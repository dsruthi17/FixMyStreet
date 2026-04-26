import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/complaint_model.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ════════════════════════════════════
  // COMPLAINTS
  // ════════════════════════════════════

  // Create complaint
  Future<String> createComplaint(Map<String, dynamic> data) async {
    final doc = await _firestore.collection('complaints').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update user's complaint count
    if (data['userId'] != null && data['userId'] != '') {
      await _firestore.collection('users').doc(data['userId']).update({
        'totalComplaints': FieldValue.increment(1),
      });
    }

    return doc.id;
  }

  // Add complaint ID to user's ownership list (for both anonymous and normal complaints)
  Future<void> addComplaintToUser(String userId, String complaintId) async {
    await _firestore.collection('users').doc(userId).update({
      'myComplaintIds': FieldValue.arrayUnion([complaintId]),
    });
  }

  // Get all complaints stream
  Stream<List<Complaint>> getComplaintsStream({
    String? category,
    String? status,
    String? userId,
    List<String>? complaintIds, // New: Get complaints by ID list
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('complaints')
        .orderBy('createdAt', descending: true);

    if (category != null && category != 'all') {
      query = query.where('category', isEqualTo: category);
    }
    if (status != null && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }
    if (userId != null) {
      // Match both userId (for normal) and createdBy (for anonymous)
      query = query.where('createdBy', isEqualTo: userId);
    }

    // If complaint IDs provided, filter by them (for My Complaints)
    if (complaintIds != null && complaintIds.isNotEmpty) {
      // Firestore 'in' query limit is 10, so we need to handle larger lists differently
      if (complaintIds.length <= 10) {
        query = query.where(FieldPath.documentId, whereIn: complaintIds);
      } else {
        // For more than 10 IDs, we'll filter client-side after getting results
        // (This is a limitation of Firestore - we can use multiple queries and merge if needed)
      }
    }

    return query.snapshots().map((snapshot) {
      var complaints = snapshot.docs
          .map((doc) => Complaint.fromMap(doc.data(), doc.id))
          .toList();

      // If we have more than 10 complaint IDs, filter client-side
      if (complaintIds != null && complaintIds.length > 10) {
        complaints =
            complaints.where((c) => complaintIds.contains(c.id)).toList();
      }

      return complaints;
    });
  }

  // Get single complaint
  Future<Complaint> getComplaint(String id) async {
    final doc = await _firestore.collection('complaints').doc(id).get();
    return Complaint.fromMap(doc.data()!, doc.id);
  }

  // Update complaint status (admin)
  Future<void> updateComplaintStatus({
    required String complaintId,
    required String newStatus,
    required String changedBy,
    String comment = '',
  }) async {
    final updateData = <String, dynamic>{
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': newStatus,
          'changedBy': changedBy,
          'changedAt': Timestamp.now(),
          'comment': comment,
        }
      ]),
    };

    if (newStatus == 'resolved') {
      updateData['resolvedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('complaints')
        .doc(complaintId)
        .update(updateData);

    // If resolved, update user's resolved count
    if (newStatus == 'resolved') {
      final complaint = await getComplaint(complaintId);
      if (complaint.userId.isNotEmpty) {
        await _firestore.collection('users').doc(complaint.userId).update({
          'resolvedComplaints': FieldValue.increment(1),
        });
      }
    }
  }

  // Assign complaint to worker
  Future<void> assignComplaint({
    required String complaintId,
    required String workerId,
    required String workerName,
    required String officerId,
  }) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      'assignedWorkerId': workerId,
      'assignedWorkerName': workerName,
      'assignedOfficerId': officerId,
      'status': 'assigned',
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': 'assigned',
          'changedBy': officerId,
          'changedAt': Timestamp.now(),
          'comment': 'Assigned to $workerName',
        }
      ]),
    });
  }

  // Upvote complaint
  Future<void> upvoteComplaint(String complaintId) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      'upvotes': FieldValue.increment(1),
    });
  }

  // Delete complaint (user can delete their own pending complaints)
  Future<void> deleteComplaint(String complaintId, String userId) async {
    // Get complaint data first to access media URLs and user info
    final doc =
        await _firestore.collection('complaints').doc(complaintId).get();
    if (doc.exists) {
      final data = doc.data();
      final complaintUserId = data?['userId'] ?? '';
      final mediaUrls = (data?['mediaUrls'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      // Delete media files from Storage if they exist (skip base64 data URLs)
      for (final media in mediaUrls) {
        try {
          final url = media['url'] as String?;
          if (url != null && url.isNotEmpty && !url.startsWith('data:')) {
            // Only delete from Storage if it's a real Storage URL (not base64)
            final ref = _storage.refFromURL(url);
            await ref.delete();
          }
        } catch (e) {
          // Continue even if media deletion fails
          print('Failed to delete media: $e');
        }
      }

      // Delete solution media if exists (skip base64 data URLs)
      final solutionMedia =
          (data?['solutionMedia'] as List<dynamic>?)?.cast<String>() ?? [];
      for (final url in solutionMedia) {
        try {
          if (url.isNotEmpty && !url.startsWith('data:')) {
            // Only delete from Storage if it's a real Storage URL (not base64)
            final ref = _storage.refFromURL(url);
            await ref.delete();
          }
        } catch (e) {
          print('Failed to delete solution media: $e');
        }
      }

      // Delete the complaint document
      await _firestore.collection('complaints').doc(complaintId).delete();

      // Update user's complaint count if userId exists
      if (complaintUserId.isNotEmpty) {
        await _firestore.collection('users').doc(complaintUserId).update({
          'totalComplaints': FieldValue.increment(-1),
        });
      }

      // Remove complaint ID from user's myComplaintIds array
      if (userId.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'myComplaintIds': FieldValue.arrayRemove([complaintId]),
        });
      }
    }
  }

  // Get single complaint stream (for real-time updates)
  Stream<Complaint> getComplaintStream(String complaintId) {
    return _firestore
        .collection('complaints')
        .doc(complaintId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Complaint.fromMap(doc.data()!, doc.id);
      }
      throw Exception('Complaint not found');
    });
  }

  // Get complaint counts by status
  Future<Map<String, int>> getComplaintStats() async {
    final snapshot = await _firestore.collection('complaints').get();
    final stats = <String, int>{
      'total': 0,
      'pending': 0,
      'in_progress': 0,
      'resolved': 0,
      'rejected': 0,
    };

    for (final doc in snapshot.docs) {
      stats['total'] = (stats['total'] ?? 0) + 1;
      final status = doc.data()['status'] ?? 'pending';
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return stats;
  }

  // Get complaint counts by category
  Future<Map<String, int>> getCategoryStats() async {
    final snapshot = await _firestore.collection('complaints').get();
    final stats = <String, int>{};

    for (final doc in snapshot.docs) {
      final category = doc.data()['category'] ?? 'other';
      stats[category] = (stats[category] ?? 0) + 1;
    }

    return stats;
  }

  // ════════════════════════════════════
  // FEEDBACK
  // ════════════════════════════════════

  Future<void> submitFeedback(FeedbackModel feedback) async {
    await _firestore.collection('feedbacks').add(feedback.toMap());
  }

  Future<FeedbackModel?> getFeedbackForComplaint(String complaintId) async {
    final snapshot = await _firestore
        .collection('feedbacks')
        .where('complaintId', isEqualTo: complaintId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return FeedbackModel.fromMap(
          snapshot.docs.first.data(), snapshot.docs.first.id);
    }
    return null;
  }

  // ════════════════════════════════════
  // USERS
  // ════════════════════════════════════

  Future<AppUser> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  Stream<AppUser> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => AppUser.fromMap(doc.data()!, doc.id),
        );
  }

  // ════════════════════════════════════
  // NOTIFICATIONS
  // ════════════════════════════════════

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String complaintId = '',
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'complaintId': complaintId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}

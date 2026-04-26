import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../core/models/complaint_model.dart';
import '../core/services/firestore_service.dart';
import '../core/services/storage_service.dart';

class ComplaintProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  // final StorageService _storageService = StorageService(); // Unused field removed

  List<Complaint> _complaints = [];
  List<Complaint> _myComplaints = [];
  bool _isLoading = false;
  String? _error;
  String _filterCategory = 'all';
  String _filterStatus = 'all';

  // Stats
  Map<String, int> _statusStats = {};
  Map<String, int> _categoryStats = {};

  // Stream subscriptions
  StreamSubscription? _complaintsSubscription;
  StreamSubscription? _myComplaintsSubscription;

  List<Complaint> get complaints => _complaints;
  List<Complaint> get myComplaints => _myComplaints;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterCategory => _filterCategory;
  String get filterStatus => _filterStatus;
  Map<String, int> get statusStats => _statusStats;
  Map<String, int> get categoryStats => _categoryStats;

  List<Complaint> get filteredComplaints {
    return _complaints.where((c) {
      final matchCategory =
          _filterCategory == 'all' || c.category == _filterCategory;
      final matchStatus = _filterStatus == 'all' || c.status == _filterStatus;
      return matchCategory && matchStatus;
    }).toList();
  }

  // Get complaints by status
  List<Complaint> getByStatus(String status) {
    if (status == 'all') return _complaints;
    // Include 'assigned' status as part of 'in_progress'
    if (status == 'in_progress') {
      return _complaints
          .where((c) => c.status == 'in_progress' || c.status == 'assigned')
          .toList();
    }
    return _complaints.where((c) => c.status == status).toList();
  }

  // Get complaints by category
  List<Complaint> getByCategory(String category) {
    if (category == 'all') return _complaints;
    return _complaints.where((c) => c.category == category).toList();
  }

  int countByStatus(String status) => getByStatus(status).length;
  int countByCategory(String category) => getByCategory(category).length;

  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  // ─── Stream all complaints (live) ───
  void streamAllComplaints() {
    _complaintsSubscription?.cancel();
    _complaintsSubscription =
        _firestoreService.getComplaintsStream().listen((complaints) {
      _complaints = complaints;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });
  }

  // ─── Stream my complaints ───
  void streamMyComplaints(List<String> complaintIds) {
    _myComplaintsSubscription?.cancel();

    if (complaintIds.isEmpty) {
      _myComplaints = [];
      notifyListeners();
      return;
    }

    _myComplaintsSubscription = _firestoreService
        .getComplaintsStream(complaintIds: complaintIds)
        .listen((complaints) {
      _myComplaints = complaints;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });
  }

  // ─── Get assigned complaints for a worker ───
  List<Complaint> getAssignedComplaints(String workerId) {
    return _complaints.where((c) => c.assignedWorkerId == workerId).toList();
  }

  // ─── Submit new complaint ───
  Future<bool> submitComplaint({
    required String userId,
    required String userName,
    required String userPhone,
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    required String address,
    String landmark = '',
    bool isAnonymous = false,
    List<File> mediaFiles = const [],
    List<XFile> mediaXFiles = const [],
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // Upload media files using XFile (works on both web and mobile)
      final List<Map<String, dynamic>> mediaUrls = [];

      // Use mediaXFiles if provided (web and mobile compatible), otherwise use mediaFiles
      final filesToUpload = mediaXFiles.isNotEmpty ? mediaXFiles : [];

      debugPrint('📸 Starting media upload: ${filesToUpload.length} XFiles');

      for (int i = 0; i < filesToUpload.length; i++) {
        final xfile = filesToUpload[i];
        try {
          debugPrint(
              '📸 Processing file ${i + 1}/${filesToUpload.length}: ${xfile.name}');
          debugPrint('   File path: ${xfile.path}');
          debugPrint('   File mimeType: ${xfile.mimeType}');

          // Read file as bytes and convert to base64 (Firestore-compatible)
          final bytes = await xfile.readAsBytes();
          final base64String = base64Encode(bytes);
          debugPrint(
              '   File size: ${bytes.length} bytes, base64 length: ${base64String.length}');

          // Store as base64 data URL (works without Firebase Storage)
          final fileName = xfile.name.toLowerCase();
          final isVideo = fileName.endsWith('.mp4') ||
              fileName.endsWith('.mov') ||
              fileName.endsWith('.avi') ||
              fileName.endsWith('.mkv') ||
              fileName.endsWith('.webm') ||
              fileName.endsWith('.m4v');

          final mimeType =
              xfile.mimeType ?? (isVideo ? 'video/mp4' : 'image/jpeg');
          final dataUrl = 'data:$mimeType;base64,$base64String';

          final mediaObject = {
            'type': isVideo ? 'video' : 'image',
            'url': dataUrl, // Base64 data URL - no Storage needed!
          };

          mediaUrls.add(mediaObject);
          debugPrint(
              '✅ Processed file ${i + 1}: base64 data URL (${isVideo ? "video" : "image"})');
          debugPrint('📦 Media object type: ${mediaObject['type']}');
        } catch (e, stackTrace) {
          debugPrint('❌ Failed to process file ${i + 1}: $e');
          debugPrint('   Stack trace: $stackTrace');
          // Continue without this file
        }
      }

      debugPrint(
          '📸 Upload complete: ${mediaUrls.length} files uploaded successfully');
      if (mediaUrls.isNotEmpty) {
        debugPrint('📦 First media URL: ${mediaUrls.first}');
      }

      final data = {
        'userId': userId, // ALWAYS store userId for ownership tracking
        'userName': isAnonymous ? 'Anonymous' : userName,
        'userPhone': userPhone,
        'title': title,
        'description': description,
        'category': category,
        'status': 'pending',
        'priority': 'medium',
        'isAnonymous': isAnonymous,
        'mediaUrls': mediaUrls,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'landmark': landmark,
        },
        'upvotes': 0,
        'statusHistory': [
          {
            'status': 'pending',
            'changedBy': 'system',
            'changedAt': DateTime.now().toIso8601String(),
            'comment': 'Complaint submitted',
          }
        ],
        'adminNotes': '',
      };

      debugPrint('Creating complaint with ${mediaUrls.length} media files');
      debugPrint('Media URLs: $mediaUrls');
      debugPrint('Complaint data: $data');

      // Create complaint and get its ID
      debugPrint('📝 Calling createComplaint...');
      final complaintId = await _firestoreService.createComplaint(data);
      debugPrint('✅ Complaint created with ID: $complaintId');

      // Add complaint ID to user's myComplaintIds array (works for anonymous + normal)
      if (userId.isNotEmpty) {
        debugPrint('📝 Adding complaint to user myComplaintIds...');
        await _firestoreService.addComplaintToUser(userId, complaintId);
        debugPrint(
            '✅ Added complaint $complaintId to user $userId myComplaintIds');
      }

      debugPrint('🎉 Complaint submission complete!');
      _setLoading(false);
      return true;
    } catch (e, stackTrace) {
      _error = e.toString();
      debugPrint('❌ Submit complaint error: $e');
      debugPrint('   Stack trace: $stackTrace');
      _setLoading(false);
      return false;
    }
  }

  // ─── Update complaint status ───
  Future<bool> updateStatus({
    required String complaintId,
    required String newStatus,
    required String adminId,
    String comment = '',
  }) async {
    try {
      await _firestoreService.updateComplaintStatus(
        complaintId: complaintId,
        newStatus: newStatus,
        changedBy: adminId,
        comment: comment,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ─── Assign complaint to worker ───
  Future<bool> assignToWorker({
    required String complaintId,
    required String workerId,
    required String workerName,
    required String officerId,
  }) async {
    try {
      await _firestoreService.assignComplaint(
        complaintId: complaintId,
        workerId: workerId,
        workerName: workerName,
        officerId: officerId,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ─── Load stats ───
  Future<void> loadStats() async {
    _statusStats = await _firestoreService.getComplaintStats();
    _categoryStats = await _firestoreService.getCategoryStats();
    notifyListeners();
  }

  // ─── Delete complaint ───
  Future<bool> deleteComplaint(String complaintId, String userId) async {
    _setLoading(true);
    _error = null;
    try {
      await _firestoreService.deleteComplaint(complaintId, userId);
      // Remove from local lists
      _complaints.removeWhere((c) => c.id == complaintId);
      _myComplaints.removeWhere((c) => c.id == complaintId);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ─── Get single complaint stream ───
  Stream<Complaint> getComplaintStream(String complaintId) {
    return _firestoreService.getComplaintStream(complaintId);
  }

  // ─── Upvote complaint ───
  Future<bool> upvoteComplaint(String complaintId) async {
    try {
      await _firestoreService.upvoteComplaint(complaintId);
      // Update local list if the complaint exists
      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        _complaints[index] = _complaints[index].copyWith(
          upvotes: _complaints[index].upvotes + 1,
        );
      }
      final myIndex = _myComplaints.indexWhere((c) => c.id == complaintId);
      if (myIndex != -1) {
        _myComplaints[myIndex] = _myComplaints[myIndex].copyWith(
          upvotes: _myComplaints[myIndex].upvotes + 1,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  @override
  void dispose() {
    _complaintsSubscription?.cancel();
    _myComplaintsSubscription?.cancel();
    super.dispose();
  }
}

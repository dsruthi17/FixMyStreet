import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String complaintId;
  final String userId;
  final double rating;
  final String comment;
  final double resolutionQuality;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.complaintId,
    required this.userId,
    required this.rating,
    this.comment = '',
    this.resolutionQuality = 0,
    required this.createdAt,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String id) {
    return FeedbackModel(
      id: id,
      complaintId: map['complaintId'] ?? '',
      userId: map['userId'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      resolutionQuality: (map['resolutionQuality'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'complaintId': complaintId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'resolutionQuality': resolutionQuality,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

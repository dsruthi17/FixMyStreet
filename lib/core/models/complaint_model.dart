import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status; // pending, assigned, in_progress, resolved, rejected
  final double latitude;
  final double longitude;
  final String address;
  final String landmark;
  final List<Map<String, dynamic>> mediaUrls;
  final String userId; // Always stores actual user ID, even for anonymous
  final String userName;
  final String userPhone;
  final bool isAnonymous;
  final int upvotes;
  final String priority; // low, medium, high, urgent
  final String assignedOfficerId;
  final String assignedOfficerName;
  final String assignedWorkerId;
  final String assignedWorkerName;
  final String solution;
  final List<String> solutionMedia;
  final String officerRemarks;
  final List<Map<String, dynamic>> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Complaint({
    this.id = '',
    required this.title,
    required this.description,
    required this.category,
    this.status = 'pending',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.address = '',
    this.landmark = '',
    this.mediaUrls = const [],
    this.userId = '', // Always stores actual user ID
    this.userName = '',
    this.userPhone = '',
    this.isAnonymous = false,
    this.upvotes = 0,
    this.priority = 'medium',
    this.assignedOfficerId = '',
    this.assignedOfficerName = '',
    this.assignedWorkerId = '',
    this.assignedWorkerName = '',
    this.solution = '',
    this.solutionMedia = const [],
    this.officerRemarks = '',
    this.statusHistory = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get categoryDisplay {
    switch (category) {
      case 'roads':
        return 'Roads & Potholes';
      case 'water':
        return 'Water Supply';
      case 'electricity':
        return 'Electricity';
      case 'sanitation':
        return 'Sanitation';
      case 'garbage':
        return 'Garbage';
      case 'drainage':
        return 'Drainage';
      case 'streetlights':
        return 'Street Lights';
      case 'parks':
        return 'Parks & Gardens';
      default:
        return category.isNotEmpty
            ? category[0].toUpperCase() + category.substring(1)
            : 'Other';
    }
  }

  factory Complaint.fromMap(Map<String, dynamic> map, String docId) {
    // Handle both nested location map and flat fields
    final locationMap = map['location'] as Map<String, dynamic>?;
    final lat = locationMap != null
        ? (locationMap['latitude'] ?? 0.0).toDouble()
        : (map['latitude'] ?? 0.0).toDouble();
    final lng = locationMap != null
        ? (locationMap['longitude'] ?? 0.0).toDouble()
        : (map['longitude'] ?? 0.0).toDouble();
    final addr = locationMap != null
        ? (locationMap['address'] ?? '')
        : (map['address'] ?? '');
    final lmk = locationMap != null
        ? (locationMap['landmark'] ?? '')
        : (map['landmark'] ?? '');

    return Complaint(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? 'pending',
      latitude: lat,
      longitude: lng,
      address: addr,
      landmark: lmk,
      mediaUrls: List<Map<String, dynamic>>.from(map['mediaUrls'] ?? []),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      isAnonymous: map['isAnonymous'] ?? false,
      upvotes: map['upvotes'] ?? 0,
      priority: map['priority'] ?? 'medium',
      assignedOfficerId: map['assignedOfficerId'] ?? '',
      assignedOfficerName: map['assignedOfficerName'] ?? '',
      assignedWorkerId: map['assignedWorkerId'] ?? '',
      assignedWorkerName: map['assignedWorkerName'] ?? '',
      solution: map['solution'] ?? '',
      solutionMedia: List<String>.from(map['solutionMedia'] ?? []),
      officerRemarks: map['officerRemarks'] ?? '',
      statusHistory:
          List<Map<String, dynamic>>.from(map['statusHistory'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'landmark': landmark,
      'mediaUrls': mediaUrls,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'isAnonymous': isAnonymous,
      'upvotes': upvotes,
      'priority': priority,
      'assignedOfficerId': assignedOfficerId,
      'assignedOfficerName': assignedOfficerName,
      'assignedWorkerId': assignedWorkerId,
      'assignedWorkerName': assignedWorkerName,
      'solution': solution,
      'solutionMedia': solutionMedia,
      'officerRemarks': officerRemarks,
      'statusHistory': statusHistory,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Complaint copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? status,
    double? latitude,
    double? longitude,
    String? address,
    String? landmark,
    List<Map<String, dynamic>>? mediaUrls,
    String? userId,
    String? userName,
    String? userPhone,
    bool? isAnonymous,
    int? upvotes,
    String? priority,
    String? assignedOfficerId,
    String? assignedOfficerName,
    String? assignedWorkerId,
    String? assignedWorkerName,
    String? solution,
    List<String>? solutionMedia,
    String? officerRemarks,
    List<Map<String, dynamic>>? statusHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Complaint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      upvotes: upvotes ?? this.upvotes,
      priority: priority ?? this.priority,
      assignedOfficerId: assignedOfficerId ?? this.assignedOfficerId,
      assignedOfficerName: assignedOfficerName ?? this.assignedOfficerName,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      assignedWorkerName: assignedWorkerName ?? this.assignedWorkerName,
      solution: solution ?? this.solution,
      solutionMedia: solutionMedia ?? this.solutionMedia,
      officerRemarks: officerRemarks ?? this.officerRemarks,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

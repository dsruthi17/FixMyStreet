import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { citizen, worker, officer, admin }

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String photoURL;
  final UserRole role;
  final bool isAnonymous;
  final String language;
  final String department;
  final int totalComplaints;
  final int resolvedComplaints;
  final List<String> assignedComplaints;
  final List<String>
      myComplaintIds; // IDs of complaints owned by this user (anonymous + normal)
  final List<String> deviceTokens;
  final DateTime createdAt;
  final DateTime lastLogin;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.phoneNumber = '',
    this.photoURL = '',
    this.role = UserRole.citizen,
    this.isAnonymous = false,
    this.language = 'en',
    this.department = '',
    this.totalComplaints = 0,
    this.resolvedComplaints = 0,
    this.assignedComplaints = const [],
    this.myComplaintIds = const [], // Initialize empty list
    this.deviceTokens = const [],
    required this.createdAt,
    required this.lastLogin,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isOfficer => role == UserRole.officer;
  bool get isWorker => role == UserRole.worker;
  bool get isCitizen => role == UserRole.citizen;

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'officer':
        return UserRole.officer;
      case 'worker':
        return UserRole.worker;
      default:
        return UserRole.citizen;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.officer:
        return 'officer';
      case UserRole.worker:
        return 'worker';
      case UserRole.citizen:
        return 'citizen';
    }
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoURL: map['photoURL'] ?? '',
      role: _parseRole(map['role']),
      isAnonymous: map['isAnonymous'] ?? false,
      language: map['language'] ?? 'en',
      department: map['department'] ?? '',
      totalComplaints: map['totalComplaints'] ?? 0,
      resolvedComplaints: map['resolvedComplaints'] ?? 0,
      assignedComplaints: List<String>.from(map['assignedComplaints'] ?? []),
      myComplaintIds: List<String>.from(
          map['myComplaintIds'] ?? []), // Load user's complaint IDs
      deviceTokens: List<String>.from(map['deviceTokens'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'role': _roleToString(role),
      'isAnonymous': isAnonymous,
      'language': language,
      'department': department,
      'totalComplaints': totalComplaints,
      'resolvedComplaints': resolvedComplaints,
      'assignedComplaints': assignedComplaints,
      'myComplaintIds': myComplaintIds, // Save user's complaint IDs
      'deviceTokens': deviceTokens,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    UserRole? role,
    bool? isAnonymous,
    String? language,
    String? department,
    int? totalComplaints,
    int? resolvedComplaints,
    List<String>? assignedComplaints,
    List<String>? myComplaintIds,
    List<String>? deviceTokens,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      language: language ?? this.language,
      department: department ?? this.department,
      totalComplaints: totalComplaints ?? this.totalComplaints,
      resolvedComplaints: resolvedComplaints ?? this.resolvedComplaints,
      assignedComplaints: assignedComplaints ?? this.assignedComplaints,
      myComplaintIds: myComplaintIds ?? this.myComplaintIds,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

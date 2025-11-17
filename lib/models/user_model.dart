import 'package:cloud_firestore/cloud_firestore.dart';
import 'family_member_model.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final LocationData location;
  final String status; // 'pending_review', 'partial', 'approved', 'rejected'
  final List<FamilyMember> familyMembers;
  final bool phoneVerified; // CHANGED: Now used for full verification gating
  final bool emailVerified; // KEPT: Used only for registration
  final String verificationStatus; // NEW: 'pending_admin', 'partially_verified', 'fully_verified', 'suspended'
  final bool profileCompleted; // NEW: Track if profile dashboard is completed
  final DateTime createdAt;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.status,
    this.familyMembers = const [],
    this.phoneVerified = false,
    this.emailVerified = false,
    this.verificationStatus = 'pending_admin',
    this.profileCompleted = false,
    required this.createdAt,
    this.isAdmin = false,
  });

  // From Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      location: LocationData.fromMap(map['location'] ?? {}),
      status: map['status'] ?? 'partial',
      familyMembers: ((map['familyMembers'] as List?) ?? [])
          .map((m) => FamilyMember.fromMap(m as Map<String, dynamic>))
          .toList(),
      phoneVerified: map['phoneVerified'] ?? false,
      emailVerified: map['emailVerified'] ?? false,
      verificationStatus: map['verificationStatus'] ?? 'pending_admin',
      profileCompleted: map['profileCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location.toMap(),
      'status': status,
      'familyMembers': familyMembers.map((m) => m.toMap()).toList(),
      'phoneVerified': phoneVerified,
      'emailVerified': emailVerified,
      'verificationStatus': verificationStatus,
      'profileCompleted': profileCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAdmin': isAdmin,
    };
  }

  // Helper to check if user is fully verified
  bool get isFullyVerified {
    return verificationStatus == 'fully_verified' &&
        phoneVerified &&
        profileCompleted;
  }

  // Copy with
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    LocationData? location,
    String? status,
    List<FamilyMember>? familyMembers,
    bool? phoneVerified,
    bool? emailVerified,
    String? verificationStatus,
    bool? profileCompleted,
    DateTime? createdAt,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      status: status ?? this.status,
      familyMembers: familyMembers ?? this.familyMembers,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class LocationData {
  final String province;
  final String city;
  final String barangay;

  LocationData({
    required this.province,
    required this.city,
    required this.barangay,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      province: map['province'] ?? '',
      city: map['city'] ?? '',
      barangay: map['barangay'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'province': province,
      'city': city,
      'barangay': barangay,
    };
  }

  // Generate document ID for Firestore
  String toDocumentId() {
    return '${province}__${city}__${barangay}'
        .replaceAll(' ', '_')
        .replaceAll('/', '_');
  }
}
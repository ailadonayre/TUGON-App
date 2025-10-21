import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final LocationData location;
  final String status; // 'pending_review', 'partial', 'approved', 'rejected'
  final bool phoneVerified;
  final bool emailVerified;
  final DateTime createdAt;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.status,
    this.phoneVerified = false,
    this.emailVerified = false,
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
      phoneVerified: map['phoneVerified'] ?? false,
      emailVerified: map['emailVerified'] ?? false,
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
      'phoneVerified': phoneVerified,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAdmin': isAdmin,
    };
  }

  // Copy with
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    LocationData? location,
    String? status,
    bool? phoneVerified,
    bool? emailVerified,
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
      phoneVerified: phoneVerified ?? this.phoneVerified,
      emailVerified: emailVerified ?? this.emailVerified,
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'family_member_model.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final LocationData location;

  // New verification fields
  final String verificationStatus; // pending_admin, partially_verified, fully_verified, suspended
  final bool emailVerified;
  final bool profileCompleted;

  // New profile fields
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? placeOfBirth;
  final String? houseNumber;
  final String? streetName;
  final String? profilePictureUrl;
  final List<FamilyMember> familyMembers;

  final DateTime createdAt;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    this.verificationStatus = 'pending_admin',
    this.emailVerified = false,
    this.profileCompleted = false,
    this.firstName,
    this.middleName,
    this.lastName,
    this.dateOfBirth,
    this.placeOfBirth,
    this.houseNumber,
    this.streetName,
    this.profilePictureUrl,
    this.familyMembers = const [],
    required this.createdAt,
    this.isAdmin = false,
  });

  // Legacy status getter for backward compatibility
  String get status => verificationStatus;

  bool get phoneVerified => false; // Deprecated but kept for compatibility

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      location: LocationData.fromMap(map['location'] ?? {}),
      verificationStatus: map['verificationStatus'] ?? map['status'] ?? 'pending_admin',
      emailVerified: map['emailVerified'] ?? false,
      profileCompleted: map['profileCompleted'] ?? false,
      firstName: map['firstName'],
      middleName: map['middleName'],
      lastName: map['lastName'],
      dateOfBirth: map['dateOfBirth'] != null
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      placeOfBirth: map['placeOfBirth'],
      houseNumber: map['houseNumber'],
      streetName: map['streetName'],
      profilePictureUrl: map['profilePictureUrl'],
      familyMembers: (map['familyMembers'] as List<dynamic>?)
          ?.map((m) => FamilyMember.fromMap(m as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location.toMap(),
      'verificationStatus': verificationStatus,
      'status': verificationStatus, // For backward compatibility
      'emailVerified': emailVerified,
      'profileCompleted': profileCompleted,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'placeOfBirth': placeOfBirth,
      'houseNumber': houseNumber,
      'streetName': streetName,
      'profilePictureUrl': profilePictureUrl,
      'familyMembers': familyMembers.map((m) => m.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isAdmin': isAdmin,
      'phoneVerified': false, // Deprecated
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    LocationData? location,
    String? verificationStatus,
    bool? emailVerified,
    bool? profileCompleted,
    String? firstName,
    String? middleName,
    String? lastName,
    DateTime? dateOfBirth,
    String? placeOfBirth,
    String? houseNumber,
    String? streetName,
    String? profilePictureUrl,
    List<FamilyMember>? familyMembers,
    DateTime? createdAt,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      emailVerified: emailVerified ?? this.emailVerified,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      houseNumber: houseNumber ?? this.houseNumber,
      streetName: streetName ?? this.streetName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      familyMembers: familyMembers ?? this.familyMembers,
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

  String toDocumentId() {
    return '${province}__${city}__${barangay}'
        .replaceAll(' ', '_')
        .replaceAll('/', '_');
  }
}
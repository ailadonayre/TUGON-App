import 'package:cloud_firestore/cloud_firestore.dart';
import 'family_member_model.dart';

class PersonalInformation {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? suffix;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String homeProvince;
  final String homeCity;
  final String homeBarangay;
  final String currentAddress;
  final bool is4PsRecipient;
  final bool isIndigenousPeople;
  final String? indigenousPeopleGroup;

  PersonalInformation({
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.suffix,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.homeProvince,
    required this.homeCity,
    required this.homeBarangay,
    required this.currentAddress,
    this.is4PsRecipient = false,
    this.isIndigenousPeople = false,
    this.indigenousPeopleGroup,
  });

  factory PersonalInformation.fromMap(Map<String, dynamic> map) {
    return PersonalInformation(
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'],
      lastName: map['lastName'] ?? '',
      suffix: map['suffix'],
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      placeOfBirth: map['placeOfBirth'] ?? '',
      homeProvince: map['homeProvince'] ?? '',
      homeCity: map['homeCity'] ?? '',
      homeBarangay: map['homeBarangay'] ?? '',
      currentAddress: map['currentAddress'] ?? '',
      is4PsRecipient: map['is4PsRecipient'] ?? false,
      isIndigenousPeople: map['isIndigenousPeople'] ?? false,
      indigenousPeopleGroup: map['indigenousPeopleGroup'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'suffix': suffix,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'placeOfBirth': placeOfBirth,
      'homeProvince': homeProvince,
      'homeCity': homeCity,
      'homeBarangay': homeBarangay,
      'currentAddress': currentAddress,
      'is4PsRecipient': is4PsRecipient,
      'isIndigenousPeople': isIndigenousPeople,
      'indigenousPeopleGroup': indigenousPeopleGroup,
    };
  }

  String get fullName {
    String name = firstName;
    if (middleName != null && middleName!.isNotEmpty) {
      name += ' $middleName';
    }
    name += ' $lastName';
    if (suffix != null && suffix!.isNotEmpty) {
      name += ' $suffix';
    }
    return name;
  }
}

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final LocationData location;
  final String status;
  final List<FamilyMember> familyMembers;
  final bool emailVerified;
  final bool profileCompleted;
  final String verificationStatus;
  final PersonalInformation? personalInfo;
  final String? profilePictureUrl;
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
    this.emailVerified = false,
    this.profileCompleted = false,
    this.verificationStatus = 'pending_admin',
    this.personalInfo,
    this.profilePictureUrl,
    required this.createdAt,
    this.isAdmin = false,
  });

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
      emailVerified: map['emailVerified'] ?? false,
      profileCompleted: map['profileCompleted'] ?? false,
      verificationStatus: map['verificationStatus'] ?? 'pending_admin',
      personalInfo: map['personalInfo'] != null
          ? PersonalInformation.fromMap(map['personalInfo'] as Map<String, dynamic>)
          : null,
      profilePictureUrl: map['profilePictureUrl'],
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
      'status': status,
      'familyMembers': familyMembers.map((m) => m.toMap()).toList(),
      'emailVerified': emailVerified,
      'profileCompleted': profileCompleted,
      'verificationStatus': verificationStatus,
      'personalInfo': personalInfo?.toMap(),
      'profilePictureUrl': profilePictureUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAdmin': isAdmin,
    };
  }

  bool get isFullyVerified {
    return verificationStatus == 'fully_verified' && personalInfo != null;
  }

  bool get isPartiallyVerified {
    return verificationStatus == 'partially_verified';
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    LocationData? location,
    String? status,
    List<FamilyMember>? familyMembers,
    bool? emailVerified,
    bool? profileCompleted,
    String? verificationStatus,
    PersonalInformation? personalInfo,
    String? profilePictureUrl,
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
      emailVerified: emailVerified ?? this.emailVerified,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      personalInfo: personalInfo ?? this.personalInfo,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
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
import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMember {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String relationship; // mother, father, son, daughter

  FamilyMember({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.relationship,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'],
      lastName: map['lastName'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      placeOfBirth: map['placeOfBirth'] ?? '',
      relationship: map['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'placeOfBirth': placeOfBirth,
      'relationship': relationship,
    };
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  static List<String> get validRelationships => ['mother', 'father', 'son', 'daughter'];
}
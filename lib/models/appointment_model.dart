import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String userId;
  final String userName;
  final List<String> requestedDocuments;
  final DateTime requestedDate;
  final String status; // pending, approved, rejected, rescheduled
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? rescheduledDate;
  final String? adminNotes; // For rejection or rescheduling reasons

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.requestedDocuments,
    required this.requestedDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.rescheduledDate,
    this.adminNotes,
  });

  // Factory constructor to create an AppointmentModel from a Firestore document
  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      requestedDocuments: List<String>.from(map['requestedDocuments'] ?? []),
      requestedDate: (map['requestedDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      rescheduledDate: (map['rescheduledDate'] as Timestamp?)?.toDate(),
      adminNotes: map['adminNotes'],
    );
  }

  // Method to convert an AppointmentModel instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'requestedDocuments': requestedDocuments,
      'requestedDate': Timestamp.fromDate(requestedDate),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'rescheduledDate': rescheduledDate != null ? Timestamp.fromDate(rescheduledDate!) : null,
      'adminNotes': adminNotes,
    };
  }
}

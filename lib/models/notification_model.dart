import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'announcement', 'critical', 'general', 'report_update', 'appointment_update'
  final String? targetBarangay;
  final String? userId; // For user-specific notifications
  final bool read;
  final DateTime createdAt;
  final String? postId;
  final String? reportId;
  final String? appointmentId; // --- 1. ADD THIS LINE ---

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.targetBarangay,
    this.userId,
    this.read = false,
    required this.createdAt,
    this.postId,
    this.reportId,
    this.appointmentId, // --- 2. ADD THIS TO THE CONSTRUCTOR ---
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'general',
      targetBarangay: map['targetBarangay'],
      userId: map['userId'],
      read: map['read'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      postId: map['postId'],
      reportId: map['reportId'],
      appointmentId: map['appointmentId'], // --- 3. ADD THIS LINE ---
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'targetBarangay': targetBarangay,
      'userId': userId,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
      'postId': postId,
      'reportId': reportId,
      'appointmentId': appointmentId, // --- 4. ADD THIS LINE ---
    };
  }

  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      targetBarangay: targetBarangay,
      userId: userId,
      read: read ?? this.read,
      createdAt: createdAt,
      postId: postId,
      reportId: reportId,
      appointmentId: appointmentId, // --- 5. ADD THIS LINE ---
    );
  }
}

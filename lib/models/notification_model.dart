import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'announcement', 'critical', 'general'
  final String? targetBarangay;
  final bool read;
  final DateTime createdAt;
  final String? postId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.targetBarangay,
    this.read = false,
    required this.createdAt,
    this.postId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'general',
      targetBarangay: map['targetBarangay'],
      read: map['read'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      postId: map['postId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'targetBarangay': targetBarangay,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
      'postId': postId,
    };
  }

  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      targetBarangay: targetBarangay,
      read: read ?? this.read,
      createdAt: createdAt,
      postId: postId,
    );
  }
}
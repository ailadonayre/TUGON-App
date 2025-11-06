import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String type; // 'barangay' or 'community'
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? imageUrl;
  final bool pinned;
  final bool isCritical;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PostModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.imageUrl,
    this.pinned = false,
    this.isCritical = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      type: map['type'] ?? 'community',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      imageUrl: map['imageUrl'],
      pinned: map['pinned'] ?? false,
      isCritical: map['isCritical'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'pinned': pinned,
      'isCritical': isCritical,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
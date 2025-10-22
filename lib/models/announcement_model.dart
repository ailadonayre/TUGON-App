import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for barangay announcements
/// Will be implemented in Phase 2
class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String barangayId;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String priority; // 'urgent', 'high', 'normal', 'low'
  final String? imageUrl;
  final bool isActive;
  final List<String> tags;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.barangayId,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.priority = 'normal',
    this.imageUrl,
    this.isActive = true,
    this.tags = const [],
  });

  // From Firestore
  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    return AnnouncementModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      barangayId: map['barangayId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      priority: map['priority'] ?? 'normal',
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] ?? true,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'barangayId': barangayId,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'priority': priority,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'tags': tags,
    };
  }

  // Copy with
  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    String? barangayId,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? priority,
    String? imageUrl,
    bool? isActive,
    List<String>? tags,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      barangayId: barangayId ?? this.barangayId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
    );
  }
}
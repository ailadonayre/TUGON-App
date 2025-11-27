import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfilePicture;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userProfilePicture,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfilePicture: map['userProfilePicture'],
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userProfilePicture': userProfilePicture,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}

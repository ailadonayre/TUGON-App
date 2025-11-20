import 'package:cloud_firestore/cloud_firestore.dart';

class ReactionModel {
  final String id;
  final String postId;
  final String userId;
  final String type; // 'upvote' or 'downvote'
  final DateTime createdAt;

  ReactionModel({
  required this.id,
  required this.postId,
  required this.userId,
  required this.type,
  required this.createdAt
  });

  factory ReactionModel.fromMap(Map<String, dynamic> map, String id) {
    return ReactionModel(
      id: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'upvote',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class PostReactionStats {
  final int upvotes;
  final int downvotes;
  final String? userReaction; // 'upvote', 'downvote', or null

  PostReactionStats({
    required this.upvotes,
    required this.downvotes,
    this.userReaction,
  });

  int get score => upvotes - downvotes;
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get the comments collection path for a specific post
  String _getCommentsPath(LocationData location, String postId) {
    final barangayDocId = location.toDocumentId();
    return 'barangays/$barangayDocId/posts/$postId/comments';
  }

  /// Stream comments for a post
  Stream<List<CommentModel>> streamComments(String postId, LocationData location) {
    return _firestore
        .collection(_getCommentsPath(location, postId))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get comment count for a post
  Stream<int> streamCommentCount(String postId, LocationData location) {
    return _firestore
        .collection(_getCommentsPath(location, postId))
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Add a comment to a post
  Future<void> addComment({
    required String postId,
    required LocationData location,
    required String userId,
    required String userName,
    String? userProfilePicture,
    required String content,
  }) async {
    final comment = CommentModel(
      id: '',
      postId: postId,
      userId: userId,
      userName: userName,
      userProfilePicture: userProfilePicture,
      content: content,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(_getCommentsPath(location, postId))
        .add(comment.toMap());
  }

  /// Update a comment
  Future<void> updateComment({
    required String postId,
    required LocationData location,
    required String commentId,
    required String content,
  }) async {
    await _firestore
        .collection(_getCommentsPath(location, postId))
        .doc(commentId)
        .update({
      'content': content,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Delete a comment
  Future<void> deleteComment({
    required String postId,
    required LocationData location,
    required String commentId,
  }) async {
    await _firestore
        .collection(_getCommentsPath(location, postId))
        .doc(commentId)
        .delete();
  }

  /// Get all comments for a post (one-time fetch)
  Future<List<CommentModel>> getComments(String postId, LocationData location) async {
    final snapshot = await _firestore
        .collection(_getCommentsPath(location, postId))
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}

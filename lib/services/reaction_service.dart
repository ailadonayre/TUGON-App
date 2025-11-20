import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reaction_model.dart';
import '../models/user_model.dart';

class ReactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Toggle upvote
  Future<void> toggleUpvote(
      String postId,
      String userId,
      LocationData location,
      ) async {
    try {
      final barangayId = location.toDocumentId();
      final reactionsRef = _firestore
          .collection('barangays')
          .doc(barangayId)
          .collection('posts')
          .doc(postId)
          .collection('reactions');

      // Check existing reaction
      final existingQuery = await reactionsRef
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        final existingDoc = existingQuery.docs.first;
        final existingType = existingDoc.data()['type'];

        if (existingType == 'upvote') {
          // Remove upvote
          await existingDoc.reference.delete();
        } else {
          // Change downvote to upvote
          await existingDoc.reference.update({
            'type': 'upvote',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Add new upvote
        await reactionsRef.add({
          'postId': postId,
          'userId': userId,
          'type': 'upvote',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle upvote: ${e.toString()}');
    }
  }

  // Toggle downvote
  Future<void> toggleDownvote(
      String postId,
      String userId,
      LocationData location,
      ) async {
    try {
      final barangayId = location.toDocumentId();
      final reactionsRef = _firestore
          .collection('barangays')
          .doc(barangayId)
          .collection('posts')
          .doc(postId)
          .collection('reactions');

      // Check existing reaction
      final existingQuery = await reactionsRef
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        final existingDoc = existingQuery.docs.first;
        final existingType = existingDoc.data()['type'];

        if (existingType == 'downvote') {
          // Remove downvote
          await existingDoc.reference.delete();
        } else {
          // Change upvote to downvote
          await existingDoc.reference.update({
            'type': 'downvote',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Add new downvote
        await reactionsRef.add({
          'postId': postId,
          'userId': userId,
          'type': 'downvote',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle downvote: ${e.toString()}');
    }
  }

  // Get reaction stats for a post
  Future<PostReactionStats> getReactionStats(
      String postId,
      LocationData location,
      String? currentUserId,
      ) async {
    try {
      final barangayId = location.toDocumentId();
      final reactionsRef = _firestore
          .collection('barangays')
          .doc(barangayId)
          .collection('posts')
          .doc(postId)
          .collection('reactions');

      final snapshot = await reactionsRef.get();

      int upvotes = 0;
      int downvotes = 0;
      String? userReaction;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String;
        final userId = data['userId'] as String;

        if (type == 'upvote') {
          upvotes++;
        } else if (type == 'downvote') {
          downvotes++;
        }

        if (currentUserId != null && userId == currentUserId) {
          userReaction = type;
        }
      }

      return PostReactionStats(
        upvotes: upvotes,
        downvotes: downvotes,
        userReaction: userReaction,
      );
    } catch (e) {
      throw Exception('Failed to get reaction stats: ${e.toString()}');
    }
  }

  // Stream reaction stats for real-time updates
  Stream<PostReactionStats> streamReactionStats(
      String postId,
      LocationData location,
      String? currentUserId,
      ) {
    final barangayId = location.toDocumentId();
    final reactionsRef = _firestore
        .collection('barangays')
        .doc(barangayId)
        .collection('posts')
        .doc(postId)
        .collection('reactions');

    return reactionsRef.snapshots().map((snapshot) {
      int upvotes = 0;
      int downvotes = 0;
      String? userReaction;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'] as String;
        final userId = data['userId'] as String;

        if (type == 'upvote') {
          upvotes++;
        } else if (type == 'downvote') {
          downvotes++;
        }

        if (currentUserId != null && userId == currentUserId) {
          userReaction = type;
        }
      }

      return PostReactionStats(
        upvotes: upvotes,
        downvotes: downvotes,
        userReaction: userReaction,
      );
    });
  }
}
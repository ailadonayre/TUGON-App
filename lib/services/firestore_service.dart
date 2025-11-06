import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ USER METHODS ============

  Future<void> createUser(UserModel user) async {
    try {
      final barangayDocId = user.location.toDocumentId();
      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<UserModel?> findUserByEmail(String email) async {
    try {
      final barangays = await _firestore.collection('barangays').get();
      for (var barangayDoc in barangays.docs) {
        final usersSnapshot = await barangayDoc.reference
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (usersSnapshot.docs.isNotEmpty) {
          final userDoc = usersSnapshot.docs.first;
          return UserModel.fromMap(userDoc.data(), userDoc.id);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to find user: ${e.toString()}');
    }
  }

  Future<UserModel?> getUserByUid(String uid, LocationData location) async {
    try {
      final barangayDocId = location.toDocumentId();
      final doc = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // NEW: Update user profile
  Future<void> updateUserProfile(String uid, LocationData location, Map<String, dynamic> updates) async {
    try {
      final barangayDocId = location.toDocumentId();
      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(uid)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // NEW: Check and update verification status
  Future<void> checkAndUpdateVerificationStatus(String uid, LocationData location) async {
    try {
      final user = await getUserByUid(uid, location);
      if (user != null && user.emailVerified && user.profileCompleted) {
        await updateUserProfile(uid, location, {'verificationStatus': 'fully_verified'});
      }
    } catch (e) {
      throw Exception('Failed to update verification status: ${e.toString()}');
    }
  }

  Future<void> updateEmailVerification(String uid, LocationData location, bool verified) async {
    try {
      await updateUserProfile(uid, location, {'emailVerified': verified});
      if (verified) {
        await checkAndUpdateVerificationStatus(uid, location);
      }
    } catch (e) {
      throw Exception('Failed to update email verification: ${e.toString()}');
    }
  }

  Future<void> updateUserStatus(String uid, LocationData location, String status) async {
    try {
      // When admin approves, set to partially_verified
      final newStatus = status == 'approved' ? 'partially_verified' : status;
      await updateUserProfile(uid, location, {'verificationStatus': newStatus});
    } catch (e) {
      throw Exception('Failed to update user status: ${e.toString()}');
    }
  }

  Future<bool> isUserAdmin(String uid) async {
    try {
      final barangays = await _firestore.collection('barangays').get();
      for (var barangayDoc in barangays.docs) {
        final userDoc = await barangayDoc.reference.collection('users').doc(uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          return data?['isAdmin'] == true;
        }
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check admin status: ${e.toString()}');
    }
  }

  Future<List<UserModel>> getPendingUsers(LocationData location) async {
    try {
      final barangayDocId = location.toDocumentId();
      final snapshot = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .where('verificationStatus', isEqualTo: 'pending_admin')
          .get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get pending users: ${e.toString()}');
    }
  }

  Future<List<UserModel>> getAllUsers(LocationData location) async {
    try {
      final barangayDocId = location.toDocumentId();
      final snapshot = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }

  Future<List<UserModel>> getUsersByStatus(LocationData location, String status) async {
    try {
      final barangayDocId = location.toDocumentId();
      final snapshot = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .where('verificationStatus', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get users by status: ${e.toString()}');
    }
  }

  Future<void> approveUser(String uid, LocationData location) async {
    try {
      await updateUserStatus(uid, location, 'approved');
    } catch (e) {
      throw Exception('Failed to approve user: ${e.toString()}');
    }
  }

  Future<void> rejectUser(String uid, LocationData location) async {
    try {
      await updateUserStatus(uid, location, 'rejected');
    } catch (e) {
      throw Exception('Failed to reject user: ${e.toString()}');
    }
  }

  Future<Map<String, int>> getUserStatistics(LocationData location) async {
    try {
      final barangayDocId = location.toDocumentId();
      final allUsers = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .get();

      int total = allUsers.docs.length;
      int pending = 0;
      int approved = 0;
      int rejected = 0;

      for (var doc in allUsers.docs) {
        final status = doc.data()['verificationStatus'] as String?;
        switch (status) {
          case 'pending_admin':
            pending++;
            break;
          case 'partially_verified':
          case 'fully_verified':
            approved++;
            break;
          case 'rejected':
            rejected++;
            break;
        }
      }

      return {'total': total, 'pending': pending, 'approved': approved, 'rejected': rejected};
    } catch (e) {
      throw Exception('Failed to get statistics: ${e.toString()}');
    }
  }

  Future<List<UserModel>> searchUsers(LocationData location, String query) async {
    try {
      final barangayDocId = location.toDocumentId();
      final snapshot = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .get();
      final allUsers = snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
      final filtered = allUsers.where((user) {
        final nameLower = user.fullName.toLowerCase();
        final emailLower = user.email.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower) || emailLower.contains(queryLower);
      }).toList();
      return filtered;
    } catch (e) {
      throw Exception('Failed to search users: ${e.toString()}');
    }
  }

  // ============ POST METHODS ============

  Future<String> createPost(PostModel post, LocationData location) async {
    try {
      final barangayDocId = location.toDocumentId();
      final docRef = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('posts')
          .add(post.toMap());

      // Create notification for barangay posts
      if (post.type == 'barangay') {
        await createNotification(
          NotificationModel(
            id: '',
            title: post.isCritical ? '🚨 CRITICAL: ${post.title}' : post.title,
            body: post.content.length > 100 ? '${post.content.substring(0, 100)}...' : post.content,
            type: post.isCritical ? 'critical' : 'announcement',
            targetBarangay: location.barangay,
            createdAt: DateTime.now(),
            postId: docRef.id,
          ),
          location,
        );
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  Future<List<PostModel>> getPosts(LocationData location, String type) async {
    try {
      final barangayDocId = location.toDocumentId();
      Query query = _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('posts')
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get posts: ${e.toString()}');
    }
  }

  Future<void> togglePostPin(String postId, LocationData location, bool pinned) async {
    try {
      final barangayDocId = location.toDocumentId();
      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('posts')
          .doc(postId)
          .update({'pinned': pinned});
    } catch (e) {
      throw Exception('Failed to toggle pin: ${e.toString()}');
    }
  }

  // ============ NOTIFICATION METHODS ============

  Future<void> createNotification(NotificationModel notification, LocationData location) async {
    try {
      final barangayDocId = location.toDocumentId();
      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('notifications')
          .add(notification.toMap());
    } catch (e) {
      throw Exception('Failed to create notification: ${e.toString()}');
    }
  }

  Future<List<NotificationModel>> getNotifications(LocationData location) async {
    try {
      final barangayDocId = location.toDocumentId();
      final snapshot = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: ${e.toString()}');
    }
  }

  Future<void> markNotificationAsRead(String notificationId, LocationData location) async {
    try {
      final barangayDocId = location.toDocumentId();
      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }
}
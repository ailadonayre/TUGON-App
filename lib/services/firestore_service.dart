import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/notification_model.dart';
import '../models/family_member_model.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfilePicture(String uid, String barangayDocId, String newUrl) async {
    try {
      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(uid)
          .update({'profilePictureUrl': newUrl});
    } catch (e) {
      print('Error updating profile picture in Firestore: $e');
      throw Exception('Failed to update profile picture URL: ${e.toString()}');
    }
  }

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

  Future<void> updateVerificationStatus(
      String uid,
      LocationData location,
      String verificationStatus,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(uid)
          .update({'verificationStatus': verificationStatus});
    } catch (e) {
      throw Exception('Failed to update verification status: ${e.toString()}');
    }
  }

  Future<void> updateProfileCompletion(
      String uid,
      LocationData location,
      bool completed,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(uid)
          .update({'profileCompleted': completed});

      if (completed) {
        await updateVerificationStatus(uid, location, 'fully_verified');
      }
    } catch (e) {
      throw Exception('Failed to update profile completion: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile(
      String uid,
      LocationData location,
      Map<String, dynamic> updates,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(uid)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  Future<void> checkAndUpdateVerificationStatus(
      String uid,
      LocationData location,
      ) async {
    try {
      final user = await getUserByUid(uid, location);
      if (user == null) return;

      String newStatus;
      if (user.profileCompleted) {
        newStatus = 'fully_verified';
      } else if (user.profileCompleted) {
        newStatus = 'partially_verified';
      } else {
        newStatus = 'pending_admin';
      }

      if (newStatus != user.verificationStatus) {
        await updateVerificationStatus(uid, location, newStatus);
      }
    } catch (e) {
      throw Exception('Failed to check verification status: ${e.toString()}');
    }
  }

  Future<void> updateEmailVerification(
      String uid,
      LocationData location,
      bool verified,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(uid)
          .update({'emailVerified': verified});
    } catch (e) {
      throw Exception('Failed to update email verification: ${e.toString()}');
    }
  }

  Future<void> updateUserStatus(
      String uid,
      LocationData location,
      String status,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      String verificationStatus = 'pending_admin';
      if (status == 'approved') {
        verificationStatus = 'partially_verified';
      }

      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(uid)
          .update({
        'status': status,
        'verificationStatus': verificationStatus,
      });
    } catch (e) {
      throw Exception('Failed to update user status: ${e.toString()}');
    }
  }

  Future<bool> isUserAdmin(String uid) async {
    try {
      final barangays = await _firestore.collection('barangays').get();

      for (var barangayDoc in barangays.docs) {
        final userDoc = await barangayDoc.reference
            .collection('users')
            .doc(uid)
            .get();

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
          .where('status', isEqualTo: 'pending_review')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending users: ${e.toString()}');
    }
  }

  Future<void> seedBarangayDocuments() async {
    try {
      final barangays = [
        {
          'id': 'BATANGAS__BATANGAS_CITY__Alangilan',
          'metadata': {
            'province': 'BATANGAS',
            'city': 'BATANGAS CITY',
            'barangay': 'Alangilan',
          }
        },
        {
          'id': 'BATANGAS__BATANGAS_CITY__Tinga_Itaas',
          'metadata': {
            'province': 'BATANGAS',
            'city': 'BATANGAS CITY',
            'barangay': 'Tinga Itaas',
          }
        },
        {
          'id': 'BATANGAS__MUNICIPALITY_OF_AGONCILLO__Banyaga',
          'metadata': {
            'province': 'BATANGAS',
            'city': 'MUNICIPALITY OF AGONCILLO',
            'barangay': 'Banyaga',
          }
        },
      ];

      for (var barangay in barangays) {
        await _firestore
            .collection('barangays')
            .doc(barangay['id'] as String)
            .set(barangay['metadata'] as Map<String, dynamic>);
      }

      print('✅ Barangay documents seeded successfully');
    } catch (e) {
      throw Exception('Failed to seed barangay documents: ${e.toString()}');
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

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }

  Future<List<UserModel>> getUsersByStatus(
      LocationData location,
      String status,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      final snapshot = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .where('status', isEqualTo: status)
          .get();

      // Sort by createdAt locally instead of using Firestore orderBy to avoid index requirement
      final users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return users;
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

      int total = 0;
      int pending = 0;
      int approved = 0;
      int rejected = 0;

      for (var doc in allUsers.docs) {
        final data = doc.data();
        final isAdmin = data['isAdmin'] as bool? ?? false;

        // Skip admin accounts
        if (isAdmin) continue;

        total++;
        final status = data['status'] as String?;
        switch (status) {
          case 'pending_review':
            pending++;
            break;
          case 'approved':
            approved++;
            break;
          case 'rejected':
            rejected++;
            break;
        }
      }

      return {
        'total': total,
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: ${e.toString()}');
    }
  }

  Future<List<UserModel>> getAllUsersAcrossBarangays() async {
    final barangays = await _firestore.collection('barangays').get();
    List<UserModel> allUsers = [];

    for (var b in barangays.docs) {
      final usersSnapshot = await b.reference.collection('users').get();
      allUsers.addAll(
          usersSnapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id))
      );
    }

    return allUsers;
  }

  Future<List<PostModel>> getAllPostsAcrossBarangays() async {
    final barangays = await _firestore.collection('barangays').get();
    List<PostModel> allPosts = [];

    for (var b in barangays.docs) {
      final postsSnapshot = await b.reference.collection('posts').get();
      allPosts.addAll(
          postsSnapshot.docs.map((doc) => PostModel.fromMap(doc.data(), doc.id))
      );
    }

    return allPosts;
  }

  Future<List<UserModel>> searchUsers(
      LocationData location,
      String query,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      final snapshot = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .get();

      final allUsers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

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

  Future<List<PostModel>> getPosts(
      LocationData location,
      String type,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      final snapshot = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('posts')
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get posts: ${e.toString()}');
    }
  }

  Future<void> createPost(
      PostModel post,
      LocationData location,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      final postsRef = _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('posts');

      final docRef = postsRef.doc();

      final data = post.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();

      await docRef.set(data);
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  Future<void> togglePostPin(
      String postId,
      LocationData location,
      bool pinned,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('posts')
          .doc(postId)
          .update({'pinned': pinned});
    } catch (e) {
      throw Exception('Failed to toggle post pin: ${e.toString()}');
    }
  }

  Future<List<NotificationModel>> getNotifications(
      LocationData location,
      {String? userId}
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      print('🔔 Fetching notifications from barangay: $barangayDocId');

      final snapshot = await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      print('🔔 Found ${snapshot.docs.length} total notifications in database');

      var notifications = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();

      if (userId != null) {
        print('🔔 Filtering for userId: $userId');
        notifications = notifications
            .where((notif) => notif.userId == null || notif.userId == userId)
            .toList();
        print('🔔 After filtering: ${notifications.length} notifications');
      }

      return notifications;
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      throw Exception('Failed to get notifications: ${e.toString()}');
    }
  }

  Future<void> markNotificationAsRead(
      String notificationId,
      LocationData location,
      ) async {
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

  Future<void> createNotification({
    required LocationData location,
    required String title,
    required String body,
    required String type,
    String? userId,
    String? postId,
    String? reportId,
  }) async {
    try {
      final barangayDocId = location.toDocumentId();

      print('🔔 Creating notification:');
      print('  - Barangay: $barangayDocId');
      print('  - Title: $title');
      print('  - Type: $type');
      print('  - UserId: ${userId ?? "ALL (barangay-wide)"}');

      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'type': type,
        'targetBarangay': barangayDocId,
        'userId': userId,
        'postId': postId,
        'reportId': reportId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Notification created successfully');
    } catch (e) {
      print('❌ Error creating notification: $e');
      throw Exception('Failed to create notification: ${e.toString()}');
    }
  }

  Future<void> updatePersonalInfo(
      String uid,
      LocationData location,
      PersonalInformation personalInfo,
      List<FamilyMember> householdMembers,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(uid)
          .update({
        'personalInfo': personalInfo.toMap(),
        'familyMembers': householdMembers.map((m) => m.toMap()).toList(),
        'fullName': personalInfo.fullName,
      });
    } catch (e) {
      throw Exception('Failed to update personal info: ${e.toString()}');
    }
  }
}

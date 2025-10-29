import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user in Firestore
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

  // Find user by email across all barangays
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

  // Get user by UID and location
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

  // Update email verification status (CHANGED FROM PHONE)
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
          .update({'emailVerified': verified}); // CHANGED
    } catch (e) {
      throw Exception('Failed to update email verification: ${e.toString()}');
    }
  }

  // Update user status (pending_review, approved, rejected, partial)
  Future<void> updateUserStatus(
      String uid,
      LocationData location,
      String status,
      ) async {
    try {
      final barangayDocId = location.toDocumentId();

      await _firestore
          .collection('barangays')
          .doc(barangayDocId)
          .collection('users')
          .doc(uid)
          .update({'status': status});
    } catch (e) {
      throw Exception('Failed to update user status: ${e.toString()}');
    }
  }

  // Check if user is admin
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

  // Get all pending users for a barangay (Admin function)
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

  // Seed barangay documents (for initial setup)
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
  // Add these methods to your existing FirestoreService class

// Get all users from a barangay
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

// Get users by status
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
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by status: ${e.toString()}');
    }
  }

// Approve user
  Future<void> approveUser(String uid, LocationData location) async {
    try {
      await updateUserStatus(uid, location, 'approved');
    } catch (e) {
      throw Exception('Failed to approve user: ${e.toString()}');
    }
  }

// Reject user
  Future<void> rejectUser(String uid, LocationData location) async {
    try {
      await updateUserStatus(uid, location, 'rejected');
    } catch (e) {
      throw Exception('Failed to reject user: ${e.toString()}');
    }
  }

// Get user statistics
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
        final status = doc.data()['status'] as String?;
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

// Search users by name or email
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

      // Filter locally (Firestore doesn't support complex text search)
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
}

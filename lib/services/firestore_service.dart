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

  // Update phone verification status
  Future<void> updatePhoneVerification(
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
          .update({'phoneVerified': verified});
    } catch (e) {
      throw Exception('Failed to update phone verification: ${e.toString()}');
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
      // Search across all barangays
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
}
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/family_member_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProfileProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String uid,
    required LocationData location,
    required String firstName,
    String? middleName,
    required String lastName,
    required DateTime dateOfBirth,
    required String placeOfBirth,
    required String houseNumber,
    required String streetName,
  }) async {
    try {
      setLoading(true);
      clearError();

      final updates = {
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'placeOfBirth': placeOfBirth,
        'houseNumber': houseNumber,
        'streetName': streetName,
        'profileCompleted': true,
      };

      await _firestoreService.updateUserProfile(uid, location, updates);
      await _firestoreService.checkAndUpdateVerificationStatus(uid, location);

      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> uploadProfilePicture(String uid, LocationData location) async {
    try {
      setLoading(true);
      clearError();

      final url = await _storageService.uploadProfilePicture(uid);
      if (url != null) {
        await _firestoreService.updateUserProfile(uid, location, {'profilePictureUrl': url});
        return true;
      }
      return false;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> addFamilyMember({
    required String uid,
    required LocationData location,
    required FamilyMember member,
  }) async {
    try {
      setLoading(true);
      clearError();

      final user = await _firestoreService.getUserByUid(uid, location);
      if (user == null) throw Exception('User not found');

      final updatedMembers = [...user.familyMembers, member];
      await _firestoreService.updateUserProfile(
        uid,
        location,
        {'familyMembers': updatedMembers.map((m) => m.toMap()).toList()},
      );

      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> removeFamilyMember({
    required String uid,
    required LocationData location,
    required String memberId,
  }) async {
    try {
      setLoading(true);
      clearError();

      final user = await _firestoreService.getUserByUid(uid, location);
      if (user == null) throw Exception('User not found');

      final updatedMembers = user.familyMembers.where((m) => m.id != memberId).toList();
      await _firestoreService.updateUserProfile(
        uid,
        location,
        {'familyMembers': updatedMembers.map((m) => m.toMap()).toList()},
      );

      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      setLoading(true);
      clearError();

      // TODO: Implement Firebase Auth password change
      // await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);

      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> resendEmailVerification() async {
    try {
      setLoading(true);
      clearError();

      // TODO: Implement email verification resend
      // This should call your email service to resend verification

      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }
}
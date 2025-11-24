import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  User? _firebaseUser;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      if (user != null && user.email != null) {
        loadUserData(user.email!);
      }
      notifyListeners();
    });
  }

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

  Future<void> updateUserProfilePicture() async {
    if (_currentUser == null || _currentUser!.uid.isEmpty) {
      throw Exception('No user is currently signed in.');
    }

    try {
      setLoading(true);
      clearError();

      final downloadUrl = await _storageService.uploadProfilePicture(_currentUser!.uid);

      if (downloadUrl == null) {
        setLoading(false);
        return;
      }

      await _firestoreService.updateUserProfilePicture(_currentUser!.uid, downloadUrl);

      _currentUser = _currentUser!.copyWith(profilePictureUrl: downloadUrl);

    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Sign Up with Email & Password
  Future<User?> signUpWithEmailPassword(
      String email,
      String password,
      ) async {
    try {
      setLoading(true);
      clearError();

      final userCredential = await _authService.signUpWithEmailPassword(
        email,
        password,
      );

      return userCredential.user;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  // Sign In with Email & Password
  Future<bool> signInWithEmailPassword(
      String email,
      String password,
      ) async {
    try {
      setLoading(true);
      clearError();

      final userCredential = await _authService.signInWithEmailPassword(
        email,
        password,
      );

      if (userCredential.user != null) {
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

  // Sign In with Google
  Future<bool> signInWithGoogle() async {
    try {
      setLoading(true);
      clearError();

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential?.user != null) {
        final userExists = await _firestoreService.findUserByEmail(userCredential!.user!.email!) != null;
        if (userExists) {
          return true;
        }
      }
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Create User in Firestore
  Future<bool> createUserInFirestore(UserModel user) async {
    try {
      setLoading(true);
      clearError();

      await _firestoreService.createUser(user);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Load User Data
  Future<void> loadUserData(String email) async {
    try {
      final userData = await _firestoreService.findUserByEmail(email);
      _currentUser = userData;
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to auto-load user data: $e");
    }
  }

  // Send Password Reset Email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      setLoading(true);
      clearError();
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Send Verification Code
  Future<String?> sendVerificationCode(String email) async {
    try {
      final code = await _authService.sendVerificationCode(email);
      return code;
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }

  // Verify Email Code
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      return await _authService.verifyEmailCode(email, code);
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  // Resend Code
  Future<String?> resendVerificationCode(String email) async {
    try {
      return await _authService.resendVerificationCode(email);
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _firebaseUser = null;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }
}

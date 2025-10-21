import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

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
        // Load user data from Firestore
        final userData = await _firestoreService.findUserByEmail(email);
        _currentUser = userData;
        notifyListeners();
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
        final userData = await _firestoreService.findUserByEmail(
          userCredential!.user!.email!,
        );
        _currentUser = userData;
        notifyListeners();
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
      setError(e.toString());
    }
  }

  // Update Phone Verification
  Future<void> updatePhoneVerification() async {
    if (_currentUser != null) {
      try {
        await _firestoreService.updatePhoneVerification(
          _currentUser!.uid,
          _currentUser!.location,
          true,
        );
        _currentUser = _currentUser!.copyWith(phoneVerified: true);
        notifyListeners();
      } catch (e) {
        setError(e.toString());
      }
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
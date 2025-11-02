import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'email_code_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EmailCodeService _emailCodeService = EmailCodeService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // -------------------------
  // Email & Password Sign Up
  // -------------------------
  Future<UserCredential> signUpWithEmailPassword(
      String email,
      String password,
      ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // -------------------------
  // Email & Password Sign In
  // -------------------------
  Future<UserCredential> signInWithEmailPassword(
      String email,
      String password,
      ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // -------------------------
  // Google Sign In - CORRECTED FOR v7.2.0
  // -------------------------
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final String? webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: webClientId, // optional for web; safe to include
        scopes: ['email', 'profile'],
      );

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      // Obtain authentication details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Sign in to Firebase
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e, st) {
      print('Google Sign-In failed: $e\n$st');
      throw Exception('Google Sign-In failed');
    }
  }



  // -------------------------
  // Send verification code via email
  // -------------------------
  Future<String> sendVerificationCode(String email) async {
    try {
      final code = await _emailCodeService.storeAndSendVerificationCode(email);
      return code;
    } catch (e) {
      throw Exception('Failed to send verification code: ${e.toString()}');
    }
  }

  // -------------------------
  // Verify the email code
  // -------------------------
  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      return await _emailCodeService.verifyCode(email, code);
    } catch (e) {
      throw Exception('Failed to verify code: ${e.toString()}');
    }
  }

  // -------------------------
  // Resend verification code
  // -------------------------
  Future<String> resendVerificationCode(String email) async {
    try {
      return await _emailCodeService.resendCode(email);
    } catch (e) {
      throw Exception('Failed to resend code: ${e.toString()}');
    }
  }

  // -------------------------
  // Password reset
  // -------------------------
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // -------------------------
  // Sign out
  // -------------------------
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      await _auth.signOut();
    }
  }

  // -------------------------
  // Exception handler
  // -------------------------
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'An error occurred: ${e.message ?? e.code}';
    }
  }
}
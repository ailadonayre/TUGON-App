import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(); // ✅ Updated constructor

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // -----------------------------------------------------------
  // EMAIL & PASSWORD SIGN UP
  // -----------------------------------------------------------
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

  // -----------------------------------------------------------
  // EMAIL & PASSWORD SIGN IN
  // -----------------------------------------------------------
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

  // -----------------------------------------------------------
  // GOOGLE SIGN IN
  // -----------------------------------------------------------
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      // Get Google authentication details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // -----------------------------------------------------------
  // PHONE AUTHENTICATION - SEND VERIFICATION CODE
  // -----------------------------------------------------------
  Future<String> verifyPhoneNumber(
      String phoneNumber,
      Function(String verificationId) codeSent,
      Function(String error) verificationFailed,
      ) async {
    String verificationIdResult = '';

    await _auth.verifyPhoneNumber(
      phoneNumber: '+63${phoneNumber.substring(1)}', // Convert 09XX → +639XX
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(_handleAuthException(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationIdResult = verificationId;
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationIdResult = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );

    return verificationIdResult;
  }

  // -----------------------------------------------------------
  // VERIFY SMS CODE
  // -----------------------------------------------------------
  Future<UserCredential> verifyPhoneCode(
      String verificationId,
      String smsCode,
      ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // -----------------------------------------------------------
  // LINK PHONE NUMBER TO EXISTING USER
  // -----------------------------------------------------------
  Future<void> linkPhoneCredential(
      String verificationId,
      String smsCode,
      ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await currentUser?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // -----------------------------------------------------------
  // SEND EMAIL VERIFICATION
  // -----------------------------------------------------------
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: ${e.toString()}');
    }
  }

  // -----------------------------------------------------------
  // PASSWORD RESET
  // -----------------------------------------------------------
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // -----------------------------------------------------------
  // SIGN OUT
  // -----------------------------------------------------------
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.disconnect(), // ✅ use disconnect() for latest API
    ]);
  }

  // -----------------------------------------------------------
  // EXCEPTION HANDLER
  // -----------------------------------------------------------
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
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification session has expired.';
      default:
        return 'An error occurred: ${e.message ?? e.code}';
    }
  }
}
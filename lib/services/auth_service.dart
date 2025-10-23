import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Use the singleton instance for google_sign_in v7+
  // final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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
  // Google Sign In (v7+ compatible)
  // -------------------------
  ///
  /// This uses `GoogleSignIn.instance.authenticate()` (interactive) and
  /// consumes the returned ID token to build a Firebase credential.
  /// Note: `accessToken` is not always provided by the new API unless you
  /// explicitly request authorization/scopes; the ID token is sufficient
  /// for Firebase Auth in most setups.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Start interactive authentication. Provide common OIDC hints so an idToken is returned.
      final GoogleSignInAccount googleUser =
      await GoogleSignIn.instance.authenticate(
        scopeHint: const <String>['openid', 'email', 'profile'],
      );

      // If authenticate() returns, we should have an account
      // if (googleUser == null) return null;

      // Obtain authentication tokens (in v7 this currently provides idToken)
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      // accessToken may be null in v7 unless you request authorization via
      // the authorizationClient flow; Firebase can accept an idToken alone.
      final String? accessToken = null;

      if (idToken == null) {
        throw Exception(
            'Google sign-in succeeded but no ID token was returned. Check your Google configuration (OAuth client IDs / serverClientId, and consent).');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      return await _auth.signInWithCredential(credential);
    } on Exception catch (e) {
      // bubble up a readable error
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  // -------------------------
  // Phone: send verification code
  // -------------------------
  Future<String> verifyPhoneNumber(
      String phoneNumber,
      Function(String verificationId) codeSent,
      Function(String error) verificationFailed,
      ) async {
    String verificationIdResult = '';

    await _auth.verifyPhoneNumber(
      phoneNumber: '+63${phoneNumber.substring(1)}', // Convert 09XX -> +639XX
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android)
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

  // -------------------------
  // Verify SMS code
  // -------------------------
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

  // -------------------------
  // Link phone credential to existing user
  // -------------------------
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

  // -------------------------
  // Email verification
  // -------------------------
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: ${e.toString()}');
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
      await Future.wait([
        _auth.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);
    } catch (e) {
      // fallback: ensure firebase sign-out happened
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
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification session has expired.';
      default:
        return 'An error occurred: ${e.message ?? e.code}';
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';

/// Email/password auth via Firebase, with a safe fallback.
///
/// If Firebase isn't configured yet (no google-services.json), [firebaseReady]
/// stays false and the app falls back to a demo login so it still runs. Once
/// you complete FIREBASE_SETUP.md, real accounts + email verification activate.
class AuthService {
  static bool firebaseReady = false;
  bool _mockSignedIn = false;

  // ---- state ---------------------------------------------------------------
  bool get isSignedIn =>
      firebaseReady ? FirebaseAuth.instance.currentUser != null : _mockSignedIn;

  String? get email =>
      firebaseReady ? FirebaseAuth.instance.currentUser?.email : 'demo@curiolock.app';

  /// Whether the user's email is verified (always true in demo mode).
  bool get isEmailVerified =>
      firebaseReady ? (FirebaseAuth.instance.currentUser?.emailVerified ?? false) : true;

  // ---- actions (return null on success, else an error message) -------------
  Future<String?> signUp(String email, String password) async {
    if (!firebaseReady) { _mockSignedIn = true; return null; }
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email.trim(), password: password);
      await cred.user?.sendEmailVerification(); // sends the verification email
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e);
    } catch (e) {
      return 'Something went wrong. Try again.';
    }
  }

  Future<String?> signIn(String email, String password) async {
    if (!firebaseReady) { _mockSignedIn = true; return null; }
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e);
    } catch (e) {
      return 'Something went wrong. Try again.';
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    if (!firebaseReady) return 'Set up Firebase to enable password reset (see FIREBASE_SETUP.md).';
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e);
    }
  }

  Future<void> resendVerification() async {
    if (firebaseReady) await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  /// Re-checks with the server whether the email is now verified.
  Future<bool> refreshVerified() async {
    if (!firebaseReady) return true;
    await FirebaseAuth.instance.currentUser?.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    _mockSignedIn = false;
    if (firebaseReady) await FirebaseAuth.instance.signOut();
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'That email already has an account — try signing in.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Password is too weak (use at least 6 characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'too-many-requests':
        return 'Too many attempts — wait a moment and retry.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}

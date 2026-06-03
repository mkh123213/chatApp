// REUSABLE SERVICE: Firebase Auth + Google Sign-In wrapper.
// REQUIRES: firebase_auth, google_sign_in packages in pubspec.yaml
// CHANGE: Add/remove auth methods (e.g., Apple Sign-In, phone auth) as needed.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthService {
  User? get currentUser;

  Stream<User?> get authStateChanges;

  Future<void> initializeGoogleSignIn();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> signInWithGoogle();

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> sendEmailVerification();

  Future<void> updateUserName({
    required String name,
  });
  Future<void> updateUserPasswordWithOldPassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<void> updateUserEmail({
    required String email,
  });

  Future<void> updateUserPassword({
    required String password,
  });

  Future<void> deleteAccount();

  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  bool _isGoogleSignInInitialized = false;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<void> initializeGoogleSignIn() async {
    if (_isGoogleSignInInitialized) return;

    await _googleSignIn.initialize();

    _isGoogleSignInInitialized = true;
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (_) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (_) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      await initializeGoogleSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException('Google sign in was cancelled.');
      }

      throw AuthException('Google sign in failed. Please try again.');
    } catch (_) {
      throw AuthException('Google sign in failed. Please try again.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (_) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw AuthException('No user is currently signed in.');
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> updateUserName({
    required String name,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw AuthException('No user is currently signed in.');
      }

      await user.updateDisplayName(name.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> updateUserEmail({
    required String email,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw AuthException('No user is currently signed in.');
      }

      await user.verifyBeforeUpdateEmail(email.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> updateUserPassword({
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw AuthException('No user is currently signed in.');
      }

      await user.updatePassword(password);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> updateUserPasswordWithOldPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw AuthException('No user is currently signed in.');
      }

      final email = user.email;

      if (email == null || email.isEmpty) {
        throw AuthException('No email found for this user.');
      }

      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw AuthException('No user is currently signed in.');
      }

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await initializeGoogleSignIn();

      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw AuthException('Failed to sign out. Please try again.');
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';

      case 'user-disabled':
        return 'This user account has been disabled.';

      case 'user-not-found':
        return 'No user found with this email.';

      case 'wrong-password':
        return 'Incorrect password. Please try again.';

      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'email-already-in-use':
        return 'This email is already in use.';

      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';

      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'requires-recent-login':
        return 'Please sign in again before doing this operation.';

      case 'too-many-requests':
        return 'Too many requests. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

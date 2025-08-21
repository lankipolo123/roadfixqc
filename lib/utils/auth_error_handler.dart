import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  static const Map<String, String> _firebaseErrorMessages = {
    'weak-password': 'Password is too weak',
    'email-already-in-use': 'Account already exists for this email',
    'invalid-email': 'Invalid email address',
    'user-not-found': 'No account found for this email',
    'wrong-password': 'Incorrect password',
    'user-disabled': 'Account has been disabled',
    'too-many-requests': 'Too many attempts. Try again later',
    'invalid-credential': 'Invalid email or password',
  };

  static String handleFirebaseAuthException(FirebaseAuthException e) {
    return _firebaseErrorMessages[e.code] ??
        e.message ??
        'Authentication error';
  }

  static String handleGenericError(dynamic error, String operation) {
    return '$operation failed: ${error.toString()}';
  }
}

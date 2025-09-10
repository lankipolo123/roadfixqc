// lib/services/auth_service.dart (UPDATED WITH TOTP SUPPORT - USING YOUR AUTHRESULT)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:roadfix/constant/auth_constant.dart';
import 'package:roadfix/models/user_model.dart';
import 'package:roadfix/services/firestore_service.dart';
import 'package:roadfix/utils/auth_result.dart';
import 'package:roadfix/utils/auth_error_handler.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<String?> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return AuthConstants.noUserSignedIn;
      if (user.emailVerified) return AuthConstants.emailAlreadyVerified;

      await user.sendEmailVerification();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return AuthErrorHandler.handleFirebaseAuthException(e);
    } catch (e) {
      return AuthErrorHandler.handleGenericError(e, 'Send verification email');
    }
  }

  Future<String?> checkEmailVerificationAndActivate() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return AuthConstants.noUserSignedIn;

      await user.reload();

      if (user.emailVerified) {
        await _firestoreService.updateUserStatus(user.uid, true);
        return null; // Success
      } else {
        return AuthConstants.emailNotVerified;
      }
    } catch (e) {
      return AuthErrorHandler.handleGenericError(
        e,
        'Check verification status',
      );
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required UserModel userData,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _createUserInFirestore(credential.user!, userData);
        await _sendEmailVerification(credential.user!);
        return null; // Success
      }
      return AuthConstants.signupFailed;
    } on FirebaseAuthException catch (e) {
      return AuthErrorHandler.handleFirebaseAuthException(e);
    } catch (e) {
      return AuthErrorHandler.handleGenericError(e, 'Signup');
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await _handleSuccessfulAuth(credential.user!);
      }

      return AuthResult.createError(AuthConstants.signinFailed).toMap();
    } on FirebaseAuthException catch (e) {
      return AuthResult.createError(
        AuthErrorHandler.handleFirebaseAuthException(e),
      ).toMap();
    } catch (e) {
      return AuthResult.createError(
        AuthErrorHandler.handleGenericError(e, 'Login'),
      ).toMap();
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.createError(
          AuthConstants.googleSigninCancelled,
        ).toMap();
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        await _handleGoogleUserCreation(userCredential.user!, googleUser);
        return await _handleSuccessfulAuth(userCredential.user!);
      }

      return AuthResult.createError(AuthConstants.googleSigninFailed).toMap();
    } catch (e) {
      return AuthResult.createError(
        AuthErrorHandler.handleGenericError(e, 'Google Sign-In'),
      ).toMap();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthErrorHandler.handleFirebaseAuthException(e);
    } catch (e) {
      return AuthErrorHandler.handleGenericError(e, 'Password reset');
    }
  }

  // Change Email Method for Firebase Auth 6.0.1
  Future<String?> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "No user signed in";

      if (user.email == null) return "Current user has no email";

      // 1. Reauthenticate first (required by Firebase)
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Use verifyBeforeUpdateEmail (Firebase Auth 6.0.1 method)
      await user.verifyBeforeUpdateEmail(newEmail);

      // 3. Update email in Firestore
      await _firestoreService.updateUser(user.uid, {'email': newEmail});

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return AuthErrorHandler.handleFirebaseAuthException(e);
    } catch (e) {
      return AuthErrorHandler.handleGenericError(e, 'Change email');
    }
  }

  // Change Password Method
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "No user signed in";

      if (user.email == null) return "Current user has no email";

      // 1. Reauthenticate first (required by Firebase)
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Update password in Firebase Auth
      await user.updatePassword(newPassword);

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return AuthErrorHandler.handleFirebaseAuthException(e);
    } catch (e) {
      return AuthErrorHandler.handleGenericError(e, 'Change password');
    }
  }

  // Check if user has TOTP enabled
  Future<bool> requiresTotpVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      return await _firestoreService.isTotpEnabled(user.uid);
    } catch (e) {
      return false; // If error occurs, skip TOTP
    }
  }

  // Private helper methods
  Future<void> _createUserInFirestore(User user, UserModel userData) async {
    UserModel newUser = userData.copyWith(uid: user.uid, isActive: false);

    try {
      await _firestoreService.createUser(newUser);
    } catch (firestoreError) {
      await user.delete(); // Clean up if Firestore fails
      rethrow;
    }
  }

  Future<void> _sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      // Email verification failure is not critical
    }
  }

  Future<Map<String, dynamic>> _handleSuccessfulAuth(User user) async {
    // Check email verification
    if (!user.emailVerified) {
      return AuthResult.createSuccessWithEmailVerification(
        message: AuthConstants.emailVerificationRequired,
      ).toMap();
    }

    // Check if TOTP is required
    final requiresTotp = await requiresTotpVerification();
    if (requiresTotp) {
      return AuthResult.createSuccessWith2FA(
        phoneNumber: '', // Not used for TOTP but required by your method
        message: 'TOTP verification required',
      ).toMap();
    }

    return AuthResult.createSuccess(
      message: AuthConstants.signinSuccessful,
    ).toMap();
  }

  Future<void> _handleGoogleUserCreation(
    User user,
    GoogleSignInAccount googleUser,
  ) async {
    bool userExists = await _firestoreService.userExists(user.uid);

    if (!userExists) {
      final displayName = googleUser.displayName ?? '';
      final nameParts = displayName.split(' ');

      UserModel newUser = UserModel(
        fname: nameParts.isNotEmpty ? nameParts.first : 'User',
        lname: nameParts.length > 1 ? nameParts.last : '',
        mi: '',
        email: googleUser.email,
        contactNumber: '',
        address: '',
        isActive: true, // Google users are automatically active
      );

      await _firestoreService.createUser(newUser.copyWith(uid: user.uid));
    }
  }
}

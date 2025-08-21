import 'package:flutter/material.dart';
import 'package:roadfix/services/auth_service.dart';
import 'package:roadfix/utils/snackbar_utils.dart';
import 'package:roadfix/widgets/common_widgets/big_button.dart';
import 'package:roadfix/layouts/auth_scaffold.dart';
import 'package:roadfix/widgets/auth_widgets/auth_redirect_button.dart';
import 'package:roadfix/screens/module_screens/navigation_screen.dart';
import 'package:roadfix/screens/auth_screens/login_screen.dart';
import 'package:roadfix/widgets/themes.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isCheckingVerification = false;
  bool _isResendingEmail = false;

  String get userEmail => _authService.currentUser?.email ?? 'your email';

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isCheckingVerification = true;
    });

    try {
      final error = await _authService.checkEmailVerificationAndActivate();

      if (mounted) {
        if (error == null) {
          // Success! Email is verified and account is activated
          SnackbarUtils.showSuccess(
            context,
            'Email verified successfully! Welcome to RoadFix! 🎉',
          );

          // Navigate to main app
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NavigationScreen()),
          );
        } else {
          // Still not verified
          SnackbarUtils.showError(context, error);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to check verification status');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResendingEmail = true;
    });

    try {
      final error = await _authService.resendEmailVerification();

      if (mounted) {
        if (error == null) {
          SnackbarUtils.showSuccess(
            context,
            'Verification email sent! Please check your inbox.',
          );
        } else {
          SnackbarUtils.showError(context, error);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to resend verification email');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResendingEmail = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to sign out');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      topPadding: 30,
      topContent: Column(
        children: [
          // Email verification icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.email_outlined, size: 64, color: primary),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Verify Your Email',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: secondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            'We sent a verification link to',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: altSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          // User email
          Text(
            userEmail,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: primary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusWarning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusWarning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: statusWarning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Check your email and click the verification link, then tap "I\'ve Verified" below.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: secondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      children: [
        const SizedBox(height: 24),

        // Check verification button
        BigButton(
          text: _isCheckingVerification
              ? "Checking..."
              : "I've Verified My Email",
          onPressed: _isCheckingVerification ? null : _checkEmailVerification,
        ),

        const SizedBox(height: 16),

        // Resend email button
        OutlinedButton(
          onPressed: _isResendingEmail ? null : _resendVerificationEmail,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            side: const BorderSide(color: primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 54),
          ),
          child: Text(
            _isResendingEmail ? "Sending..." : "Resend Verification Email",
            style: const TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Sign out redirect button
        AuthRedirectTextButton(
          prompt: "Want to use a different account?",
          action: "Sign Out",
          onPressed: _signOut,
        ),

        const SizedBox(height: 16),

        // Help text
        Text(
          'Didn\'t receive the email? Check your spam folder or try resending.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: altSecondary),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

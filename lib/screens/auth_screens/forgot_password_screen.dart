import 'package:flutter/material.dart';
import 'package:roadfix/layouts/auth_scaffold.dart';
import 'package:roadfix/widgets/auth_widgets/custom_textfield.dart';
import 'package:roadfix/widgets/common_widgets/big_button.dart';
import 'package:roadfix/widgets/auth_widgets/auth_redirect_button.dart';
import 'package:roadfix/screens/auth_screens/login_screen.dart';
import 'package:roadfix/utils/focus_helper.dart';
import 'package:roadfix/services/auth_service.dart';
import 'package:roadfix/utils/snackbar_utils.dart';
import 'package:roadfix/widgets/themes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Please enter your email address');
      }
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Please enter a valid email address');
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final error = await _authService.resetPassword(email);

      if (mounted) {
        if (error != null) {
          SnackbarUtils.showError(context, error);
        } else {
          setState(() => _emailSent = true);
          SnackbarUtils.showSuccess(
            context,
            'Password reset email sent! Check your inbox.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to send password reset email');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendEmail() async {
    await _handleResetPassword();
  }

  void _goBackToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      topPadding: 30,
      topContent: Column(
        children: [
          // Lock icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: statusWarning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_outlined,
              size: 64,
              color: primary,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            _emailSent ? 'Check Your Email' : 'Reset Password',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: secondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            _emailSent
                ? 'We sent a password reset link to ${_emailController.text.trim()}'
                : 'Enter your email address and we\'ll send you a link to reset your password.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: altSecondary),
            textAlign: TextAlign.center,
          ),

          if (_emailSent) ...[
            const SizedBox(height: 20),

            // Instructions after email sent
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Click the link in your email to create a new password. You can then sign in with your new password.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: secondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      children: [
        if (!_emailSent) ...[
          const SizedBox(height: 16),

          // Email input field
          CustomTextField(
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            focusNode: _emailFocus,
            textInputAction: TextInputAction.done,
            onNext: () => FocusHelper.next(context, null),
          ),

          const SizedBox(height: 24),

          // Send reset email button
          BigButton(
            text: _isLoading ? "Sending..." : "Send Reset Email",
            onPressed: _isLoading ? null : _handleResetPassword,
          ),
        ] else ...[
          const SizedBox(height: 24),

          // Back to login button
          BigButton(text: "Back to Sign In", onPressed: _goBackToLogin),

          const SizedBox(height: 16),

          // Resend email button
          OutlinedButton(
            onPressed: _isLoading ? null : _handleResendEmail,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              side: const BorderSide(color: statusWarning),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 54),
            ),
            child: Text(
              _isLoading ? "Sending..." : "Resend Email",
              style: const TextStyle(
                color: statusWarning,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Back to login redirect button
        AuthRedirectTextButton(
          prompt: "Remember your password?",
          action: "Sign In",
          onPressed: _goBackToLogin,
        ),

        if (_emailSent) ...[
          const SizedBox(height: 16),

          // Help text
          Text(
            'Didn\'t receive the email? Check your spam folder or try resending.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: altSecondary),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

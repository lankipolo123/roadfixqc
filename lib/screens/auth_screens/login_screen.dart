import 'package:flutter/material.dart';
import 'package:roadfix/layouts/auth_scaffold.dart';
import 'package:roadfix/widgets/auth_widgets/login_top_content.dart';
import 'package:roadfix/widgets/auth_widgets/custom_textfield.dart';
import 'package:roadfix/widgets/common_widgets/big_button.dart';
import 'package:roadfix/widgets/auth_widgets/social_divider.dart';
import 'package:roadfix/widgets/auth_widgets/google_signin_button.dart';
import 'package:roadfix/widgets/auth_widgets/auth_redirect_button.dart';
import 'package:roadfix/screens/module_screens/navigation_screen.dart';
import 'package:roadfix/screens/auth_screens/signup_screen.dart';
import 'package:roadfix/screens/auth_screens/email_verification_screen.dart';
import 'package:roadfix/screens/auth_screens/forgot_password_screen.dart';
import 'package:roadfix/utils/focus_helper.dart';
import 'package:roadfix/services/auth_service.dart';
import 'package:roadfix/utils/snackbar_utils.dart';
import 'package:roadfix/widgets/themes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Please enter your email');
      }
      return;
    }

    if (password.isEmpty) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Please enter your password');
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (mounted) {
        if (result['success'] != true) {
          SnackbarUtils.showError(context, result['message'] ?? 'Login failed');
        } else {
          // Check email verification status after successful login
          final user = _authService.currentUser;
          if (user != null && !user.emailVerified) {
            // User logged in but email not verified - go to verification screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const EmailVerificationScreen(),
              ),
            );
          } else {
            // User verified - go to main app
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NavigationScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithGoogle();

      if (mounted) {
        if (result['success'] != true) {
          SnackbarUtils.showError(
            context,
            result['message'] ?? 'Google Sign-In failed',
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NavigationScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Google Sign-In failed');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      topPadding: 30,
      topContent: const LoginTopContent(),
      children: [
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
          focusNode: _emailFocus,
          onNext: () => FocusHelper.next(context, _passwordFocus),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Password',
          obscureText: true,
          icon: Icons.lock_outline,
          controller: _passwordController,
          focusNode: _passwordFocus,
          textInputAction: TextInputAction.done,
          onNext: () => FocusHelper.next(context, null),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handleForgotPassword,
            child: Text(
              'Forgot Password?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: statusDanger,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        BigButton(
          text: _isLoading ? "Signing In..." : "Log In",
          onPressed: _isLoading ? null : _handleLogin,
        ),
        const SizedBox(height: 16),
        const SocialDivider(),
        const SizedBox(height: 12),
        GoogleSignInButton(onPressed: _isLoading ? null : _handleGoogleSignIn),
        const SizedBox(height: 24),
        AuthRedirectTextButton(
          prompt: "Don't have an account?",
          action: "Sign Up",
          onPressed: () {
            if (!_isLoading) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()),
              );
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

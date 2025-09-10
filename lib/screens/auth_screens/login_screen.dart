// lib/screens/auth_screens/login_screen.dart (UPDATED WITH TOTP SUPPORT - USING YOUR AUTHRESULT)
import 'package:flutter/material.dart';
import 'package:roadfix/layouts/auth_scaffold.dart';
import 'package:roadfix/widgets/auth_widgets/login_top_content.dart';
import 'package:roadfix/widgets/auth_widgets/custom_textfield.dart';
import 'package:roadfix/widgets/common_widgets/big_button.dart';
import 'package:roadfix/widgets/auth_widgets/social_divider.dart';
import 'package:roadfix/widgets/auth_widgets/google_signin_button.dart';
import 'package:roadfix/widgets/auth_widgets/auth_redirect_button.dart';
import 'package:roadfix/widgets/dialog_widgets/totp_verfication_dialog.dart';
import 'package:roadfix/screens/module_screens/navigation_screen.dart';
import 'package:roadfix/screens/auth_screens/signup_screen.dart';
import 'package:roadfix/screens/auth_screens/email_verification_screen.dart';
import 'package:roadfix/screens/auth_screens/forgot_password_screen.dart';
import 'package:roadfix/utils/focus_helper.dart';
import 'package:roadfix/services/auth_service.dart';
import 'package:roadfix/services/connectivity_service.dart';
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
  bool _isInitialLoading = true;
  bool _hasConnection = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      await Future.wait([
        ConnectivityService.hasInternetConnection(),
        Future.delayed(const Duration(milliseconds: 1500)),
      ]).then((results) {
        _hasConnection = results[0] as bool;
      });

      if (mounted) {
        setState(() => _isInitialLoading = false);

        if (!_hasConnection) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              SnackbarUtils.showError(
                context,
                'No internet connection. Please check your network and try again.',
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasConnection = false;
          _isInitialLoading = false;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            SnackbarUtils.showError(
              context,
              'Connection error. Please try again.',
            );
          }
        });
      }
    }
  }

  Future<bool> _checkConnectivityBeforeAction() async {
    final hasConnection = await ConnectivityService.hasInternetConnection();

    if (!hasConnection && mounted) {
      SnackbarUtils.showError(
        context,
        'No internet connection. Please check your network.',
      );
      return false;
    }

    return hasConnection;
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

    if (!await _checkConnectivityBeforeAction()) return;

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
          // Check what type of success we got
          if (result['requiresEmailVerification'] == true) {
            // Email verification required
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const EmailVerificationScreen(),
              ),
            );
          } else if (result['requires2FA'] == true) {
            // TOTP verification required
            await _handleTotpVerification();
          } else {
            // Complete success - go to main app
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

  Future<void> _handleTotpVerification() async {
    try {
      final totpResult = await TotpVerificationDialog.show(context);

      if (totpResult == true && mounted) {
        // TOTP verification successful - proceed to main app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NavigationScreen()),
        );
      } else if (totpResult == false && mounted) {
        // User cancelled TOTP verification - sign them out for security
        await _authService.signOut();
        SnackbarUtils.showError(
          context,
          'Two-factor authentication is required. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        // TOTP verification failed - sign out for security
        await _authService.signOut();
        SnackbarUtils.showError(
          context,
          'Authentication failed. Please try again.',
        );
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
    if (!await _checkConnectivityBeforeAction()) return;

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
          // Check if Google user needs TOTP (unlikely but possible)
          if (result['requires2FA'] == true) {
            await _handleTotpVerification();
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NavigationScreen()),
            );
          }
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

  Widget _buildLoginForm() {
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

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const AuthScaffold(
        topPadding: 30,
        topContent: LoginTopContent(),
        children: [
          SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 24),
                Text(
                  'Checking connection...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return _buildLoginForm();
  }
}

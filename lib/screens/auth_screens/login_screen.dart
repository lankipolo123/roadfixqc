// lib/screens/auth_screens/login_screen.dart (UPDATED WITH CONNECTIVITY CACHE)
import 'package:flutter/material.dart';
import 'package:roadfix/layouts/auth_scaffold.dart';
import 'package:roadfix/widgets/auth_widgets/login_top_content.dart';
import 'package:roadfix/widgets/auth_widgets/custom_textfield.dart';
import 'package:roadfix/widgets/common_widgets/big_button.dart';
import 'package:roadfix/widgets/auth_widgets/auth_redirect_button.dart';
import 'package:roadfix/widgets/dialog_widgets/totp_verfication_dialog.dart';
import 'package:roadfix/screens/module_screens/navigation_screen.dart';
import 'package:roadfix/screens/auth_screens/signup_screen.dart';
import 'package:roadfix/screens/auth_screens/email_verification_screen.dart';
import 'package:roadfix/screens/auth_screens/forgot_password_screen.dart';
import 'package:roadfix/utils/focus_helper.dart';
import 'package:roadfix/services/auth_service.dart';
import 'package:roadfix/services/connectivity_service.dart';
import 'package:roadfix/utils/connectivity_cache.dart';
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
    // Check if we should skip the initial check (already done this session)
    if (ConnectivityCache.shouldSkipInitialCheck()) {
      setState(() {
        _isInitialLoading = false;
        _hasConnection = ConnectivityCache.hasRecentConnection();
      });
      return;
    }

    try {
      await Future.wait([
        ConnectivityService.hasInternetConnection(),
        Future.delayed(const Duration(milliseconds: 1500)),
      ]).then((results) {
        _hasConnection = results[0] as bool;
      });

      if (mounted) {
        // Cache the result
        ConnectivityCache.setConnectionStatus(_hasConnection);

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
        ConnectivityCache.setConnectionStatus(false);
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
    // First check cache
    final cachedStatus = ConnectivityCache.getCachedConnectionStatus();
    if (cachedStatus == true) {
      return true; // We have recent confirmed connection
    }

    // If no cache or expired, do a quick check
    final hasConnection = await ConnectivityService.hasInternetConnection();
    ConnectivityCache.setConnectionStatus(hasConnection);

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

      debugPrint('🔍 Auth result: $result');
      debugPrint('🔍 success: ${result['success']}');
      debugPrint('🔍 requires2FA: ${result['requires2FA']}');
      debugPrint(
        '🔍 requiresEmailVerification: ${result['requiresEmailVerification']}',
      );

      if (!mounted) return;

      if (result['success'] != true) {
        SnackbarUtils.showError(context, result['message'] ?? 'Login failed');
      } else {
        // Check what type of success we got
        if (result['requiresEmailVerification'] == true) {
          debugPrint('🔍 Navigating to email verification');
          _navigateToEmailVerification();
        } else if (result['requires2FA'] == true) {
          debugPrint('🔍 TOTP required - showing verification dialog');
          await _handleTotpVerification();
        } else {
          debugPrint('🔍 Complete success - navigating to main app');
          _navigateToMainApp();
        }
      }
    } catch (e) {
      debugPrint('🔍 Login error: $e');
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
    if (!mounted) return;

    try {
      debugPrint('🔍 Showing TOTP dialog');
      final totpResult = await TotpVerificationDialog.show(context);
      debugPrint('🔍 TOTP result: $totpResult');

      if (!mounted) return;

      if (totpResult == true) {
        debugPrint('🔍 TOTP successful - navigating to main app');
        _navigateToMainApp();
      } else if (totpResult == false) {
        debugPrint('🔍 TOTP cancelled - signing out');
        await _authService.signOut();
        if (mounted) {
          SnackbarUtils.showError(
            context,
            'Two-factor authentication is required. Please try again.',
          );
        }
      }
    } catch (e) {
      debugPrint('🔍 TOTP error: $e');
      await _authService.signOut();
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Authentication failed. Please try again.',
        );
      }
    }
  }

  void _navigateToMainApp() {
    if (mounted) {
      debugPrint('🔍 Navigating to NavigationScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavigationScreen()),
      );
    }
  }

  void _navigateToEmailVerification() {
    if (mounted) {
      debugPrint('🔍 Navigating to EmailVerificationScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
      );
    }
  }

  void _handleForgotPassword() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
      );
    }
  }

  void _handleSignUpNavigation() {
    if (!_isLoading && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      );
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
        const SizedBox(height: 24),
        AuthRedirectTextButton(
          prompt: "Don't have an account?",
          action: "Sign Up",
          onPressed: _handleSignUpNavigation,
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
          SizedBox(height: 80),
          Center(
            // ignore: prefer_const_constructors
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
                SizedBox(height: 20),
                Text(
                  'Checking connection...',
                  style: TextStyle(color: altSecondary, fontSize: 14),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      );
    }

    return _buildLoginForm();
  }
}

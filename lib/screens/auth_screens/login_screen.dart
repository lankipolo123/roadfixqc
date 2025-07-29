import 'package:flutter/material.dart';
import 'package:roadfix/widgets/auth_widgets/login_top_content.dart';
import 'package:roadfix/widgets/auth_widgets/custom_textfield.dart';
import 'package:roadfix/widgets/big_button.dart';
import 'package:roadfix/widgets/auth_widgets/forgot_button.dart';
import 'package:roadfix/widgets/auth_widgets/social_divider.dart';
import 'package:roadfix/widgets/auth_widgets/google_signin_button.dart';
import 'package:roadfix/widgets/auth_widgets/auth_redirect_button.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/screens/module_screens/navigation_screen.dart';
import 'package:roadfix/screens/auth_screens/signup_screen.dart';
import 'package:roadfix/helpers/focus_helper.dart';
import 'package:roadfix/widgets/diagonal_stripes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: inputFill,
      body: Stack(
        children: [
          // 🔳 Top & Bottom Diagonal Stripes
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(height: 15, child: DiagonalStripes()),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(height: 15, child: DiagonalStripes()),
          ),

          // 🟨 Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginTopContent(),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: viewInsets + 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 12),

                                // 🔹 Email Field
                                CustomTextField(
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  focusNode: _emailFocus,
                                  onNext: () =>
                                      FocusHelper.next(context, _passwordFocus),
                                ),
                                const SizedBox(height: 8),

                                // 🔹 Password Field
                                CustomTextField(
                                  label: 'Password',
                                  obscureText: true,
                                  icon: Icons.lock_outline,
                                  focusNode: _passwordFocus,
                                  textInputAction: TextInputAction.done,
                                  onNext: () => FocusHelper.next(context, null),
                                ),
                                const SizedBox(height: 4),

                                const ForgotPasswordButton(),
                                const SizedBox(height: 12),

                                // 🔹 Log In Button
                                BigButton(
                                  text: "Log In",
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const NavigationScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),

                                const SocialDivider(),
                                const SizedBox(height: 8),
                                const GoogleSignInButton(),
                                const SizedBox(height: 24),

                                // 🔹 Redirect to Sign Up
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AuthRedirectTextButton(
                                    prompt: "Don't have an account?",
                                    action: "Sign Up",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SignUpScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:roadfix/screens/auth_screens/login_screen.dart';
import 'package:roadfix/widgets/auth_widgets/signup_top_content.dart';
import 'package:roadfix/widgets/auth_widgets/custom_textfield.dart';
import 'package:roadfix/widgets/big_button.dart';
import 'package:roadfix/widgets/auth_widgets/auth_redirect_button.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/helpers/focus_helper.dart';
import 'package:roadfix/widgets/diagonal_stripes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    fullNameFocus.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    addressFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: inputFill,
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          // ⬛ Diagonal stripes background at top and bottom
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

          // ⬜ Main content
          SafeArea(
            child: Column(
              children: [
                const SignupTopContent(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ListView(
                      padding: EdgeInsets.only(bottom: viewInsets + 24),
                      children: [
                        const SizedBox(height: 10),
                        CustomTextField(
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          focusNode: fullNameFocus,
                          onNext: () => FocusHelper.next(context, emailFocus),
                        ),
                        CustomTextField(
                          label: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email_outlined,
                          focusNode: emailFocus,
                          onNext: () => FocusHelper.next(context, phoneFocus),
                        ),
                        CustomTextField(
                          label: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone_outlined,
                          focusNode: phoneFocus,
                          onNext: () => FocusHelper.next(context, addressFocus),
                        ),
                        CustomTextField(
                          label: 'Address',
                          icon: Icons.home_outlined,
                          focusNode: addressFocus,
                          onNext: () =>
                              FocusHelper.next(context, passwordFocus),
                        ),
                        CustomTextField(
                          label: 'Password',
                          obscureText: true,
                          icon: Icons.lock_outline,
                          focusNode: passwordFocus,
                          textInputAction: TextInputAction.done,
                          onNext: () => FocusHelper.next(context, null),
                        ),
                        const SizedBox(height: 24),
                        BigButton(
                          text: "Sign Up",
                          onPressed: () {
                            // TODO: Handle sign-up logic
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthRedirectTextButton(
                          prompt: "Already have an account?",
                          action: "Sign In",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
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

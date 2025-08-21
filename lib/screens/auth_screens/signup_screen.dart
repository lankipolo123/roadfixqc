import 'package:flutter/material.dart';
import 'package:roadfix/widgets/auth_widgets/auth_name_row.dart';
import 'package:roadfix/layouts/auth_scaffold.dart';
import 'package:roadfix/widgets/auth_widgets/signup_top_content.dart';
import 'package:roadfix/widgets/auth_widgets/custom_textfield.dart';
import 'package:roadfix/widgets/common_widgets/big_button.dart';
import 'package:roadfix/widgets/auth_widgets/auth_redirect_button.dart';
import 'package:roadfix/screens/auth_screens/login_screen.dart';
import 'package:roadfix/utils/focus_helper.dart';
import 'package:roadfix/models/user_model.dart';
import 'package:roadfix/services/auth_service.dart';
import 'package:roadfix/utils/snackbar_utils.dart';
import 'package:roadfix/widgets/dialog_widgets/dialog_utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final miController = TextEditingController();
  final emailController = TextEditingController();
  final contactNumberController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();

  final fnameFocus = FocusNode();
  final lnameFocus = FocusNode();
  final miFocus = FocusNode();
  final emailFocus = FocusNode();
  final contactNumberFocus = FocusNode();
  final addressFocus = FocusNode();
  final passwordFocus = FocusNode();

  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    miController.dispose();
    emailController.dispose();
    contactNumberController.dispose();
    addressController.dispose();
    passwordController.dispose();

    fnameFocus.dispose();
    lnameFocus.dispose();
    miFocus.dispose();
    emailFocus.dispose();
    contactNumberFocus.dispose();
    addressFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  String? _validateFields() {
    final fname = fnameController.text.trim();
    final lname = lnameController.text.trim();
    final mi = miController.text.trim();
    final email = emailController.text.trim();
    final contact = contactNumberController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text;

    if (fname.isEmpty) {
      return 'First name is required';
    }
    if (fname.length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (lname.isEmpty) {
      return 'Last name is required';
    }
    if (lname.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    if (mi.isNotEmpty && mi.length != 1) {
      return 'Middle initial must be a single character';
    }
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    if (contact.isEmpty) {
      return 'Contact number is required';
    }
    if (address.isEmpty) {
      return 'Address is required';
    }
    if (address.length < 10) {
      return 'Please enter a complete address';
    }
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(password)) {
      return 'Password must contain both letters and numbers';
    }

    final contactDigits = contact.replaceAll(RegExp(r'\D'), '');
    final isValidMobile =
        contactDigits.length == 11 && contactDigits.startsWith('09');
    final isValidLandline =
        contactDigits.length >= 7 && contactDigits.length <= 8;

    if (!isValidMobile && !isValidLandline) {
      return 'Please enter a valid Philippine phone number';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    final validationError = _validateFields();
    if (validationError != null) {
      if (mounted) {
        SnackbarUtils.showError(context, validationError);
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = UserModel(
        fname: fnameController.text.trim(),
        lname: lnameController.text.trim(),
        mi: miController.text.trim().isEmpty
            ? ''
            : miController.text.trim().toUpperCase(),
        email: emailController.text.trim().toLowerCase(),
        contactNumber: contactNumberController.text.trim(),
        address: addressController.text.trim(),
      );

      final error = await _authService.signUp(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
        userData: userData,
      );

      if (mounted) {
        if (error != null) {
          SnackbarUtils.showError(context, error);
        } else {
          _showSuccessDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    DialogUtils.showSuccess(
      context: context,
      title: 'Account Created!',
      message:
          'Your account has been created successfully. Please check your email for verification link before signing in.',
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      topPadding: 25,
      topContent: const SignupTopContent(),
      children: [
        const SizedBox(height: 16),
        NameRow(
          firstNameController: fnameController,
          middleInitialController: miController,
          lastNameController: lnameController,
          firstNameFocus: fnameFocus,
          middleInitialFocus: miFocus,
          lastNameFocus: lnameFocus,
          nextFocus: emailFocus,
        ),
        const SizedBox(height: 10),
        CustomTextField(
          label: 'Email Address',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
          controller: emailController,
          focusNode: emailFocus,
          onNext: () => FocusHelper.next(context, contactNumberFocus),
        ),
        const SizedBox(height: 10),
        CustomTextField(
          label: 'Contact Number',
          keyboardType: TextInputType.phone,
          icon: Icons.phone_outlined,
          controller: contactNumberController,
          focusNode: contactNumberFocus,
          onNext: () => FocusHelper.next(context, addressFocus),
        ),
        const SizedBox(height: 10),
        CustomTextField(
          label: 'Address',
          icon: Icons.home_outlined,
          controller: addressController,
          focusNode: addressFocus,
          onNext: () => FocusHelper.next(context, passwordFocus),
        ),
        const SizedBox(height: 10),
        CustomTextField(
          label: 'Password',
          obscureText: true,
          icon: Icons.lock_outline,
          controller: passwordController,
          focusNode: passwordFocus,
          textInputAction: TextInputAction.done,
          onNext: () => FocusHelper.next(context, null),
        ),
        const SizedBox(height: 24),
        BigButton(
          text: _isLoading ? "Creating Account..." : "Sign Up",
          onPressed: _isLoading ? null : _handleSignUp,
        ),
        const SizedBox(height: 16),
        AuthRedirectTextButton(
          prompt: "Already have an account?",
          action: "Sign In",
          onPressed: () {
            if (!_isLoading) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

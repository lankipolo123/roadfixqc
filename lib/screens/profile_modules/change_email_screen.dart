// lib/screens/profile_modules/change_email_screen.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/common_widgets/module_header.dart';
import 'package:roadfix/widgets/common_widgets/custom_text_field.dart';
import 'package:roadfix/widgets/common_widgets/big_button.dart';
import 'package:roadfix/services/auth_service.dart';
import 'package:roadfix/utils/snackbar_utils.dart';
import 'package:roadfix/widgets/themes.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newEmailFocus = FocusNode();
  final _currentPasswordFocus = FocusNode();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _emailChanged = false;

  @override
  void dispose() {
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    _newEmailFocus.dispose();
    _currentPasswordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  Future<void> _handleChangeEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final newEmail = _newEmailController.text.trim();
    final currentPassword = _currentPasswordController.text;

    setState(() => _isLoading = true);

    try {
      final error = await _authService.changeEmail(
        newEmail: newEmail,
        currentPassword: currentPassword,
      );

      if (mounted) {
        if (error != null) {
          SnackbarUtils.showError(context, error);
        } else {
          setState(() => _emailChanged = true);
          SnackbarUtils.showSuccess(
            context,
            'Verification email sent! Please check your new email address.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to change email');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goBack() {
    Navigator.pop(context, _emailChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Column(
        children: [
          ModuleHeader(title: 'Change Email', showBack: true, onBack: _goBack),
          Expanded(
            child: Container(
              color: inputFill,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Icon and title
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.email_outlined,
                                size: 48,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Change Your Email Address',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: secondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enter your new email address and current password to update your account.',
                              style: TextStyle(
                                fontSize: 14,
                                color: altSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      if (_emailChanged) ...[
                        // Success message
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: statusSuccess.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusSuccess.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: statusSuccess,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Verification Email Sent!',
                                      style: TextStyle(
                                        color: statusSuccess,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Please check ${_newEmailController.text.trim()} and click the verification link to complete the email change.',
                                      style: const TextStyle(
                                        color: secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // New Email field
                      CustomTextField(
                        label: 'New Email Address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _newEmailController,
                        focusNode: _newEmailFocus,
                        validator: _validateEmail,
                        enabled: !_emailChanged,
                        onChanged: (value) {
                          // Optional: trigger validation on change
                        },
                      ),

                      const SizedBox(height: 16),

                      // Current Password field
                      CustomTextField(
                        label: 'Current Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        controller: _currentPasswordController,
                        focusNode: _currentPasswordFocus,
                        validator: _validatePassword,
                        enabled: !_emailChanged,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixIconTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Security info
                      if (!_emailChanged)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: statusWarning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusWarning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: statusWarning,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You\'ll receive a verification email at your new address. Your email will only be changed after you click the verification link.',
                                  style: TextStyle(
                                    color: secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Change Email button
                      if (!_emailChanged)
                        BigButton(
                          text: _isLoading
                              ? "Sending Verification..."
                              : "Send Verification Email",
                          onPressed: _isLoading ? null : _handleChangeEmail,
                        )
                      else
                        BigButton(text: "Done", onPressed: _goBack),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// lib/screens/profile_modules/change_email_screen.dart (WITH FLOATING BACK BUTTON)
import 'package:flutter/material.dart';
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

  bool _hasChanges() {
    return _newEmailController.text.isNotEmpty ||
        _currentPasswordController.text.isNotEmpty;
  }

  Future<void> _handleCancel() async {
    if (_hasChanges() && !_emailChanged) {
      final shouldCancel = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to go back?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );

      if (shouldCancel == true && mounted) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context, _emailChanged);
    }
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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: inputFill,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

                          // Cancel button
                          if (!_emailChanged)
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : _handleCancel,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primary,
                                  side: const BorderSide(color: primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating back button
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: secondary,
                      size: 20,
                    ),
                    onPressed: _isLoading ? null : _handleCancel,
                    padding: EdgeInsets.zero,
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

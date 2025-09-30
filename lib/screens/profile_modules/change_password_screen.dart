// lib/screens/profile_modules/change_password_screen.dart (WITH FLOATING BACK BUTTON)
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/common_widgets/custom_text_field.dart';
import 'package:roadfix/widgets/common_widgets/big_button.dart';
import 'package:roadfix/services/auth_service.dart';
import 'package:roadfix/utils/snackbar_utils.dart';
import 'package:roadfix/widgets/themes.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordChanged = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value == _currentPasswordController.text) {
      return 'New password must be different from current password';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _hasChanges() {
    return _currentPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _handleCancel() async {
    if (_hasChanges() && !_passwordChanged) {
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
      Navigator.pop(context);
    }
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    setState(() => _isLoading = true);

    try {
      final error = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (mounted) {
        if (error != null) {
          SnackbarUtils.showError(context, error);
        } else {
          setState(() => _passwordChanged = true);
          SnackbarUtils.showSuccess(context, 'Password changed successfully!');
          // Clear form
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to change password');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                                    color: statusWarning.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline,
                                    size: 48,
                                    color: statusWarning,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Change Your Password',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Enter your current password and choose a new secure password.',
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

                          if (_passwordChanged) ...[
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
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: statusSuccess,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Password changed successfully! You can now use your new password to sign in.',
                                      style: TextStyle(
                                        color: statusSuccess,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Current Password field
                          CustomTextField(
                            label: 'Current Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureCurrentPassword,
                            controller: _currentPasswordController,
                            focusNode: _currentPasswordFocus,
                            validator: _validateCurrentPassword,
                            suffixIcon: _obscureCurrentPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // New Password field
                          CustomTextField(
                            label: 'New Password',
                            prefixIcon: Icons.lock_reset_outlined,
                            obscureText: _obscureNewPassword,
                            controller: _newPasswordController,
                            focusNode: _newPasswordFocus,
                            validator: _validateNewPassword,
                            suffixIcon: _obscureNewPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // Confirm New Password field
                          CustomTextField(
                            label: 'Confirm New Password',
                            prefixIcon: Icons.lock_reset_outlined,
                            obscureText: _obscureConfirmPassword,
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            validator: _validateConfirmPassword,
                            suffixIcon: _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            onSuffixIconTap: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          // Security tips
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Password Security Tips',
                                      style: TextStyle(
                                        color: primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '• Use at least 8 characters\n• Include uppercase and lowercase letters\n• Add numbers and special characters\n• Avoid common words or personal information',
                                  style: TextStyle(
                                    color: secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Change Password button
                          if (!_passwordChanged)
                            BigButton(
                              text: _isLoading
                                  ? "Changing Password..."
                                  : "Change Password",
                              onPressed: _isLoading
                                  ? null
                                  : _handleChangePassword,
                            )
                          else
                            BigButton(
                              text: "Done",
                              onPressed: () => Navigator.pop(context),
                            ),

                          const SizedBox(height: 16),

                          // Cancel button
                          if (!_passwordChanged)
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

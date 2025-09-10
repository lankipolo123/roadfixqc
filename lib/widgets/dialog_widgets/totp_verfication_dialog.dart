// lib/widgets/dialog_widgets/totp_verification_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadfix/services/totp_service.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/widgets/themes.dart';

class TotpVerificationDialog extends StatefulWidget {
  const TotpVerificationDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TotpVerificationDialog(),
    );
  }

  @override
  State<TotpVerificationDialog> createState() => _TotpVerificationDialogState();
}

class _TotpVerificationDialogState extends State<TotpVerificationDialog> {
  final UserService _userService = UserService();
  final TextEditingController _codeController = TextEditingController();

  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a 6-digit code';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final user = await _userService.getCurrentUser();
      if (user?.totpSecret == null) {
        throw Exception('TOTP not properly configured');
      }

      final code = _codeController.text.trim();
      final isValid = TotpService.verifyCode(user!.totpSecret!, code);

      if (!isValid) {
        setState(() {
          _errorMessage = 'Invalid code. Please try again.';
          _isVerifying = false;
        });
        return;
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: inputFill,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.security, color: secondary, size: 24),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Two-Factor Authentication',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const Text(
          'Enter the 6-digit code from your authenticator app to continue:',
          style: TextStyle(color: altSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _codeController,
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: const TextStyle(color: altSecondary),
            filled: true,
            fillColor: inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primary, width: 2),
            ),
            errorText: _errorMessage,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: statusDanger, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: statusDanger, width: 2),
            ),
          ),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
            color: secondary,
          ),
          maxLength: 6,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (_errorMessage != null) {
              setState(() => _errorMessage = null);
            }
          },
          onSubmitted: (_) {
            if (!_isVerifying) {
              _verifyCode();
            }
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isVerifying ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isVerifying
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: secondary,
                    ),
                  )
                : const Text(
                    'Verify',
                    style: TextStyle(
                      color: secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isVerifying
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: altSecondary, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

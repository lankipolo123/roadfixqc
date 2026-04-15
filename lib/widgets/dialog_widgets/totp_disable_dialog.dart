// lib/widgets/dialog_widgets/totp_disable_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadfix/services/totp_service.dart';
import 'package:roadfix/services/firestore_service.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class TotpDisableDialog extends StatefulWidget {
  const TotpDisableDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TotpDisableDialog(),
    );
  }

  @override
  State<TotpDisableDialog> createState() => _TotpDisableDialogState();
}

class _TotpDisableDialogState extends State<TotpDisableDialog> {
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();
  final TextEditingController _codeController = TextEditingController();

  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndDisable() async {
    if (_codeController.text.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final user = await _userService.getCurrentUser();
      if (user?.uid == null || user?.totpSecret == null) {
        throw Exception('User or TOTP secret not found');
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

      await _firestoreService.disableTotp(user.uid!);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to disable TOTP: $e';
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: inputFill,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
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
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: statusDanger,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.security, color: inputFill, size: 24.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            'Disable Two-Factor Authentication',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: Icon(Icons.close, color: altSecondary, size: 22.w),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: statusWarning,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: inputFill, size: 24.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Disabling 2FA will make your account less secure. You can re-enable it anytime.',
                  style: TextStyle(
                    color: inputFill,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Enter your current 6-digit authentication code to confirm:',
          style: TextStyle(color: altSecondary, fontSize: 13.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        TextField(
          controller: _codeController,
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: const TextStyle(color: altSecondary),
            filled: true,
            fillColor: inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: primary, width: 2),
            ),
            errorText: _errorMessage,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: statusDanger, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: statusDanger, width: 2),
            ),
          ),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 4,
            color: secondary,
          ),
          maxLength: 6,
          buildCounter: (context,
                  {required currentLength,
                  required isFocused,
                  maxLength}) =>
              null,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (_errorMessage != null) setState(() => _errorMessage = null);
          },
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isVerifying
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: altSecondary, fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyAndDisable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusDanger,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: _isVerifying
                    ? SizedBox(
                        height: 16.w,
                        width: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: inputFill,
                        ),
                      )
                    : Text(
                        'Disable 2FA',
                        style: TextStyle(
                          color: inputFill,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

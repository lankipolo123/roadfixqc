// lib/widgets/dialog_widgets/totp_setup_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:roadfix/services/totp_service.dart';
import 'package:roadfix/services/firestore_service.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class TotpSetupDialog extends StatefulWidget {
  const TotpSetupDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TotpSetupDialog(),
    );
  }

  @override
  State<TotpSetupDialog> createState() => _TotpSetupDialogState();
}

class _TotpSetupDialogState extends State<TotpSetupDialog> {
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();
  final TextEditingController _codeController = TextEditingController();

  late String _secret;
  late String _qrCodeUrl;
  bool _isLoading = true;
  bool _isVerifying = false;
  String? _errorMessage;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _generateTotpSetup();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _generateTotpSetup() async {
    try {
      final user = await _userService.getCurrentUser();
      if (user == null) throw Exception('User not found');

      _secret = TotpService.generateSecret();
      _qrCodeUrl = TotpService.generateTotpUrl(
        secret: _secret,
        accountName: user.email,
        issuer: 'RoadFix',
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to generate TOTP setup: $e';
      });
    }
  }

  Future<void> _verifyAndEnable() async {
    if (_codeController.text.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final code = _codeController.text.trim();
      final isValid = TotpService.verifyCode(_secret, code);

      if (!isValid) {
        setState(() {
          _errorMessage = 'Invalid code. Please try again.';
          _isVerifying = false;
        });
        return;
      }

      final user = await _userService.getCurrentUser();
      if (user?.uid == null) throw Exception('User not found');

      await _firestoreService.enableTotp(uid: user!.uid!, totpSecret: _secret);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to enable TOTP: $e';
        _isVerifying = false;
      });
    }
  }

  void _copySecret() {
    Clipboard.setData(ClipboardData(text: _secret));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Secret copied to clipboard'),
        backgroundColor: statusSuccess,
        duration: Duration(seconds: 2),
      ),
    );
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
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: primary))
            else if (_errorMessage != null)
              _buildErrorState()
            else
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
            color: primary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.security, color: secondary, size: 24.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            'Enable Two-Factor Authentication',
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

  Widget _buildErrorState() {
    return Column(
      children: [
        Icon(Icons.error_outline, size: 48.w, color: statusDanger),
        SizedBox(height: 16.h),
        Text(
          _errorMessage!,
          style: TextStyle(color: statusDanger, fontSize: 14.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: altSecondary, fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _generateTotpSetup,
                style: ElevatedButton.styleFrom(backgroundColor: primary),
                child: Text('Retry',
                    style: TextStyle(color: secondary, fontSize: 14.sp)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildStepIndicator(),
        SizedBox(height: 24.h),
        if (_currentStep == 0) _buildQrCodeStep() else _buildVerificationStep(),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(0, 'Setup'),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep > 0 ? primary : altSecondary,
          ),
        ),
        _buildStepDot(1, 'Verify'),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: isActive ? primary : altSecondary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? secondary : inputFill,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: isActive ? secondary : altSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQrCodeStep() {
    return Column(
      children: [
        Text(
          'Scan this QR code with your authenticator app (Google Authenticator, Authy, etc.)',
          style: TextStyle(color: altSecondary, fontSize: 13.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: inputFill,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: altSecondary),
          ),
          child: QrImageView(
            data: _qrCodeUrl,
            version: QrVersions.auto,
            size: 180.w,
            backgroundColor: inputFill,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Or manually enter this secret key:',
          style: TextStyle(color: altSecondary, fontSize: 12.sp),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: altSecondary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _secret,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.sp,
                    color: inputFill,
                  ),
                ),
              ),
              IconButton(
                onPressed: _copySecret,
                icon: Icon(Icons.copy, size: 16.w, color: primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _currentStep = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Next',
              style: TextStyle(
                  color: secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      children: [
        Text(
          'Enter the 6-digit code from your authenticator app to complete setup:',
          style: TextStyle(color: altSecondary, fontSize: 13.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
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
                    : () => setState(() => _currentStep = 0),
                child: Text(
                  'Back',
                  style: TextStyle(color: altSecondary, fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyAndEnable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
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
                          color: secondary,
                        ),
                      )
                    : Text(
                        'Enable 2FA',
                        style: TextStyle(
                          color: secondary,
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

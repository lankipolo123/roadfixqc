import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadfix/screens/module_screens/navigation_screen.dart';
import 'package:roadfix/utils/location_permission_manager.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);

    await LocationPermissionManager.checkLocationPermission(
      openSettings: false,
    );

    if (mounted) {
      setState(() => _isRequesting = false);
      await _proceedToApp();
    }
  }

  Future<void> _proceedToApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_permission_shown', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: inputFill,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Location icon
              Container(
                padding: EdgeInsets.all(28.r),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  size: 64.r,
                  color: primary,
                ),
              ),

              SizedBox(height: 32.h),

              // Title
              Text(
                'Enable Location Access',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: secondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              // Description
              Text(
                'RoadFix uses your location to accurately map road issues in your area. This helps us pinpoint problems and get them fixed faster.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Enable Location button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _requestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isRequesting
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(inputFill),
                          ),
                        )
                      : Text(
                          'Enable Location',
                          style: TextStyle(
                            color: inputFill,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 12.h),

              // Skip button
              TextButton(
                onPressed: _isRequesting ? null : _proceedToApp,
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

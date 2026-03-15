import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:roadfix/layouts/homescreen_layout.dart';
import 'package:roadfix/services/geolocation_services.dart';
import 'package:roadfix/utils/location_permission_manager.dart';
import 'package:roadfix/widgets/dialog_widgets/location_guidance_dialog.dart';
import 'package:roadfix/widgets/home_widgets/home_header_widgets/home_header.dart';
import 'package:roadfix/widgets/home_widgets/recent_report_section.dart';
import 'package:roadfix/widgets/profile_widgets/status_summary_row.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/home_widgets/banner_widget.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/models/user_model.dart';
import 'package:roadfix/utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  final GeolocationService _geoService = GeolocationService();

  String _locationText = 'Getting location...';
  bool _isLoadingLocation = true;
  LocationStatus _locationStatus = LocationStatus.loading;
  UserModel? _currentUser;
  bool _isLoadingUser = true;
  bool _hasUserError = false;

  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _listenToServiceStatus();
  }

  @override
  void dispose() {
    _serviceStatusSubscription?.cancel();
    super.dispose();
  }

  void _listenToServiceStatus() {
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen(
      (ServiceStatus status) {
        if (!mounted) return;
        if (status == ServiceStatus.enabled) {
          _getCurrentLocation();
        } else {
          setState(() {
            _locationText = 'Enable GPS';
            _locationStatus = LocationStatus.serviceOff;
            _isLoadingLocation = false;
          });
        }
      },
    );
  }

  Future<void> _initializeData() async {
    // Load user data and location in parallel so location starts fetching immediately
    await Future.wait([
      _loadUserData(),
      _getCurrentLocation(),
    ]);
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoadingUser = true;
        _hasUserError = false;
      });

      final user = await _userService.getCurrentUser();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;
          _hasUserError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentUser = null;
          _isLoadingUser = false;
          _hasUserError = true;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
        _locationStatus = LocationStatus.loading;
      });
    }

    // Check status first to give specific feedback
    final status = await LocationPermissionManager.getLocationStatus();

    if (status == LocationStatus.serviceOff) {
      if (mounted) {
        setState(() {
          _locationText = 'Enable GPS';
          _locationStatus = LocationStatus.serviceOff;
          _isLoadingLocation = false;
        });
      }
      return;
    }

    if (status == LocationStatus.denied) {
      if (mounted) {
        setState(() {
          _locationText = 'Allow location';
          _locationStatus = LocationStatus.denied;
          _isLoadingLocation = false;
        });
      }
      return;
    }

    if (status == LocationStatus.deniedForever) {
      if (mounted) {
        setState(() {
          _locationText = 'Location blocked';
          _locationStatus = LocationStatus.deniedForever;
          _isLoadingLocation = false;
        });
      }
      return;
    }

    // Permission granted and service on — fetch location
    try {
      final locationData = await _geoService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationText = locationData.shortAddress;
          _locationStatus = LocationStatus.loaded;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationText = 'Location unavailable';
          _locationStatus = LocationStatus.error;
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _onLocationTap() async {
    switch (_locationStatus) {
      case LocationStatus.serviceOff:
        final result = await LocationGuidanceDialog.show(
          context,
          LocationGuidanceType.serviceOff,
        );
        if (result && mounted) _getCurrentLocation();
        break;

      case LocationStatus.denied:
        final granted = await LocationPermissionManager.checkLocationPermission(
          openSettings: false,
        );
        if (granted && mounted) _getCurrentLocation();
        break;

      case LocationStatus.deniedForever:
        final result = await LocationGuidanceDialog.show(
          context,
          LocationGuidanceType.permanentlyDenied,
        );
        if (result && mounted) _getCurrentLocation();
        break;

      case LocationStatus.loaded:
      case LocationStatus.error:
      case LocationStatus.loading:
        // Refresh location (existing behavior)
        setState(() {
          _isLoadingLocation = true;
          _locationText = 'Refreshing...';
          _locationStatus = LocationStatus.loading;
        });

        try {
          final locationData = await _geoService.getCurrentLocationForced();
          if (mounted) {
            setState(() {
              _locationText = locationData.shortAddress;
              _locationStatus = LocationStatus.loaded;
              _isLoadingLocation = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _locationText = 'Location unavailable';
              _locationStatus = LocationStatus.error;
              _isLoadingLocation = false;
            });
          }
        }
        break;
    }
  }

  Widget _buildHeader() {
    // Show loading only during initial load
    if (_isLoadingUser) {
      return _buildLoadingHeader();
    }

    // Show error if user loading failed
    if (_hasUserError) {
      return _buildErrorHeader();
    }

    // Show actual header with user data
    if (_currentUser != null) {
      return HomeHeader(
        user: _currentUser!,
        locationText: _locationText,
        isLoadingLocation: _isLoadingLocation,
        locationStatus: _locationStatus,
        onLocationTap: _onLocationTap,
      );
    }

    // Fallback welcome header
    return Container(
      height: 120.h,
      color: primary,
      child: Center(
        child: Text(
          'Welcome!',
          style: TextStyle(
            color: altSecondary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
      height: 120.h,
      color: primary,
      child: const Center(
        child: CircularProgressIndicator(color: altSecondary),
      ),
    );
  }

  Widget _buildErrorHeader() {
    return Container(
      height: 120.h,
      color: primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading profile',
              style: TextStyle(
                color: altSecondary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: _loadUserData,
              child: const Text('Retry', style: TextStyle(color: altSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSummary() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 0),
      color: inputFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Reports Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
          SizedBox(height: 12.h),
          const StatusSummaryRow(),
        ],
      ),
    );
  }

  List<Widget> _buildContent() {
    // Show loading content only during initial user load
    if (_isLoadingUser) {
      return [_buildLoadingContent()];
    }

    // Show error content if user loading failed
    if (_hasUserError) {
      return [_buildErrorContent()];
    }

    // Show normal content
    return [
      _buildReportSummary(),
      SizedBox(height: 20.h),
      const BannerWidget(),
      SizedBox(height: 20.h),
      const RecentReportsSection(),
      SizedBox(height: 12.h),
    ];
  }

  Widget _buildLoadingContent() {
    return Container(
      color: inputFill,
      child: const Center(child: CircularProgressIndicator(color: primary)),
    );
  }

  Widget _buildErrorContent() {
    return Container(
      color: inputFill,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.r, color: statusDanger),
            SizedBox(height: 16.h),
            Text(
              'Failed to load user data',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: altSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please try again later',
              style: TextStyle(fontSize: 14.sp, color: altSecondary),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreenLayout(header: _buildHeader(), children: _buildContent());
  }
}

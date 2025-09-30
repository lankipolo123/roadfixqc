import 'package:flutter/material.dart';
import 'package:roadfix/layouts/homescreen_layout.dart';
import 'package:roadfix/services/geolocation_services.dart';
import 'package:roadfix/widgets/home_widgets/home_header_widgets/home_header.dart';
import 'package:roadfix/widgets/home_widgets/recent_report_section.dart';
import 'package:roadfix/widgets/profile_widgets/status_summary_row.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/home_widgets/banner_widget.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/models/user_model.dart';

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
  UserModel? _currentUser;
  bool _isLoadingUser = true;
  bool _hasUserError = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load user data once
    await _loadUserData();
    // Load location once
    await _getCurrentLocation();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoadingUser = true;
        _hasUserError = false;
      });

      // Get current user once instead of using stream
      final user = await _userService
          .getCurrentUser(); // You might need to add this method

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
    try {
      final locationData = await _geoService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationText = locationData.shortAddress;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationText = 'Location unavailable';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _onLocationTap() async {
    setState(() {
      _isLoadingLocation = true;
      _locationText = 'Refreshing...';
    });

    try {
      final locationData = await _geoService.getCurrentLocationForced();
      if (mounted) {
        setState(() {
          _locationText = locationData.shortAddress;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationText = 'Location unavailable';
          _isLoadingLocation = false;
        });
      }
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
        onLocationTap: _onLocationTap,
      );
    }

    // Fallback welcome header
    return Container(
      height: 120,
      color: primary,
      child: const Center(
        child: Text(
          'Welcome!',
          style: TextStyle(
            color: altSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
      height: 120,
      color: primary,
      child: const Center(
        child: CircularProgressIndicator(color: altSecondary),
      ),
    );
  }

  Widget _buildErrorHeader() {
    return Container(
      height: 120,
      color: primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Error loading profile',
              style: TextStyle(
                color: altSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
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
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      color: inputFill,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Reports Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
          SizedBox(height: 12),
          StatusSummaryRow(),
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
      const SizedBox(height: 20),
      const BannerWidget(),
      const SizedBox(height: 20),
      const RecentReportsSection(),
      const SizedBox(height: 12),
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
            const Icon(Icons.error_outline, size: 64, color: statusDanger),
            const SizedBox(height: 16),
            const Text(
              'Failed to load user data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: altSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please try again later',
              style: TextStyle(fontSize: 14, color: altSecondary),
            ),
            const SizedBox(height: 16),
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

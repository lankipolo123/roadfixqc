import 'package:flutter/material.dart';
import 'package:roadfix/services/geolocation_services.dart';
import 'package:roadfix/widgets/home_widgets/recent_report_section.dart';
import 'package:roadfix/widgets/profile_widgets/status_summary_row.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/home_widgets/home_header_widgets/home_header.dart';
import 'package:roadfix/widgets/home_widgets/banner_widget.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/models/profile_summary.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  final GeolocationService _geoService = GeolocationService();

  // Location state
  String _locationText = 'Getting location...';
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get current location (uses cache automatically)
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationText = 'Getting location...';
    });

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

  // Force refresh location when user taps badge
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //parent layout
      backgroundColor: primary,
      body: StreamBuilder<ProfileSummary?>(
        stream: _userService.getCurrentUserProfileSummaryStream(),
        builder: (context, snapshot) {
          return Column(
            children: [
              // Header
              _buildHeader(snapshot),
              // Body
              Expanded(
                child: Container(
                  color: inputFill,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Reports Summary
                        _buildReportSummary(snapshot),
                        const SizedBox(height: 20), //spacing
                        const BannerWidget(), //need graphics designer jumbotron/hero
                        const SizedBox(height: 20), //spacing
                        const RecentReportsSection(), // Fixed: removed mock data
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(AsyncSnapshot<ProfileSummary?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Container(
        height: 120,
        color: primary,
        child: const Center(
          child: CircularProgressIndicator(color: inputFill, strokeWidth: 2),
        ),
      );
    }

    if (snapshot.hasError) {
      return Container(
        height: 120,
        color: primary,
        child: const Center(
          child: Text(
            'Error loading user data',
            style: TextStyle(color: inputFill, fontSize: 16),
          ),
        ),
      );
    }

    if (!snapshot.hasData || snapshot.data == null) {
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

    return HomeHeader(
      user: snapshot.data!,
      locationText: _locationText,
      isLoadingLocation: _isLoadingLocation,
      onLocationTap: _onLocationTap,
    );
  }

  Widget _buildReportSummary(AsyncSnapshot<ProfileSummary?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting ||
        snapshot.hasError ||
        !snapshot.hasData ||
        snapshot.data == null) {
      return const SizedBox.shrink(); // Hide summary if no data
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      color: inputFill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Reports Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: secondary,
            ),
          ),
          const SizedBox(height: 12),
          StatusSummaryRow(user: snapshot.data!),
        ],
      ),
    );
  }
}

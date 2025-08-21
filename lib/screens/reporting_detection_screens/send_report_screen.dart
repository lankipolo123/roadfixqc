import 'dart:io';
import 'package:flutter/material.dart';
import 'package:roadfix/layouts/striped_form_layout.dart';
import 'package:roadfix/services/geolocation_services.dart';
import 'package:roadfix/services/report_service.dart';
import 'package:roadfix/widgets/detection_widgets/location_textfield.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/reporting_widgets/detection_tags.dart';
import 'package:roadfix/widgets/reporting_widgets/report_action_button.dart';
import 'package:roadfix/widgets/reporting_widgets/report_form.dart';
import 'package:roadfix/widgets/common_widgets/custom_text_field.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/widgets/themes.dart';

class SendReportScreen extends StatefulWidget {
  final String imagePath;
  final String? reportType;
  final List<String>? detections;

  const SendReportScreen({
    super.key,
    required this.imagePath,
    this.reportType,
    this.detections,
  });

  @override
  State<SendReportScreen> createState() => _SendReportScreenState();
}

class _SendReportScreenState extends State<SendReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final UserService _userService = UserService();
  final GeolocationService _geoService = GeolocationService();
  final ReportService _reportService = ReportService();

  bool _isLoadingUserData = true;
  bool _isLoadingLocation = false;
  bool _isSubmittingReport = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load user data: $e'),
            backgroundColor: statusWarning,
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await _geoService.getCurrentLocationForced();

      if (mounted) {
        setState(() {
          _locationController.text = locationData.formattedAddress;
          _isLoadingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location updated: ${locationData.shortAddress}'),
            backgroundColor: statusSuccess,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: statusDanger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if required fields are filled
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a location for your report'),
          backgroundColor: statusWarning,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the road issue'),
          backgroundColor: statusWarning,
        ),
      );
      return;
    }

    // Set loading state and show modal
    setState(() {
      _isSubmittingReport = true;
    });

    LoadingModal.show(
      context,
      title: 'Submitting Report',
      description:
          'Please wait while we upload your image and save your report.',
    );

    try {
      // Submit report using ReportService
      final reportId = await _reportService.submitReport(
        imageFile: File(widget.imagePath),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        reportType: widget.reportType ?? 'road_issue',
        detections: widget.detections ?? [],
      );

      if (mounted) {
        // Hide loading modal
        LoadingModal.hide(context);

        if (reportId != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report submitted successfully!'),
              backgroundColor: statusSuccess,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back to NavigationScreen (home)
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          throw Exception('Report submission failed - no ID returned');
        }
      }
    } catch (e) {
      if (mounted) {
        // Hide loading modal
        LoadingModal.hide(context);

        // Show error message
        String errorMessage = 'Failed to submit report';
        String errorStr = e.toString();
        if (errorStr.contains('Failed to submit report:')) {
          errorMessage = errorStr.split('Failed to submit report:').last.trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: statusDanger,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingReport = false;
        });
      }
    }
  }

  void _onReportAnother() {
    if (!_isSubmittingReport) {
      Navigator.popUntil(context, (route) => route.settings.name == '/report');
    }
  }

  void _onDone() {
    if (!_isSubmittingReport) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StripedFormLayout(
      child: Scaffold(
        backgroundColor: inputFill,
        appBar: AppBar(
          title: const Text(
            "Submit a Report",
            style: TextStyle(color: secondary),
          ),
          backgroundColor: primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: secondary),
        ),
        body: _isLoadingUserData
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primary),
                    SizedBox(height: 16),
                    Text(
                      'Loading your profile data...',
                      style: TextStyle(color: secondary),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image preview
                    Center(
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: secondary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: secondary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Detection tags (if available)
                    if (widget.detections != null)
                      DetectionTags(detections: widget.detections!),

                    // Form
                    ReportForm(
                      formKey: _formKey,
                      children: [
                        LocationTextField(
                          controller: _locationController,
                          onSuffixIconTap: _getCurrentLocation,
                          isLoading: _isLoadingLocation,
                          hintText: 'Tap GPS for accurate location',
                        ),
                        const SizedBox(height: 16),

                        DescriptionTextField(
                          controller: _descriptionController,
                          hintText: 'Describe the road issue in detail...',
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    ReportActionButtons(
                      onSubmit: _isSubmittingReport ? () {} : _submitReport,
                      onReportAnother: _isSubmittingReport
                          ? () {}
                          : _onReportAnother,
                      onDone: _isSubmittingReport ? () {} : _onDone,
                      isLoading: _isSubmittingReport,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

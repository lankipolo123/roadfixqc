import 'dart:io';
import 'package:flutter/material.dart';
import 'package:roadfix/layouts/diagonal_background.dart';
import 'package:roadfix/models/location_models.dart';
import 'package:roadfix/services/geolocation_services.dart';
import 'package:roadfix/services/report_service.dart';
import 'package:roadfix/widgets/common_widgets/toast_widget.dart';
import 'package:roadfix/widgets/detection_widgets/location_textfield.dart';
import 'package:roadfix/widgets/dialog_widgets/loading_dialog.dart';
import 'package:roadfix/widgets/dialog_widgets/location_required_dialog.dart';
import 'package:roadfix/widgets/reporting_widgets/detection_tags.dart';
import 'package:roadfix/widgets/reporting_widgets/report_form.dart';
import 'package:roadfix/services/user_service.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/services/security_service.dart';

// Development feature flag - set to false for production
const bool enableQuezonCityOnly = false;

class SendReportScreen extends StatefulWidget {
  final String imagePath;
  final String? reportType;
  final List<String>? detections;
  final String? autoDescription;

  const SendReportScreen({
    super.key,
    required this.imagePath,
    this.reportType,
    this.detections,
    this.autoDescription,
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
  final SecurityService _securityService = SecurityService();

  bool _isLoadingUserData = true;
  bool _isLoadingLocation = false;
  bool _isSubmittingReport = false;
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    if (widget.autoDescription != null) {
      _descriptionController.text = widget.autoDescription!;
    }
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
        AppToast.showError(
          context,
          message: 'Could not load user data: $e',
          title: 'Loading Error',
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
      final locationData = await _geoService.getCurrentLocationForReports();

      if (mounted) {
        setState(() {
          _locationData = locationData;
          _locationController.text = locationData.formattedAddress;
          _isLoadingLocation = false;
        });

        AppToast.showSuccess(
          context,
          message: locationData.shortAddress,
          title: 'Location Updated',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });

        AppToast.showError(
          context,
          message: 'Failed to get location: $e',
          title: 'Location Error',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_locationController.text.trim().isEmpty) {
      AppToast.showWarning(
        context,
        message: 'Please add a location for your report',
        title: 'Missing Location',
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      AppToast.showWarning(
        context,
        message: 'Please describe the road issue',
        title: 'Missing Description',
      );
      return;
    }

    // FEATURE FLAG: Restrict to Quezon City only during development
    if (enableQuezonCityOnly) {
      final locationText = _locationController.text.toLowerCase();
      if (!locationText.contains('quezon city') &&
          !locationText.contains('quezon')) {
        AppToast.showError(
          context,
          message:
              'Reports are currently limited to Quezon City locations only',
          title: 'Location Restricted',
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }

    // Check if location has coordinates — show dialog to prompt GPS fetch
    if (_locationData == null) {
      final shouldGetLocation = await LocationRequiredDialog.show(context);
      if (!mounted) return;
      if (shouldGetLocation) {
        await _getCurrentLocation();
        // If location still not obtained after attempt, stop
        if (_locationData == null) return;
      } else {
        return;
      }
    }

    final securityResult = await _securityService.validateReport(
      imageFile: File(widget.imagePath),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
    );

    if (!mounted) return;

    if (!securityResult.isValid) {
      AppToast.showError(
        context,
        message: securityResult.message,
        title: 'Security Check Failed',
        duration: const Duration(seconds: 4),
      );
      return;
    }

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
      final reportId = await _reportService.submitReport(
        imageFile: File(widget.imagePath),
        description: securityResult.cleanDescription!,
        location: securityResult.cleanLocation!,
        latitude: _locationData!.latitude,
        longitude: _locationData!.longitude,
        reportType: widget.reportType ?? 'road_issue',
        detections: widget.detections ?? [],
      );

      if (mounted) {
        LoadingModal.hide(context);

        if (reportId != null) {
          await _securityService.recordSubmission(
            securityResult.cleanLocation!,
            securityResult.cleanDescription!,
          );

          if (mounted) {
            AppToast.showSuccess(
              context,
              message: 'Your report has been submitted and is being reviewed',
              title: 'Report Submitted!',
              duration: const Duration(seconds: 2),
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
        } else {
          throw Exception('Report submission failed - no ID returned');
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingModal.hide(context);

        String errorMessage = 'Failed to submit report';
        String errorStr = e.toString();
        if (errorStr.contains('Failed to submit report:')) {
          errorMessage = errorStr.split('Failed to submit report:').last.trim();
        }

        AppToast.showError(
          context,
          message: errorMessage,
          title: 'Submission Failed',
          duration: const Duration(seconds: 4),
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

  // ✅ CHANGED: Cancel navigation
  void _onCancel() {
    if (!_isSubmittingReport) {
      Navigator.pop(context);
    }
  }

  // ✅ ADDED: Show full screen image
  void _showFullImage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: secondary.withValues(alpha: 0.8),
                ),
                icon: const Icon(Icons.close, color: inputFill, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DiagonalBackgroundLayout(
      child: Scaffold(
        backgroundColor: inputFill,
        appBar: AppBar(
          title: const Text(
            "Submit a Report",
            style: TextStyle(color: secondary),
          ),
          backgroundColor: transparent,
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
                    // ✅ CHANGED: Made image clickable
                    Center(
                      child: GestureDetector(
                        onTap: _showFullImage,
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
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(widget.imagePath),
                                  fit: BoxFit.cover,
                                  width: 180,
                                  height: 180,
                                ),
                              ),
                              // ✅ ADDED: Zoom icon overlay
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: secondary.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.zoom_in,
                                    color: inputFill,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (widget.detections != null)
                      DetectionTags(detections: widget.detections!),

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

                        // ✅ CHANGED: Blueish-grey disabled look
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFE8EFF5,
                            ), // Blueish-grey background
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFB0C4DE,
                              ), // Light steel blue border
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _descriptionController,
                            readOnly: true,
                            enabled: false,
                            maxLines: 5,
                            style: const TextStyle(
                              color: Color(
                                0xFF5B6B7D,
                              ), // Darker blueish-grey text
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Auto-generated description',
                              hintStyle: TextStyle(
                                color: Color(
                                  0xFF8B99A8,
                                ), // Medium blueish-grey hint
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ✅ CHANGED: New action buttons layout
                    Row(
                      children: [
                        // Submit button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmittingReport
                                ? null
                                : _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              disabledBackgroundColor: Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSubmittingReport
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: inputFill,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Submit Report',
                                    style: TextStyle(
                                      color: inputFill,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Cancel button
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: _isSubmittingReport ? null : _onCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: _isSubmittingReport
                                    ? Colors.grey.shade400
                                    : secondary,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: _isSubmittingReport
                                    ? Colors.grey.shade400
                                    : secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// lib/widgets/detection_widgets/location_textfield.dart (FIXED - WITH GPS CALLBACK)
import 'package:flutter/material.dart';
import 'package:roadfix/services/geolocation_services.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';

class LocationTextField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSuffixIconTap;
  final Function(double lat, double lng)?
  onLocationSelected; // NEW: Pass GPS back
  final bool isLoading;
  final String? hintText;
  final String? labelText;

  const LocationTextField({
    super.key,
    required this.controller,
    this.onSuffixIconTap,
    this.onLocationSelected, // NEW
    this.isLoading = false,
    this.hintText,
    this.labelText,
  });

  @override
  State<LocationTextField> createState() => _LocationTextFieldState();
}

class _LocationTextFieldState extends State<LocationTextField> {
  final GeolocationService _geoService = GeolocationService();
  bool _isLoadingLocation = false;

  Future<void> _getLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await _geoService.getCurrentLocation();
      if (mounted) {
        // Set address text
        widget.controller.text = locationData.formattedAddress;

        // PASS GPS COORDINATES BACK TO PARENT
        if (widget.onLocationSelected != null) {
          widget.onLocationSelected!(
            locationData.latitude,
            locationData.longitude,
          );
        }

        setState(() {
          _isLoadingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location updated: ${locationData.shortAddress}'),
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleSuffixTap() {
    if (widget.onSuffixIconTap != null) {
      widget.onSuffixIconTap!();
    } else {
      _getLocation(); // Default behavior: get GPS location
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = widget.isLoading || _isLoadingLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (matching CustomTextField style)
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: altSecondary,
            ),
          ),
          SizedBox(height: 8.h),
        ],

        // Text field
        TextFormField(
          controller: widget.controller,
          style: TextStyle(fontSize: 16.sp, color: Colors.black87),
          decoration: InputDecoration(
            labelText: widget.labelText == null ? 'Location' : null,
            hintText: widget.hintText ?? 'Enter location or tap GPS button',
            hintStyle: TextStyle(color: altSecondary, fontSize: 16.sp),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: altSecondary,
            ),
            suffixIcon: isLoading
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(strokeWidth: 2.r),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.gps_fixed, color: altSecondary),
                    onPressed: _handleSuffixTap,
                    tooltip: 'Get current location',
                  ),
            filled: true,
            fillColor: inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: altSecondary, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: altSecondary, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: statusDanger, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: statusDanger, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a location';
            }
            return null;
          },
          maxLines: 2,
          minLines: 1,
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}

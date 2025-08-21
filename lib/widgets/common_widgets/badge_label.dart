import 'package:flutter/material.dart';
import 'package:roadfix/services/geolocation_services.dart';
import 'package:roadfix/widgets/themes.dart';

class BadgeLabel extends StatefulWidget {
  final String? text; // Optional - if null, will show location
  final Color backgroundColor;
  final Color textColor;
  final bool isLocationBadge; // New parameter to enable location features
  final VoidCallback? onTap;

  const BadgeLabel({
    super.key,
    this.text,
    this.backgroundColor = primary,
    this.textColor = secondary,
    this.isLocationBadge = false,
    this.onTap,
  });

  // Convenience constructor for location badges
  const BadgeLabel.location({
    super.key,
    this.backgroundColor = primary,
    this.textColor = secondary,
    this.onTap,
  }) : text = null,
       isLocationBadge = true;

  @override
  State<BadgeLabel> createState() => _BadgeLabelState();
}

class _BadgeLabelState extends State<BadgeLabel> {
  final GeolocationService _geoService = GeolocationService();
  String? _locationText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLocationBadge && widget.text == null) {
      _getLocation();
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
      _locationText = 'Getting location...';
    });

    try {
      final location = await _geoService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationText =
              location.shortAddress; // "Anonas, QC" or "Taytay, Rizal"
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationText = 'Location unavailable';
          _isLoading = false;
        });
      }
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.isLocationBadge) {
      _getLocation(); // Default: refresh location
    }
  }

  String get _displayText {
    if (widget.text != null) {
      return widget.text!; // Use provided text
    }
    return _locationText ?? 'Getting location...'; // Use location text
  }

  @override
  Widget build(BuildContext context) {
    Widget badgeContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show loading or location icon for location badges
          if (widget.isLocationBadge) ...[
            if (_isLoading)
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                ),
              )
            else
              Icon(Icons.location_on, size: 12, color: widget.textColor),
            const SizedBox(width: 4),
          ],
          Text(
            _displayText,
            style: TextStyle(
              fontSize: 10,
              color: widget.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    // Make it tappable if it's a location badge or has onTap
    if (widget.isLocationBadge || widget.onTap != null) {
      return GestureDetector(onTap: _handleTap, child: badgeContent);
    }

    return badgeContent;
  }
}

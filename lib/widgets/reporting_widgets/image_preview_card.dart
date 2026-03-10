import 'dart:io';
import 'package:flutter/material.dart';
import 'package:roadfix/utils/responsive.dart';
import 'package:roadfix/widgets/themes.dart';
import 'fullscreen_image_viewer.dart';

class ImagePreviewCard extends StatelessWidget {
  final String imagePath;
  final double size;
  final String buttonText;
  final bool showButton;

  const ImagePreviewCard({
    super.key,
    required this.imagePath,
    this.size = 200,
    this.buttonText = 'View Full Size',
    this.showButton = true,
  });

  void _showFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image preview container
        Container(
          width: size.w,
          height: size.w,
          decoration: BoxDecoration(
            border: Border.all(color: altSecondary),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: secondary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: size.w,
              height: size.w,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: size.w,
                  height: size.w,
                  color: altSecondary.withValues(alpha: 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: statusDanger, size: 40.r),
                      SizedBox(height: 8.h),
                      Text(
                        'Image not found',
                        style: TextStyle(color: altSecondary, fontSize: 12.sp),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // View full size button
        if (showButton) ...[
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => _showFullScreenImage(context),
            icon: const Icon(Icons.fullscreen, color: secondary),
            label: Text(buttonText, style: const TextStyle(color: secondary)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 2,
            ),
          ),
        ],
      ],
    );
  }
}

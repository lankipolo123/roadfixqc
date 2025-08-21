import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roadfix/widgets/themes.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final bool showAppBar;
  final String? title;
  final List<Widget>? actions;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    this.showAppBar = true,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: title != null ? Text(title!) : null,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: actions,
              systemOverlayStyle: SystemUiOverlayStyle.light,
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            // Main image with interactive viewer
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.grey[900],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white54,
                            size: 60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Could not load image',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Custom back button if no app bar
            if (!showAppBar)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: inputFill),
                  ),
                ),
              ),

            // Zoom instructions (optional)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pinch to zoom • Drag to pan',
                    style: TextStyle(color: altSecondary, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Variant with additional controls
class FullScreenImageViewerWithControls extends StatefulWidget {
  final String imagePath;
  final String? title;

  const FullScreenImageViewerWithControls({
    super.key,
    required this.imagePath,
    this.title,
  });

  @override
  State<FullScreenImageViewerWithControls> createState() =>
      _FullScreenImageViewerWithControlsState();
}

class _FullScreenImageViewerWithControlsState
    extends State<FullScreenImageViewerWithControls> {
  final TransformationController _transformationController =
      TransformationController();

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _zoomIn() {
    final Matrix4 currentTransform = _transformationController.value;
    final double currentScale = currentTransform.getMaxScaleOnAxis();
    if (currentScale < 4.0) {
      _transformationController.value = currentTransform * Matrix4.identity()
        ..scale(1.2);
    }
  }

  void _zoomOut() {
    final Matrix4 currentTransform = _transformationController.value;
    final double currentScale = currentTransform.getMaxScaleOnAxis();
    if (currentScale > 0.5) {
      _transformationController.value = currentTransform * Matrix4.identity()
        ..scale(0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondary,
      appBar: AppBar(
        backgroundColor: transparent,
        elevation: 0,
        title: widget.title != null ? Text(widget.title!) : null,
        iconTheme: const IconThemeData(color: inputFill),
        actions: [
          IconButton(
            onPressed: _resetZoom,
            icon: const Icon(Icons.crop_free),
            tooltip: 'Reset Zoom',
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(File(widget.imagePath)),
            ),
          ),

          // Zoom controls
          Positioned(
            bottom: 50,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: secondary,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.zoom_in, color: inputFill),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: secondary,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.zoom_out, color: inputFill),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

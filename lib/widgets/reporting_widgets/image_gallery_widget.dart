// lib/widgets/reporting_widgets/image_gallery_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:roadfix/widgets/themes.dart';

/// Displays one or more images as a swipeable gallery.
/// - Single image: shows it directly (no pager UI).
/// - Multiple images: wraps in a PageView with a "current / total" counter.
/// - Tapping any image opens a full-screen zoomable viewer.
class ImageGalleryWidget extends StatefulWidget {
  final List<String> images;

  /// Label shown above the gallery (e.g. "BEFORE - REPORTED ISSUE").
  final String label;

  /// Color of the label text.
  final Color labelColor;

  /// Height of each image tile.
  final double imageHeight;

  const ImageGalleryWidget({
    super.key,
    required this.images,
    required this.label,
    this.labelColor = altSecondary,
    this.imageHeight = 180,
  });

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    final isSingle = widget.images.length == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Section label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: widget.labelColor,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Image area
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.imageHeight,
            child: isSingle
                ? _buildImageTile(widget.images.first, 0)
                : PageView.builder(
                    controller: _pageController,
                    itemCount: widget.images.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (_, i) =>
                        _buildImageTile(widget.images[i], i),
                  ),
          ),
        ),

        // Page indicator — only for multiple images
        if (!isSingle) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dot indicators
              ...List.generate(widget.images.length, (i) {
                final active = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? widget.labelColor
                        : widget.labelColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
              const SizedBox(width: 10),
              // "1 / 3" counter
              Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: TextStyle(
                  fontSize: 11,
                  color: secondary.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildImageTile(String url, int index) {
    return GestureDetector(
      onTap: () => _showFullScreen(context, index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) => _loader(),
            errorWidget: (_, __, ___) => _error(),
          ),
          // Zoom hint icon
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreen(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) => _FullScreenGallery(
        images: widget.images,
        initialIndex: initialIndex,
        label: widget.label,
      ),
    );
  }

  static Widget _loader() => Container(
        color: altSecondary.withValues(alpha: 0.1),
        child: const Center(child: CircularProgressIndicator(color: primary)),
      );

  static Widget _error() => Container(
        color: altSecondary.withValues(alpha: 0.1),
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: altSecondary, size: 36),
        ),
      );
}

// ─── Full-screen viewer ────────────────────────────────────────────────────────

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String label;

  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
    required this.label,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          // Paged full-screen images
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.black87,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 48, 8),
                    child: Text(
                      widget.images.length > 1
                          ? '${widget.label}  ${_current + 1} / ${widget.images.length}'
                          : widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  // Images
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: PageView.builder(
                      controller: _ctrl,
                      itemCount: widget.images.length,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemBuilder: (_, i) => InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 4.0,
                        child: CachedNetworkImage(
                          imageUrl: widget.images[i],
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(color: primary),
                          ),
                          errorWidget: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: Colors.white54, size: 48),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Dot indicator for multiple images
                  if (widget.images.length > 1) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.images.length, (i) {
                        final active = i == _current;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                  ] else
                    const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          // Close button
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 26),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

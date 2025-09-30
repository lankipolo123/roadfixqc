// lib/screens/splash_screens/connectivity_splash_screen.dart
import 'package:flutter/material.dart';
import 'package:roadfix/services/connectivity_service.dart';
import 'package:roadfix/utils/snackbar_utils.dart';
import 'package:roadfix/widgets/themes.dart';
import 'package:roadfix/widgets/common_widgets/diagonal_stripes.dart';
import 'package:roadfix/layouts/auth_scaffold.dart';

class ConnectivitySplashScreen extends StatefulWidget {
  const ConnectivitySplashScreen({super.key});

  @override
  State<ConnectivitySplashScreen> createState() =>
      _ConnectivitySplashScreenState();
}

class _ConnectivitySplashScreenState extends State<ConnectivitySplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _hasConnection = false;
  bool _isChecking = true;
  String _statusMessage = 'Checking connection...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkConnectivity();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _checkConnectivity() async {
    try {
      // Add minimum display time for better UX
      await Future.wait([
        ConnectivityService.hasInternetConnection(),
        Future.delayed(const Duration(milliseconds: 2000)),
      ]).then((results) {
        _hasConnection = results[0] as bool;
      });

      if (mounted) {
        setState(() {
          _isChecking = false;
          _statusMessage = _hasConnection
              ? 'Connected successfully!'
              : 'No internet connection detected';
        });

        // Cache connectivity status globally
        ConnectivityCache.setConnectionStatus(_hasConnection);

        if (_hasConnection) {
          _navigateToLogin();
        } else {
          _showRetryOption();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasConnection = false;
          _isChecking = false;
          _statusMessage = 'Connection error occurred';
        });

        ConnectivityCache.setConnectionStatus(false);
        _showRetryOption();
      }
    }
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _showRetryOption() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Please check your network connection and try again.',
        );
      }
    });
  }

  Future<void> _retryConnection() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Retrying connection...';
    });

    await _checkConnectivity();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: inputFill,
      body: Stack(
        children: [
          // Background diagonal stripes
          const Positioned(
            top: -3,
            left: 0,
            right: 0,
            child: SizedBox(height: 120, child: DiagonalStripes()),
          ),
          const Positioned(
            bottom: -1,
            left: 0,
            right: 0,
            child: SizedBox(height: 120, child: DiagonalStripes()),
          ),

          // Main content using your AuthScaffold style
          Positioned.fill(
            child: AuthScaffold(
              topPadding: 50,
              topContent: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // App logo/icon with pulse animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isChecking ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _hasConnection && !_isChecking
                                  ? Icons.wifi
                                  : _isChecking
                                  ? Icons.wifi_find
                                  : Icons.wifi_off,
                              size: 48,
                              color: _hasConnection && !_isChecking
                                  ? statusSuccess
                                  : _isChecking
                                  ? primary
                                  : statusDanger,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // App name
                    const Text(
                      'RoadFix',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              children: [
                const SizedBox(height: 48),

                // Status message
                Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: _hasConnection && !_isChecking
                        ? statusSuccess
                        : _isChecking
                        ? altSecondary
                        : statusDanger,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Loading indicator or retry button
                if (_isChecking)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  )
                else if (!_hasConnection)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _retryConnection,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Connection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          ConnectivityCache.setConnectionStatus(true);
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Continue Anyway',
                          style: TextStyle(color: altSecondary, fontSize: 14),
                        ),
                      ),
                    ],
                  )
                else
                  const Icon(
                    Icons.check_circle,
                    color: statusSuccess,
                    size: 32,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// lib/utils/connectivity_cache.dart
class ConnectivityCache {
  static bool? _hasConnection;
  static DateTime? _lastChecked;

  /// Cache the connectivity status
  static void setConnectionStatus(bool hasConnection) {
    _hasConnection = hasConnection;
    _lastChecked = DateTime.now();
  }

  /// Get cached connectivity status (expires after 5 minutes)
  static bool? getCachedConnectionStatus() {
    if (_hasConnection == null || _lastChecked == null) {
      return null;
    }

    final now = DateTime.now();
    final difference = now.difference(_lastChecked!);

    // Cache expires after 5 minutes
    if (difference.inMinutes > 5) {
      _hasConnection = null;
      _lastChecked = null;
      return null;
    }

    return _hasConnection;
  }

  /// Check if we should skip connectivity check
  static bool shouldSkipConnectivityCheck() {
    final cached = getCachedConnectionStatus();
    return cached == true; // Only skip if we have confirmed connection
  }

  /// Clear the cache (useful for testing or when user manually retries)
  static void clearCache() {
    _hasConnection = null;
    _lastChecked = null;
  }
}

// lib/utils/connectivity_cache.dart
class ConnectivityCache {
  static bool? _hasConnection;
  static DateTime? _lastChecked;
  static bool _hasBeenCheckedThisSession = false;

  /// Cache the connectivity status
  static void setConnectionStatus(bool hasConnection) {
    _hasConnection = hasConnection;
    _lastChecked = DateTime.now();
    _hasBeenCheckedThisSession = true;
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

  /// Check if we should skip the initial connectivity check and loading
  static bool shouldSkipInitialCheck() {
    return _hasBeenCheckedThisSession;
  }

  /// Check if we have a recent good connection
  static bool hasRecentConnection() {
    final cached = getCachedConnectionStatus();
    return cached == true;
  }

  /// Clear the cache (useful for testing or when user manually retries)
  static void clearCache() {
    _hasConnection = null;
    _lastChecked = null;
    _hasBeenCheckedThisSession = false;
  }

  /// Mark that initial check was completed this session
  static void markInitialCheckComplete() {
    _hasBeenCheckedThisSession = true;
  }
}

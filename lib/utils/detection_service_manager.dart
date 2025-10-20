import 'package:flutter/material.dart';
import 'package:roadfix/services/pothole_detection_service.dart';
import 'package:roadfix/services/road_blocks_detection_service.dart';
import 'package:roadfix/services/utility_pole_detection_service.dart';

enum DetectionModelType { pothole, roadblocks, utilityPole }

/// ✅ SINGLETON: Manages all detection models and ensures only ONE is loaded at a time
class DetectionServiceManager {
  static final DetectionServiceManager _instance =
      DetectionServiceManager._internal();
  factory DetectionServiceManager() => _instance;
  DetectionServiceManager._internal();

  // Service instances
  PotholeDetectionService? _potholeService;
  RoadblocksDetectionService? _roadblocksService;
  UtilityPoleDetectionService? _utilityPoleService;

  DetectionModelType? _currentlyLoadedModel;

  /// Get the currently loaded model type
  DetectionModelType? get currentModel => _currentlyLoadedModel;

  /// ✅ CRITICAL: Load a specific model and dispose others
  Future<PotholeDetectionService> getPotholeService() async {
    debugPrint('🔄 Requesting POTHOLE model...');

    // If already loaded, return it
    if (_currentlyLoadedModel == DetectionModelType.pothole &&
        _potholeService != null) {
      debugPrint('✅ Pothole model already loaded, reusing instance');
      return _potholeService!;
    }

    // Dispose ALL other models first
    await _disposeAllModels();

    // Create and load pothole model
    debugPrint('🆕 Creating NEW pothole service...');
    _potholeService = PotholeDetectionService();
    await _potholeService!.loadModel();
    _currentlyLoadedModel = DetectionModelType.pothole;

    debugPrint('✅ Pothole model loaded and ready');
    return _potholeService!;
  }

  Future<RoadblocksDetectionService> getRoadblocksService() async {
    debugPrint('🔄 Requesting ROADBLOCKS model...');

    if (_currentlyLoadedModel == DetectionModelType.roadblocks &&
        _roadblocksService != null) {
      debugPrint('✅ Roadblocks model already loaded, reusing instance');
      return _roadblocksService!;
    }

    await _disposeAllModels();

    debugPrint('🆕 Creating NEW roadblocks service...');
    _roadblocksService = RoadblocksDetectionService();
    await _roadblocksService!.loadModel();
    _currentlyLoadedModel = DetectionModelType.roadblocks;

    debugPrint('✅ Roadblocks model loaded and ready');
    return _roadblocksService!;
  }

  Future<UtilityPoleDetectionService> getUtilityPoleService() async {
    debugPrint('🔄 Requesting UTILITY POLE model...');

    if (_currentlyLoadedModel == DetectionModelType.utilityPole &&
        _utilityPoleService != null) {
      debugPrint('✅ Utility Pole model already loaded, reusing instance');
      return _utilityPoleService!;
    }

    await _disposeAllModels();

    debugPrint('🆕 Creating NEW utility pole service...');
    _utilityPoleService = UtilityPoleDetectionService();
    await _utilityPoleService!.loadModel();
    _currentlyLoadedModel = DetectionModelType.utilityPole;

    debugPrint('✅ Utility Pole model loaded and ready');
    return _utilityPoleService!;
  }

  /// ✅ CRITICAL: Dispose ALL models before loading a new one
  Future<void> _disposeAllModels() async {
    debugPrint('🗑️ Disposing all models...');

    if (_potholeService != null) {
      debugPrint('   - Disposing pothole model');
      _potholeService!.dispose();
      _potholeService = null;
    }

    if (_roadblocksService != null) {
      debugPrint('   - Disposing roadblocks model');
      _roadblocksService!.dispose();
      _roadblocksService = null;
    }

    if (_utilityPoleService != null) {
      debugPrint('   - Disposing utility pole model');
      _utilityPoleService!.dispose();
      _utilityPoleService = null;
    }

    _currentlyLoadedModel = null;
    debugPrint('✅ All models disposed');

    // ✅ IMPORTANT: Give the system time to fully release GPU/CPU resources
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Optional: Force cleanup (useful for app lifecycle events)
  Future<void> disposeAll() async {
    await _disposeAllModels();
  }
}

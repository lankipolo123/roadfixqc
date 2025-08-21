import 'package:camera/camera.dart';

Future<CameraController> initCameraController() async {
  final cameras = await availableCameras();
  final backCamera = cameras.firstWhere(
    (cam) => cam.lensDirection == CameraLensDirection.back,
    orElse: () => cameras.first,
  );

  final controller = CameraController(
    backCamera,
    ResolutionPreset.high,
    enableAudio: false,
  );

  await controller.initialize();
  return controller;
}

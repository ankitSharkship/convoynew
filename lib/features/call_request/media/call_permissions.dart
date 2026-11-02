import 'package:permission_handler/permission_handler.dart';

enum PermissionOutcome { granted, denied, permanentlyDenied }

class CallPermissionResult {
  final PermissionOutcome microphone;
  final PermissionOutcome camera;

  const CallPermissionResult({required this.microphone, required this.camera});

  static const allGranted = CallPermissionResult(
    microphone: PermissionOutcome.granted,
    camera: PermissionOutcome.granted,
  );

  bool get microphoneOk => microphone == PermissionOutcome.granted;
  bool get cameraOk => camera == PermissionOutcome.granted;
}

/// Asks for what a call needs before anything is sent to the server, so nobody
/// is rung (or put into a live call) by a phone that cannot take part.
abstract class CallPermissions {
  /// The microphone, and the camera when [needCamera] (the driver). A
  /// permission that is not needed is reported as granted.
  Future<CallPermissionResult> request({required bool needCamera});

  Future<void> openSettings();
}

class DeviceCallPermissions implements CallPermissions {
  const DeviceCallPermissions();

  PermissionOutcome _outcome(PermissionStatus status) {
    if (status.isGranted || status.isLimited) return PermissionOutcome.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return PermissionOutcome.permanentlyDenied;
    }
    return PermissionOutcome.denied;
  }

  @override
  Future<CallPermissionResult> request({required bool needCamera}) async {
    final mic = _outcome(await Permission.microphone.request());
    final camera = needCamera
        ? _outcome(await Permission.camera.request())
        : PermissionOutcome.granted;
    return CallPermissionResult(microphone: mic, camera: camera);
  }

  @override
  Future<void> openSettings() async {
    await openAppSettings();
  }
}

// face_capture_screen.dart
//
// Auto-capture face verification screen, similar to Aadhaar FaceRD.
// - Shows a live camera preview with a darkened overlay and an oval "safe zone"
// - Runs on-device face detection on the camera stream
// - Auto-captures once the face is centered, correctly sized, and facing forward
//   for N consecutive frames (no manual shutter button)
//
// Dependencies (add to pubspec.yaml):
//   camera: ^0.10.6
//   google_mlkit_face_detection: ^0.10.0
//
// Permissions:
//   Android: <uses-permission android:name="android.permission.CAMERA" />
//   iOS: NSCameraUsageDescription in Info.plist

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceCaptureScreen extends StatefulWidget {
  /// Called once a valid, well-positioned face photo has been captured.
  final void Function(File imageFile) onCaptured;

  const FaceCaptureScreen({super.key, required this.onCaptured});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _controller;
  late FaceDetector _faceDetector;

  bool _isDetecting = false;
  bool _isCapturing = false;
  bool _faceInOval = false;

  int _stableFrameCount = 0;
  // Roughly how many consecutive good frames are needed before auto-capture.
  // At ~15fps stream throttling, 10 frames ≈ under a second of steady hold.
  static const int _requiredStableFrames = 10;

  String _statusText = 'Position your face in the frame';

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableClassification:
            true, // gives eyeOpenProbability, useful for blink/liveness
      ),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
    _controller!.startImageStream(_processCameraImage);
  }

  void _processCameraImage(CameraImage image) async {
    // Throttle: skip frames while a previous one is still being processed,
    // or while we're already capturing.
    if (_isDetecting || _isCapturing) return;
    _isDetecting = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage != null) {
        final faces = await _faceDetector.processImage(inputImage);
        _evaluateFaces(faces, image);
      }
    } catch (e) {
      debugPrint('Face detection error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
    if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;
    if (image.planes.length != 1) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void _evaluateFaces(List<Face> faces, CameraImage image) {
    if (faces.isEmpty) {
      _resetStability('Bring your face into the frame');
      return;
    }
    if (faces.length > 1) {
      _resetStability('Only one person should be visible');
      return;
    }

    final face = faces.first;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

    if (!_isFaceWellPositioned(face, imageSize)) return;

    _stableFrameCount++;
    if (mounted) {
      setState(() {
        _faceInOval = true;
        _statusText = 'Hold still...';
      });
    }

    if (_stableFrameCount >= _requiredStableFrames) {
      _captureImage();
    }
  }

  bool _isFaceWellPositioned(Face face, Size imageSize) {
    final box = face.boundingBox;

    // Note: with the front camera the image is typically mirrored relative
    // to what the user sees on screen. If you find the centering feels
    // inverted on your device, flip with: centerX = 1 - centerX.
    final centerX = (box.left + box.right) / 2 / imageSize.width;
    final centerY = (box.top + box.bottom) / 2 / imageSize.height;

    const centerTolerance = 0.3;
    final isCentered =
        (centerX - 0.5).abs() < centerTolerance &&
        (centerY - 0.5).abs() < centerTolerance;

    final faceWidthRatio = box.width / imageSize.width;
    final isGoodSize = faceWidthRatio > 0.35 && faceWidthRatio < 0.75;

    final headTiltOk =
        (face.headEulerAngleY ?? 0).abs() < 15 &&
        (face.headEulerAngleZ ?? 0).abs() < 15;

    if (!isCentered) {
      _resetStability('Center your face in the oval');
      return false;
    }
    if (!isGoodSize) {
      _resetStability(
        faceWidthRatio <= 0.35 ? 'Move closer' : 'Move a bit further away',
      );
      return false;
    }
    if (!headTiltOk) {
      _resetStability('Look straight at the camera');
      return false;
    }

    return true;
  }

  void _resetStability(String message) {
    _stableFrameCount = 0;
    if (mounted) {
      setState(() {
        _faceInOval = false;
        _statusText = message;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing || _controller == null) return;
    _isCapturing = true;
    await _controller!.stopImageStream();

    try {
      final file = await _controller!.takePicture();
      widget.onCaptured(File(file.path));
    } catch (e) {
      debugPrint('Capture error: $e');
      _isCapturing = false;
      await _controller!.startImageStream(_processCameraImage);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          CustomPaint(
            size: Size.infinite,
            painter: _OvalOverlayPainter(highlight: _faceInOval),
          ),
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: Text(
              _statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 6, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OvalOverlayPainter extends CustomPainter {
  final bool highlight;
  _OvalOverlayPainter({required this.highlight});

  @override
  void paint(Canvas canvas, Size size) {
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: size.width * 0.7,
      height: size.width * 0.7 * 1.3,
    );

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addOval(ovalRect);
    final cutoutPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      ovalPath,
    );

    canvas.drawPath(cutoutPath, Paint()..color = Colors.black.withOpacity(0.6));

    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = highlight ? Colors.greenAccent : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant _OvalOverlayPainter oldDelegate) =>
      oldDelegate.highlight != highlight;
}

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'main.dart';

class CameraProcess {
  static const _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  final int cameraIndex;

  CameraController? controller;

  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );
  bool _processing = false;

  CameraProcess(this.cameraIndex);

  Future<CameraProcessResult?> process(CameraImage image) async {
    if (_processing) {
      return null;
    }
    _processing = true;
    CameraProcessResult? result;
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage != null) {
      final faces = await _faceDetector.processImage(inputImage);
      result = CameraProcessResult(faces, inputImage, cameras[cameraIndex].lensDirection);
    }
    _processing = false;
    return result;
  }

  void dispose() {
    _faceDetector.close();
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = cameras[cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[controller?.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || (Platform.isAndroid && format != InputImageFormat.nv21) || (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

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
}

class CameraProcessResult {
  final List<Face> faces;
  final InputImage inputImage;
  final CameraLensDirection cameraLensDirection;

  CameraProcessResult(this.faces, this.inputImage, this.cameraLensDirection);
}

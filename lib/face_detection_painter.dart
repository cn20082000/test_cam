import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:test_cam/camera_process.dart';
import 'package:test_cam/translator_position.dart';

class FaceDetectionPainter extends CustomPainter {
  final CameraProcessResult data;

  FaceDetectionPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    for (final face in data.faces) {
      final left = TranslatorPosition.translateX(
        face.boundingBox.left,
        size,
        data.inputImage.metadata?.size ?? Size.zero,
        data.inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg,
        data.cameraLensDirection,
      );
      final top = TranslatorPosition.translateY(
        face.boundingBox.top,
        size,
        data.inputImage.metadata?.size ?? Size.zero,
        data.inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg,
        data.cameraLensDirection,
      );
      final right = TranslatorPosition.translateX(
        face.boundingBox.right,
        size,
        data.inputImage.metadata?.size ?? Size.zero,
        data.inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg,
        data.cameraLensDirection,
      );
      final bottom = TranslatorPosition.translateY(
        face.boundingBox.bottom,
        size,
        data.inputImage.metadata?.size ?? Size.zero,
        data.inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg,
        data.cameraLensDirection,
      );

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

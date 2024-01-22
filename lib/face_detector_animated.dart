import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:test_cam/camera_process.dart';
import 'package:test_cam/translator_position.dart';

class FaceDetectorAnimated {
  static Widget build(CameraProcessResult data, Face face, Size size) {
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

    return AnimatedPositioned(
      key: ValueKey(face.trackingId),
      duration: const Duration(milliseconds: 50),
      top: min(top, bottom),
      left: min(left, right),
      height: (bottom - top).abs(),
      width: (right - left).abs(),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.lightBlue),
        ),
      ),
    );
  }
}
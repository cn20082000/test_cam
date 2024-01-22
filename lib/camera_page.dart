import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test_cam/camera_process.dart';
import 'package:test_cam/face_detector_animated.dart';
import 'package:test_cam/main.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraProcess cameraProcess;
  late CameraController cameraCtrl;

  int cameraIndex = 0;
  CameraProcessResult? result;

  @override
  void initState() {
    super.initState();
    _initCameraIndex();
    _initCameraProcess();
    _initCameraController();
  }

  @override
  void dispose() {
    cameraCtrl.dispose();
    cameraProcess.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Center(
    //     child: CameraPreview(
    //       cameraCtrl,
    //       child: CustomPaint(painter: result != null ? FaceDetectionPainter(result!) : null),
    //     ),
    //   ),
    // );
    return Scaffold(
      body: Center(
        child: CameraPreview(
          cameraCtrl,
          child: LayoutBuilder(builder: (ctx, cts) {
            return Stack(
              children:
                  result != null ? result!.faces.map((e) => FaceDetectorAnimated.build(result!, e, Size(cts.maxWidth, cts.maxHeight))).toList() : [],
            );
          }),
        ),
      ),
    );
  }

  void _initCameraIndex() {
    for (int i = 0; i < cameras.length; ++i) {
      if (cameras[i].lensDirection == CameraLensDirection.front) {
        cameraIndex = i;
        break;
      }
    }
  }

  void _initCameraProcess() {
    cameraProcess = CameraProcess(cameraIndex);
  }

  void _initCameraController() {
    cameraCtrl = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    cameraCtrl.initialize().then((value) {
      if (!mounted) {
        return;
      }
      cameraProcess.controller = cameraCtrl;
      cameraCtrl.startImageStream((image) {
        cameraProcess.process(image).then((value) {
          if (value != null) {
            setState(() {
              result = value;
            });
          }
        });
      });
      setState(() {});
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }
}

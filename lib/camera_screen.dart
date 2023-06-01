import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_camera_rt/ascii_screen.dart';
import 'package:flutter_camera_rt/camera_handler.dart';
import 'package:flutter_camera_rt/service/image_result_processor_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with CameraHandler, WidgetsBindingObserver {
  CameraController? _cameraController;
  CameraLensDirection cameraDirection = CameraLensDirection.front;
  bool _isProcessing = false;
  List<StreamSubscription<Uint8List>> _rawSubscription = [];
  bool showAscii = false;

  late ImageResultProcessorService _imageResultProcessorService;

  @override
  void initState() {
    super.initState();
    _imageResultProcessorService = ImageResultProcessorService();
    WidgetsBinding.instance.addObserver(this);
    _rawSubscription.add(_imageResultProcessorService.rawQueue.listen((event) {
      _isProcessing = false;
    }));
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dispose all streams!
    _rawSubscription.forEach((element) {
      element.cancel();
    });
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller!.description);
      }
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller?.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    // If the controller is updated then update the UI.
    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        print("Camera error: ${controller!.value.errorDescription}");
      }
    });

    try {
      await controller!.initialize();

      await controller!
          .startImageStream((CameraImage image) => _processCameraImage(image));
    } on CameraException catch (e) {
      showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  _initCamera() async {
    CameraController controller = CameraController(
      await _getCamera(cameraDirection),
      ResolutionPreset.low,
    );
    setState(() {
      _cameraController = controller;
    });
    await _cameraController!.initialize();
    _cameraController!
        .startImageStream((CameraImage image) => _processCameraImage(image));
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) {
      return; //Do not detect another image until you finish the previous.
    }
    _isProcessing = true;
    print("Sent a new image and sleeping for: $DELAY_TIME");
    await Future.delayed(
      const Duration(milliseconds: DELAY_TIME),
      () => _imageResultProcessorService.addRawImage(image, showAscii),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_cameraController != null) CameraPreview(_cameraController!),
        if (showAscii)
          AsciiScreen(asciiStream: _imageResultProcessorService.asciiQueue),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.flash_on),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.camera_front),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: IconButton(
            onPressed: () {
              setState(() {
                showAscii = !showAscii;
              });
            },
            icon: Icon(Icons.abc),
          ),
        )
      ],
    );
  }
}

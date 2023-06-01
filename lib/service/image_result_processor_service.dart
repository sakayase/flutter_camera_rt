import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_camera_rt/method_channelling/yuv_channelling.dart';
import 'package:rxdart/subjects.dart';
import 'package:image/image.dart' as img_lib;
import 'package:enough_ascii_art/enough_ascii_art.dart' as art;

class ImageResultProcessorService {
  final YuvChannelling _yuvChannelling = YuvChannelling();

  /// We need to notify the page that we have finished the process of the image.
  /// The subject could possibly sink the result [Uint8List] if needed.
  final PublishSubject<Uint8List> _rawQueue = PublishSubject();

  final PublishSubject<String> _asciiQueue = PublishSubject();

  /// Observers that needs the result image should subscribe to this stream.
  Stream<Uint8List> get rawQueue => _rawQueue.stream;

  Stream<String> get asciiQueue => _asciiQueue.stream;

  addRawImage(CameraImage cameraImage, bool shouldFeedAscii) async {
    num sTime = DateTime.now().millisecondsSinceEpoch;
    Uint8List imgJpeg = await _yuvChannelling.yuvTransform(cameraImage);
    print(
        "Job (raw) took ${(DateTime.now().millisecondsSinceEpoch - sTime) / 1000} seconds to complete.");
    if (shouldFeedAscii) {
      processJpgImage(imgJpeg);
    }
    _rawQueue.sink.add(imgJpeg);
  }

  processJpgImage(Uint8List jpgImage) {
    num sTime = DateTime.now().millisecondsSinceEpoch;
    img_lib.Image? img = img_lib.decodeImage(jpgImage);
    String? asciiArt;
    if (img != null) {
      asciiArt = art.convertImage(
        img,
        maxWidth: 80,
        invert: true,
      );
      print(
          "Job (ascii) took ${(DateTime.now().millisecondsSinceEpoch - sTime) / 1000} seconds to complete.");
      _asciiQueue.sink.add(asciiArt);
      return;
    }
    print(
        "Job (ascii) failed in ${(DateTime.now().millisecondsSinceEpoch - sTime) / 1000} seconds.");
  }

  void dispose() {
    _rawQueue.close();
  }
}

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

/// Alternative detection service using Google ML Kit.
///
/// Advantages over TFLite:
/// - No model file to bundle — model downloaded on first use.
/// - Simpler API; handles preprocessing automatically.
///
/// Use this as a drop-in replacement for [DetectionService] during
/// development or when the TFLite model file is not available.
class MLKitDetectionService {
  late ObjectDetector _detector;
  bool _isInitialised = false;

  /// Initialises the ML Kit object detector in streaming mode.
  void init() {
    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: false,
    );
    _detector = ObjectDetector(options: options);
    _isInitialised = true;
    debugPrint('✅ ML Kit detector initialised.');
  }

  /// Runs inference on a single [InputImage] and returns the top label.
  ///
  /// Returns an empty string if no objects are detected.
  Future<String> detect(InputImage inputImage) async {
    if (!_isInitialised) return '';

    try {
      final objects = await _detector.processImage(inputImage);
      if (objects.isEmpty) return '';

      final best = objects.first;
      if (best.labels.isEmpty) return 'Unknown object';

      final topLabel = best.labels.reduce(
        (a, b) => a.confidence > b.confidence ? a : b,
      );

      return topLabel.text;
    } catch (e) {
      debugPrint('ML Kit detection error: $e');
      return '';
    }
  }

  /// Releases ML Kit detector resources.
  void dispose() {
    if (_isInitialised) {
      _detector.close();
      _isInitialised = false;
    }
  }
}

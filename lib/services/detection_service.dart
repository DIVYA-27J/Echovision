import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import '../models/detection_result.dart';
import '../utils/constants.dart';

/// Service that runs TFLite MobileNetV2 SSD inference on live camera frames.
///
/// Extends [ChangeNotifier] so the UI rebuilds automatically when a new
/// high-confidence detection is available.
class DetectionService extends ChangeNotifier {
  Interpreter? _interpreter;
  List<String> _labels = [];

  String currentLabel = '';
  double currentConfidence = 0.0;
  bool isModelLoaded = false;
  bool _isProcessing = false;

  /// Loads the TFLite model and labels file from the assets bundle.
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(AppConstants.modelPath);
      final labelData =
          await rootBundle.loadString(AppConstants.labelsPath);
      _labels = labelData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      isModelLoaded = true;
      notifyListeners();
      debugPrint('✅ TFLite model loaded. Labels: ${_labels.length}');
    } catch (e) {
      debugPrint('❌ Failed to load TFLite model: $e');
    }
  }

  /// Returns true if a detection at [confidence] should trigger a TTS
  /// announcement.
  bool shouldAnnounce(double confidence) =>
      confidence >= AppConstants.announceThreshold;

  /// Runs inference on a single [CameraImage] frame.
  ///
  /// Skips the frame if the previous one is still being processed
  /// (frame-dropping strategy to avoid queue build-up).
  Future<void> detect(CameraImage image) async {
    if (_isProcessing || !isModelLoaded || _interpreter == null) return;
    _isProcessing = true;

    try {
      // --- Preprocessing: YUV420 → RGB → resize to 300×300 → normalise ---
      final input = _preprocessImage(image);
      // Output tensor: [1, 10, 6] — 10 candidate boxes, each with
      // [yMin, xMin, yMax, xMax, score, classIndex]
      final output =
          List.generate(1, (_) => List.generate(10, (_) => List.filled(6, 0.0)));

      _interpreter!.run(input, output);

      final result = _parseOutput(output);

      if (result != null &&
          result.confidence >= AppConstants.announceThreshold) {
        currentLabel = result.label;
        currentConfidence = result.confidence;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Detection error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Converts a [CameraImage] (YUV420) to a normalised 300×300 RGB tensor.
  List<List<List<List<double>>>> _preprocessImage(CameraImage image) {
    const int size = AppConstants.inputSize;
    final input = List.generate(
      1,
      (_) => List.generate(
        size,
        (_) => List.generate(size, (_) => List.filled(3, 0.0)),
      ),
    );

    // Simple YUV→greyscale approximation for hackathon MVP.
    // Replace with a full YUV→RGB converter (image package) for production.
    final yPlane = image.planes[0].bytes;
    final imgWidth = image.width;
    final imgHeight = image.height;

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final srcX = (x * imgWidth ~/ size).clamp(0, imgWidth - 1);
        final srcY = (y * imgHeight ~/ size).clamp(0, imgHeight - 1);
        final yVal = yPlane[srcY * imgWidth + srcX] / 255.0;
        // Assign same value to R, G, B channels (greyscale fallback)
        input[0][y][x][0] = yVal;
        input[0][y][x][1] = yVal;
        input[0][y][x][2] = yVal;
      }
    }
    return input;
  }

  /// Parses the raw TFLite output tensor into a [DetectionResult].
  DetectionResult? _parseOutput(List<List<List<double>>> output) {
    double bestConfidence = 0.0;
    int bestClassIdx = -1;

    for (final box in output[0]) {
      // box = [yMin, xMin, yMax, xMax, score, classIndex]
      if (box.length < 6) continue;
      final score = box[4];
      if (score > bestConfidence) {
        bestConfidence = score;
        bestClassIdx = box[5].toInt();
      }
    }

    if (bestClassIdx < 0 || bestClassIdx >= _labels.length) return null;

    return DetectionResult(
      label: _labels[bestClassIdx],
      confidence: bestConfidence,
      detectedAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }
}

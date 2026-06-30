// test/detection_service_test.dart
// Unit tests from Echo Vision Full Project Guide — Part 9.1

import 'package:flutter_test/flutter_test.dart';
import 'package:echo_vision/services/detection_service.dart';
import 'package:echo_vision/services/tts_service.dart';

void main() {
  group('DetectionService', () {
    late DetectionService svc;

    setUp(() {
      svc = DetectionService();
    });

    tearDown(() {
      svc.dispose();
    });

    test('ignores low-confidence detections', () {
      // Below announce threshold (0.55) → should NOT announce
      expect(svc.shouldAnnounce(0.3), false);
      expect(svc.shouldAnnounce(0.40), false);
      expect(svc.shouldAnnounce(0.54), false);

      // At or above announce threshold → should announce
      expect(svc.shouldAnnounce(0.55), true);
      expect(svc.shouldAnnounce(0.6), true);
      expect(svc.shouldAnnounce(0.9), true);
    });

    test('initial label is empty', () {
      expect(svc.currentLabel, isEmpty);
    });

    test('initial confidence is zero', () {
      expect(svc.currentConfidence, 0.0);
    });

    test('model is not loaded initially', () {
      expect(svc.isModelLoaded, false);
    });
  });

  group('TTSService', () {
    late TTSService tts;

    setUp(() {
      tts = TTSService();
    });

    test('initial lastSpoken is empty', () {
      expect(tts.lastSpoken, isEmpty);
    });

    test('prevents duplicate TTS announcements via speak()', () async {
      // First call — should speak
      await tts.speak('chair');
      expect(tts.lastSpoken, 'chair');

      // Second call with same text — should NOT fire TTS again
      // (lastSpoken remains 'chair', no new speak issued)
      await tts.speak('chair');
      expect(tts.lastSpoken, 'chair');
    });

    test('allows different label after resetCache()', () async {
      await tts.speak('chair');
      tts.resetCache();
      expect(tts.lastSpoken, isEmpty);
    });

    test('speakForced overrides repeat prevention', () async {
      await tts.speak('bottle');
      await tts.speakForced('bottle'); // Should still accept
      expect(tts.lastSpoken, 'bottle');
    });
  });

  group('Confidence threshold constants', () {
    test('announce threshold is 0.55', () {
      final svc = DetectionService();
      // At exactly 0.55 → announce
      expect(svc.shouldAnnounce(0.55), true);
      // Just below → do not announce
      expect(svc.shouldAnnounce(0.549), false);
      svc.dispose();
    });
  });
}

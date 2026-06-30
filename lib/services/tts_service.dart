import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/constants.dart';

/// Manages text-to-speech announcements for detected objects.
///
/// Key behaviour:
/// - Prevents repetition: speaking the same label twice in a row is a no-op.
/// - Stops any ongoing speech before starting a new announcement.
class TTSService {
  final FlutterTts _tts = FlutterTts();

  String _lastSpoken = '';
  String get lastSpoken => _lastSpoken;

  bool _isInitialised = false;

  /// Initialises TTS engine with default settings from [AppConstants].
  Future<void> init() async {
    try {
      await _tts.setLanguage(AppConstants.defaultTtsLanguage);
      await _tts.setSpeechRate(AppConstants.ttsSpeechRate);
      await _tts.setVolume(AppConstants.ttsVolume);
      await _tts.setPitch(AppConstants.ttsPitch);

      _tts.setErrorHandler((message) {
        debugPrint('TTS error: $message');
      });

      _isInitialised = true;
      debugPrint('✅ TTS initialised.');
    } catch (e) {
      debugPrint('❌ TTS init failed: $e');
    }
  }

  /// Sets the TTS language (e.g. 'en-US', 'ta-IN').
  Future<void> setLanguage(String language) async {
    await _tts.setLanguage(language);
  }

  /// Speaks [text] aloud.
  ///
  /// If [text] is the same as the last spoken string, this is a no-op
  /// to prevent continuous repetition of the same label.
  Future<void> speak(String text) async {
    if (!_isInitialised) return;
    if (text.trim().isEmpty) return;
    if (text == _lastSpoken) return; // Prevent repetition

    _lastSpoken = text;
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Forces speech of [text] even if it matches the last spoken string.
  Future<void> speakForced(String text) async {
    if (!_isInitialised) return;
    _lastSpoken = text;
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Stops any ongoing speech.
  Future<void> stop() async => await _tts.stop();

  /// Clears the last spoken cache, allowing the same label to be re-announced.
  void resetCache() => _lastSpoken = '';

  /// Releases TTS resources.
  Future<void> dispose() async => await _tts.stop();
}

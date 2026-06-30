import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../utils/constants.dart';

/// Listens for voice commands and notifies the app when "Help me" is detected.
class SpeechService {
  final stt.SpeechToText _stt = stt.SpeechToText();

  /// Callback invoked when the "Help me" command is recognised.
  Function(String)? onCommandDetected;

  bool _isListening = false;
  bool get isListening => _isListening;

  bool _isAvailable = false;

  /// Initialises the STT engine.
  ///
  /// Returns true if the device supports speech recognition.
  Future<bool> initialise() async {
    _isAvailable = await _stt.initialize(
      onError: (error) => debugPrint('STT error: ${error.errorMsg}'),
      onStatus: (status) => debugPrint('STT status: $status'),
    );
    debugPrint('✅ STT available: $_isAvailable');
    return _isAvailable;
  }

  /// Starts continuous listening for the "Help me" voice command.
  Future<void> startListening() async {
    if (!_isAvailable || _isListening) return;

    _isListening = true;

    await _stt.listen(
      onResult: (result) {
        final words = result.recognizedWords.toLowerCase().trim();
        debugPrint('STT heard: "$words"');

        if (words.contains('help me') || words.contains('help')) {
          onCommandDetected?.call(words);
        }
      },
      listenFor: AppConstants.sttListenDuration,
      pauseFor: AppConstants.sttPauseDuration,
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Stops listening.
  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;
    await _stt.stop();
  }

  /// Restarts the STT listener (e.g. after the pause duration expires).
  Future<void> restartListening() async {
    await stopListening();
    await Future.delayed(const Duration(milliseconds: 300));
    await startListening();
  }
}

/// App-wide constants for Echo Vision.
library;

class AppConstants {
  // TFLite model config
  static const String modelPath = 'assets/models/mobilenet.tflite';
  static const String labelsPath = 'assets/models/labels.txt';
  static const int inputSize = 300;
  static const int numResults = 10;

  // Confidence thresholds
  static const double ignoreThreshold = 0.40;
  static const double announceThreshold = 0.55;
  static const double highConfidenceThreshold = 0.75;

  // TTS settings
  static const double ttsSpeechRate = 0.5;
  static const double ttsVolume = 1.0;
  static const double ttsPitch = 1.0;
  static const String defaultTtsLanguage = 'en-US';

  // STT settings
  static const Duration sttListenDuration = Duration(seconds: 30);
  static const Duration sttPauseDuration = Duration(seconds: 3);

  // Emergency
  static const int maxSmsLength = 160;
  static const String appName = 'Echo Vision';
  static const String sosPrefix = 'ECHO VISION SOS: ';

  // SharedPreferences keys
  static const String keyEmergencyContact = 'emergency_contact';
  static const String keyTtsLanguage = 'tts_language';
}

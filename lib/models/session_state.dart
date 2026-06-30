import 'detection_result.dart';

/// Represents the complete state of a single app session.
///
/// Cleared on app termination — never written to persistent storage.
class SessionState {
  /// The most recently detected object.
  DetectionResult? lastDetection;

  /// Total number of detections this session.
  int detectionCount = 0;

  /// Whether the emergency SMS has been sent in this session.
  bool emergencySent = false;

  /// Timestamp when the session began.
  final DateTime sessionStart = DateTime.now();

  SessionState();

  /// Resets state as if the app was freshly launched.
  void clear() {
    lastDetection = null;
    detectionCount = 0;
    emergencySent = false;
  }

  /// Returns a human-readable session summary.
  String get summary =>
      'Session: ${detectionCount} detections since '
      '${sessionStart.toLocal().toIso8601String().substring(11, 19)}. '
      'Emergency sent: $emergencySent';
}

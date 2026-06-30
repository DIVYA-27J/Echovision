import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';

/// In-session memory store for the most recently detected object and location.
///
/// This service holds state only for the current app session.
/// All data is cleared when [clear] is called or the app terminates.
/// Nothing is written to disk — privacy-friendly by design.
class MemoryService extends ChangeNotifier {
  String? lastObject;
  DateTime? lastDetectedAt;
  Position? lastLocation;

  /// Updates the session with a new detection.
  void update(String object, Position? location) {
    lastObject = object;
    lastDetectedAt = DateTime.now();
    lastLocation = location;
    notifyListeners();
  }

  /// Clears all session data (called on app dispose).
  void clear() {
    lastObject = null;
    lastDetectedAt = null;
    lastLocation = null;
    notifyListeners();
  }

  /// Returns a human-readable summary for debugging / status display.
  String get summary {
    if (lastObject == null) return 'Nothing detected yet.';

    final loc = lastLocation != null
        ? 'Lat: ${lastLocation!.latitude.toStringAsFixed(4)}, '
            'Lon: ${lastLocation!.longitude.toStringAsFixed(4)}'
        : 'Location unavailable';

    final time = lastDetectedAt != null
        ? lastDetectedAt!.toLocal().toIso8601String().substring(11, 19)
        : '—';

    return 'Object: $lastObject | $loc | $time';
  }

  /// Returns true if there is any detection data in memory.
  bool get hasData => lastObject != null;
}

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Provides GPS location for emergency SMS messages.
///
/// Location is only requested when the 'Help me' command is triggered —
/// never polled continuously. This respects user privacy and battery life.
class LocationService {
  /// Fetches the current GPS position.
  ///
  /// Returns null if:
  /// - Permission is denied or permanently denied.
  /// - The location lookup times out (5-second limit).
  /// - Any other error occurs (e.g. GPS hardware unavailable).
  Future<Position?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('📍 Location permission denied.');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('📍 Location fetch failed: $e');
      return null;
    }
  }

  /// Builds a Google Maps link from a [Position].
  static String buildMapsLink(Position position) =>
      'https://maps.google.com/?q=${position.latitude},${position.longitude}';

  /// Builds a fallback string when location is unavailable.
  static String unavailableMessage() => 'Location unavailable';
}

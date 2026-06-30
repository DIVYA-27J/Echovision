import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';
import '../utils/constants.dart';
import 'location_service.dart';

/// Handles the emergency "Help me" feature.
///
/// Composes and sends an SMS to the stored emergency contact containing:
/// - The last detected object name.
/// - A Google Maps link (or "Location unavailable" fallback).
///
/// Privacy: SMS content is capped at [AppConstants.maxSmsLength] characters.
/// No audio or camera data is ever included.
class EmergencyService {
  final Telephony _telephony = Telephony.instance;

  /// Sends an SOS SMS to [contact] with the last detected [objectName]
  /// and optional [location].
  ///
  /// Returns true on success, false on failure.
  Future<bool> sendHelp({
    required String contact,
    required String objectName,
    Position? location,
  }) async {
    if (contact.trim().isEmpty) {
      debugPrint('❌ Emergency: No contact number set.');
      return false;
    }

    final locStr = location != null
        ? LocationService.buildMapsLink(location)
        : LocationService.unavailableMessage();

    // Sanitise object name — remove any special characters that could
    // cause issues with SMS encoding.
    final safeObject = objectName.replaceAll(RegExp(r'[^\w\s]'), '').trim();

    String message =
        '${AppConstants.sosPrefix}Near object: $safeObject. Location: $locStr';

    // Cap to SMS-safe length
    if (message.length > AppConstants.maxSmsLength) {
      message = message.substring(0, AppConstants.maxSmsLength);
    }

    try {
      await _telephony.sendSms(
        to: contact,
        message: message,
        statusListener: (status) {
          debugPrint('📱 SMS status: $status');
        },
      );
      debugPrint('✅ SOS SMS sent to $contact');
      return true;
    } catch (e) {
      debugPrint('❌ SMS send failed: $e');
      return false;
    }
  }
}

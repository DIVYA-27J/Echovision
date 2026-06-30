import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Manages persistent user settings using SharedPreferences.
///
/// Currently stores:
/// - Emergency contact phone number.
/// - TTS language preference.
///
/// For production, replace SharedPreferences with flutter_secure_storage
/// to encrypt the emergency contact number.
class SettingsService {
  // ---------------------------------------------------------------------------
  // Emergency Contact
  // ---------------------------------------------------------------------------

  /// Returns the stored emergency contact number, or null if not set.
  Future<String?> getEmergencyContact() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyEmergencyContact);
  }

  /// Saves [number] as the emergency contact.
  Future<void> setEmergencyContact(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyEmergencyContact, number.trim());
  }

  /// Removes the stored emergency contact.
  Future<void> clearEmergencyContact() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyEmergencyContact);
  }

  // ---------------------------------------------------------------------------
  // TTS Language
  // ---------------------------------------------------------------------------

  /// Returns the stored TTS language code, defaulting to 'en-US'.
  Future<String> getTtsLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyTtsLanguage) ??
        AppConstants.defaultTtsLanguage;
  }

  /// Saves [language] as the TTS language preference.
  Future<void> setTtsLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyTtsLanguage, language);
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles runtime permission requests and fallback dialogs.
class PermissionHelper {
  /// Requests camera, microphone, location, and SMS permissions.
  /// Returns true only if camera AND microphone are granted (mandatory).
  static Future<bool> requestAllPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.sms,
    ].request();

    final camera = statuses[Permission.camera]!.isGranted;
    final mic = statuses[Permission.microphone]!.isGranted;

    // Camera and mic are mandatory; location and SMS are optional
    return camera && mic;
  }

  /// Checks if only camera and mic are granted (minimum required).
  static Future<bool> hasCorePermissions() async {
    final camera = await Permission.camera.isGranted;
    final mic = await Permission.microphone.isGranted;
    return camera && mic;
  }

  /// Shows a dialog directing users to app settings if camera is
  /// permanently denied.
  static Future<void> showSettingsIfDenied(BuildContext context) async {
    final denied = await Permission.camera.isPermanentlyDenied;
    if (denied) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Camera Required',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Echo Vision needs camera access to detect objects. '
            'Please enable camera permission in app settings.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              onPressed: openAppSettings,
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  /// Returns a user-facing description for the permission rationale.
  static String getRationale(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera is required to detect objects in real time.';
      case Permission.microphone:
        return 'Microphone is needed to listen for "Help me" voice commands.';
      case Permission.location:
        return 'Location is included in emergency SMS to help responders find you.';
      case Permission.sms:
        return 'SMS permission allows the app to send an emergency alert to your contact.';
      default:
        return 'This permission is required for app functionality.';
    }
  }
}

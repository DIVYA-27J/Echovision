import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/detection_service.dart';
import 'services/tts_service.dart';
import 'services/speech_service.dart';
import 'services/memory_service.dart';
import 'services/location_service.dart';
import 'services/emergency_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EchoVisionApp());
}

/// Root application widget.
///
/// Sets up [MultiProvider] so all services are available throughout the
/// widget tree without manual dependency injection.
class EchoVisionApp extends StatelessWidget {
  const EchoVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AI inference — loads TFLite model on creation
        ChangeNotifierProvider(
          create: (_) => DetectionService()..loadModel(),
        ),
        // In-session state — cleared on dispose
        ChangeNotifierProvider(
          create: (_) => MemoryService(),
        ),
        // Text-to-speech — initialised on creation
        Provider<TTSService>(
          create: (_) => TTSService()..init(),
          dispose: (_, svc) => svc.dispose(),
        ),
        // Speech-to-text
        Provider<SpeechService>(
          create: (_) => SpeechService(),
        ),
        // Emergency SMS
        Provider<EmergencyService>(
          create: (_) => EmergencyService(),
        ),
        // GPS location
        Provider<LocationService>(
          create: (_) => LocationService(),
        ),
      ],
      child: MaterialApp(
        title: 'Echo Vision',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            secondary: Color(0xFF00B4D8),
            surface: Color(0xFF1A1A2E),
            background: Color(0xFF0D0D1A),
            error: Color(0xFFFF5252),
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF12122A),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

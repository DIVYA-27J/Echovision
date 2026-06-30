import 'package:flutter/material.dart';
import '../utils/permission_helper.dart';
import 'camera_screen.dart';

/// Splash screen shown on app launch.
///
/// Responsibilities:
/// 1. Display the Echo Vision branding.
/// 2. Request all required runtime permissions.
/// 3. Navigate to [CameraScreen] if permissions are granted,
///    or show an error state if mandatory permissions are denied.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  String _statusText = 'Initialising...';
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _animController.forward();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _statusText = 'Requesting permissions...');

    final granted = await PermissionHelper.requestAllPermissions();

    if (!mounted) return;

    if (granted) {
      setState(() => _statusText = 'Loading AI model...');
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CameraScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      setState(() {
        _permissionDenied = true;
        _statusText = 'Camera & microphone access required.';
      });
      if (mounted) await PermissionHelper.showSettingsIfDenied(context);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF00B4D8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.remove_red_eye_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // App name
              const Text(
                'Echo Vision',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI-Powered Assistive Technology',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 48),

              // Status
              if (!_permissionDenied) ...[
                const CircularProgressIndicator(
                  color: Color(0xFF6C63FF),
                  strokeWidth: 2,
                ),
                const SizedBox(height: 16),
              ],

              Text(
                _statusText,
                style: TextStyle(
                  color: _permissionDenied
                      ? const Color(0xFFFF5252)
                      : Colors.white54,
                  fontSize: 13,
                ),
              ),

              // Retry button if permissions denied
              if (_permissionDenied) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Settings'),
                  onPressed: () async {
                    await PermissionHelper.showSettingsIfDenied(context);
                    if (mounted) {
                      setState(() {
                        _permissionDenied = false;
                        _statusText = 'Retrying...';
                      });
                      _initApp();
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

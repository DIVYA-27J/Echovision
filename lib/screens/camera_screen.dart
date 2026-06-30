import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/detection_service.dart';
import '../services/tts_service.dart';
import '../services/speech_service.dart';
import '../services/memory_service.dart';
import '../services/location_service.dart';
import '../services/emergency_service.dart';
import '../services/settings_service.dart';
import '../widgets/detection_overlay.dart';
import '../widgets/status_bar.dart';
import '../widgets/help_button.dart';
import 'settings_screen.dart';

/// Main screen of Echo Vision.
///
/// Shows a live camera preview with:
/// - Real-time object detection overlay
/// - TTS announcements for detected objects
/// - Continuous STT listening for "Help me" voice command
/// - SOS button to trigger emergency flow
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialised = false;

  late DetectionService _detectionService;
  late TTSService _ttsService;
  late SpeechService _speechService;
  late MemoryService _memoryService;
  final LocationService _locationService = LocationService();
  final EmergencyService _emergencyService = EmergencyService();
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAll());
  }

  Future<void> _initAll() async {
    _detectionService = context.read<DetectionService>();
    _ttsService = context.read<TTSService>();
    _speechService = context.read<SpeechService>();
    _memoryService = context.read<MemoryService>();

    await _initCamera();
    await _initSpeech();

    // React to new detections
    _detectionService.addListener(_onDetection);
  }

  // ---------------------------------------------------------------------------
  // Camera Initialisation
  // ---------------------------------------------------------------------------

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      if (!mounted) return;

      _controller!.startImageStream(_processFrame);

      setState(() => _isCameraInitialised = true);
    } catch (e) {
      debugPrint('❌ Camera init error: $e');
    }
  }

  /// Passes each camera frame to [DetectionService] for inference.
  void _processFrame(CameraImage image) {
    _detectionService.detect(image);
  }

  // ---------------------------------------------------------------------------
  // Speech Initialisation
  // ---------------------------------------------------------------------------

  Future<void> _initSpeech() async {
    await _speechService.initialise();
    _speechService.onCommandDetected = _onHelpCommand;
    await _speechService.startListening();
  }

  // ---------------------------------------------------------------------------
  // Detection Listener
  // ---------------------------------------------------------------------------

  void _onDetection() {
    final label = _detectionService.currentLabel;
    if (label.isEmpty) return;

    // Announce via TTS
    _ttsService.speak(label);

    // Update session memory (location is not fetched here to preserve battery)
    _memoryService.update(label, null);
  }

  // ---------------------------------------------------------------------------
  // Emergency Flow
  // ---------------------------------------------------------------------------

  /// Called when "Help me" is detected by STT or the SOS button is tapped.
  Future<void> _onHelpCommand(String _) async {
    await _showEmergencyDialog();
  }

  Future<void> _showEmergencyDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5252), size: 28),
            SizedBox(width: 8),
            Text('Send SOS?',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'An emergency SMS will be sent to your contact with your '
              'location and the last detected object.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            if (_memoryService.hasData)
              Text(
                'Last object: ${_memoryService.lastObject}',
                style: const TextStyle(
                    color: Color(0xFF6C63FF), fontWeight: FontWeight.w600),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1744),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.send, size: 18),
            label: const Text('SEND NOW'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dispatchSOS();
    }
  }

  Future<void> _dispatchSOS() async {
    final contact = await _settingsService.getEmergencyContact();
    if (contact == null || contact.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠ No emergency contact set. Please add one in Settings.'),
          backgroundColor: Color(0xFFFF6D00),
          duration: Duration(seconds: 4),
        ),
      );
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()));
      return;
    }

    // Fetch location just-in-time
    final position = await _locationService.getCurrentLocation();
    _memoryService.update(_memoryService.lastObject ?? 'Unknown', position);

    final success = await _emergencyService.sendHelp(
      contact: contact,
      objectName: _memoryService.lastObject ?? 'Unknown',
      location: position,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '✅ SOS sent to $contact'
            : '❌ Failed to send SMS. Check permissions.'),
        backgroundColor:
            success ? const Color(0xFF00C853) : const Color(0xFFFF1744),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller!.stopImageStream();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detectionService.removeListener(_onDetection);
    _controller?.stopImageStream();
    _controller?.dispose();
    _speechService.stopListening();
    _memoryService.clear();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.remove_red_eye_rounded,
                color: Color(0xFF6C63FF), size: 22),
            SizedBox(width: 8),
            Text(
              'Echo Vision',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: _isCameraInitialised
          ? Stack(
              children: [
                // Full-screen camera preview
                SizedBox.expand(
                  child: CameraPreview(_controller!),
                ),

                // Object detection label overlay
                const DetectionOverlay(),

                // SOS button — centred at bottom
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: HelpButton(
                      onPressed: () => _showEmergencyDialog(),
                    ),
                  ),
                ),

                // Status bar at very bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: const StatusBar(),
                ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF6C63FF),
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Initialising camera...',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
    );
  }
}

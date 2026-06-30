import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/memory_service.dart';
import '../services/detection_service.dart';

/// Status bar shown at the bottom of the camera screen.
///
/// Displays the last detected object, session memory summary, and
/// model-ready indicator.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MemoryService, DetectionService>(
      builder: (context, memory, detection, _) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              // Model status indicator
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: detection.isModelLoaded
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF6D00),
                  boxShadow: [
                    BoxShadow(
                      color: detection.isModelLoaded
                          ? const Color(0xFF00E676).withOpacity(0.5)
                          : const Color(0xFFFF6D00).withOpacity(0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  detection.isModelLoaded
                      ? (memory.hasData ? memory.summary : 'Scanning...')
                      : 'Loading AI model...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

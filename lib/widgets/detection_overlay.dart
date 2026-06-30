import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/detection_service.dart';
import '../utils/constants.dart';

/// Transparent overlay that displays the current detected object label
/// and a confidence bar on top of the live camera preview.
class DetectionOverlay extends StatelessWidget {
  const DetectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DetectionService>(
      builder: (context, service, _) {
        final label = service.currentLabel;
        final confidence = service.currentConfidence;

        if (label.isEmpty) return const SizedBox.shrink();

        // Choose colour based on confidence tier
        final color = confidence >= AppConstants.highConfidenceThreshold
            ? const Color(0xFF00E676) // high — green
            : confidence >= AppConstants.announceThreshold
                ? const Color(0xFFFFD740) // medium — amber
                : const Color(0xFFFF6D00); // low — orange

        return Positioned(
          top: 40,
          left: 16,
          right: 16,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(label),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Object label
                  Row(
                    children: [
                      Icon(Icons.visibility, color: color, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: color.withOpacity(0.8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Confidence bar
                  Row(
                    children: [
                      Text(
                        '${(confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: confidence,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

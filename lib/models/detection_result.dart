/// Data model representing a single object detection result.
class DetectionResult {
  final String label;
  final double confidence;
  final DateTime detectedAt;
  final double? latitude;
  final double? longitude;

  const DetectionResult({
    required this.label,
    required this.confidence,
    required this.detectedAt,
    this.latitude,
    this.longitude,
  });

  /// Converts the detection result to a JSON-serialisable map.
  Map<String, dynamic> toJson() => {
        'label': label,
        'confidence': confidence,
        'detectedAt': detectedAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
      };

  /// Creates a [DetectionResult] from a JSON map.
  factory DetectionResult.fromJson(Map<String, dynamic> json) =>
      DetectionResult(
        label: json['label'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        detectedAt: DateTime.parse(json['detectedAt'] as String),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  /// Short human-readable summary for display or SMS.
  String get summary {
    final loc = (latitude != null && longitude != null)
        ? 'https://maps.google.com/?q=$latitude,$longitude'
        : 'Location unavailable';
    return 'Object: $label (${(confidence * 100).toStringAsFixed(0)}%) | $loc';
  }

  @override
  String toString() =>
      'DetectionResult(label: $label, confidence: $confidence, '
      'detectedAt: $detectedAt)';
}

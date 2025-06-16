class AudioResult {
  final String audioName;
  final bool isFake;
  final double confidence;
  final String uploadDate;
  final String? message;

  AudioResult({
    required this.audioName,
    required this.isFake,
    required this.confidence,
    required this.uploadDate,
    this.message,
  });

  factory AudioResult.fromJson(Map<String, dynamic> json) {
    return AudioResult(
      audioName: json['audio_name'] as String? ?? '',
      isFake: json['is_fake'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      uploadDate: json['upload_date'] as String? ?? '',
      message: json['message'] as String?,
    );
  }
}

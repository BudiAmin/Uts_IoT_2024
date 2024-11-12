class SensorData {
  final double suhu;
  final double kelembapan;
  final double kekeruhan;
  final double ph;
  final String timestamp;

  SensorData({
    required this.suhu,
    required this.kelembapan,
    required this.kekeruhan,
    required this.ph,
    required this.timestamp,
  });

  // Fungsi factory untuk membuat objek dari JSON
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      suhu: json['suhu']?.toDouble() ?? 0.0,
      kelembapan: json['kelembapan']?.toDouble() ?? 0.0,
      kekeruhan: json['kekeruhan']?.toDouble() ?? 0.0,
      ph: json['ph']?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] ?? '',
    );
  }

  // Fungsi untuk mengubah objek menjadi format JSON
  Map<String, dynamic> toJson() {
    return {
      'suhu': suhu,
      'kelembapan': kelembapan,
      'kekeruhan': kekeruhan,
      'ph': ph,
      'timestamp': timestamp,
    };
  }
}

class EmotionRecord {
  final DateTime date;
  final String emotion; // 예: 'happy', 'sad', 'angry', ...
  final String diary;

  EmotionRecord({required this.date, required this.emotion, required this.diary});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'emotion': emotion,
    'diary': diary,
  };

  factory EmotionRecord.fromJson(Map<String, dynamic> json) => EmotionRecord(
    date: DateTime.parse(json['date']),
    emotion: json['emotion'],
    diary: json['diary'],
  );
} 
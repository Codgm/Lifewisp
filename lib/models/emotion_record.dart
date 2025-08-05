import 'dart:io';

class EmotionRecord {
  final DateTime date;
  final String emotion;
  final String diary;
  final List<String> categories; // 선택된 카테고리들
  final List<String> imagePaths; // 이미지 파일 경로들

  EmotionRecord({
    required this.date,
    required this.emotion,
    required this.diary,
    this.categories = const [],
    this.imagePaths = const [],
  });

  // 복사 생성자 (수정 시 사용)
  EmotionRecord copyWith({
    DateTime? date,
    String? emotion,
    String? diary,
    List<String>? categories,
    List<String>? imagePaths,
  }) {
    return EmotionRecord(
      date: date ?? this.date,
      emotion: emotion ?? this.emotion,
      diary: diary ?? this.diary,
      categories: categories ?? this.categories,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  // JSON 변환 (저장 시 사용)
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'emotion': emotion,
      'diary': diary,
      'categories': categories,
      'imagePaths': imagePaths,
    };
  }

  // JSON에서 생성 (불러오기 시 사용)
  factory EmotionRecord.fromJson(Map<String, dynamic> json) {
    return EmotionRecord(
      date: DateTime.parse(json['date']),
      emotion: json['emotion'],
      diary: json['diary'],
      categories: List<String>.from(json['categories'] ?? []),
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
    );
  }

  @override
  String toString() {
    return 'EmotionRecord{date: $date, emotion: $emotion, diary: $diary, categories: $categories, imagePaths: $imagePaths}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmotionRecord &&
        other.date == date &&
        other.emotion == emotion &&
        other.diary == diary;
  }

  @override
  int get hashCode {
    return date.hashCode ^ emotion.hashCode ^ diary.hashCode;
  }
}
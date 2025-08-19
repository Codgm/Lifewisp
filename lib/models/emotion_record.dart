import 'dart:io';

class EmotionRecord {
  final String id; // 고유 식별자 추가
  final DateTime date;
  final String emotion;
  final String diary;
  final List<String> categories; // 선택된 카테고리들
  final List<String> imagePaths; // 이미지 파일 경로들
  final DateTime createdAt; // 생성 시간
  final DateTime updatedAt; // 수정 시간
  final bool isSynced; // 클라우드 동기화 상태

  EmotionRecord({
    String? id,
    required this.date,
    required this.emotion,
    required this.diary,
    this.categories = const [],
    this.imagePaths = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // 복사 생성자 (수정 시 사용)
  EmotionRecord copyWith({
    String? id,
    DateTime? date,
    String? emotion,
    String? diary,
    List<String>? categories,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return EmotionRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      emotion: emotion ?? this.emotion,
      diary: diary ?? this.diary,
      categories: categories ?? this.categories,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // JSON 변환 (저장 시 사용)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'emotion': emotion,
      'diary': diary,
      'categories': categories,
      'imagePaths': imagePaths,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  // Firestore용 JSON 변환 (이미지 경로 제외)
  Map<String, dynamic> toFirestoreJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'emotion': emotion,
      'diary': diary,
      'categories': categories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'hasImages': imagePaths.isNotEmpty,
      'imageCount': imagePaths.length,
    };
  }

  // JSON에서 생성 (불러오기 시 사용)
  factory EmotionRecord.fromJson(Map<String, dynamic> json) {
    return EmotionRecord(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.parse(json['date']),
      emotion: json['emotion'],
      diary: json['diary'],
      categories: List<String>.from(json['categories'] ?? []),
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      createdAt: json['createdAt'] != null ? 
                 DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? 
                 DateTime.parse(json['updatedAt']) : DateTime.now(),
      isSynced: json['isSynced'] ?? false,
    );
  }

  // Firestore에서 생성 (이미지 경로는 빈 배열로 설정)
  factory EmotionRecord.fromFirestore(Map<String, dynamic> json) {
    return EmotionRecord(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.parse(json['date']),
      emotion: json['emotion'],
      diary: json['diary'],
      categories: List<String>.from(json['categories'] ?? []),
      imagePaths: const [], // Firestore에는 이미지 경로를 저장하지 않음
      createdAt: json['createdAt'] != null ? 
                 DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? 
                 DateTime.parse(json['updatedAt']) : DateTime.now(),
      isSynced: true, // Firestore에서 가져온 데이터는 동기화됨
    );
  }

  @override
  String toString() {
    return 'EmotionRecord{id: $id, date: $date, emotion: $emotion, diary: $diary, categories: $categories, imagePaths: $imagePaths, isSynced: $isSynced}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmotionRecord &&
        other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
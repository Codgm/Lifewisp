class Goal {
  final String id;
  final String title;
  final String description;
  final String category; // '감정관리', '습관형성', '성장목표', '자기돌봄'
  final DateTime createdAt;
  final DateTime updatedAt; // 수정 시간 추가
  final DateTime? targetDate;
  final double targetValue; // 목표 수치 (예: 80% 긍정적 감정)
  final double currentValue; // 현재 진행률
  final String unit; // 단위 (%, 횟수, 일수 등)
  final bool isActive;
  final List<String> actionSteps; // 구체적 실행 단계들
  final String status; // '진행중', '완료', '지연', '포기'
  final String userId; // 사용자 ID 추가
  final bool isSynced; // 동기화 상태 추가

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.targetDate,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.isActive,
    required this.actionSteps,
    required this.status,
    required this.userId,
    this.isSynced = false,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? targetDate,
    double? targetValue,
    double? currentValue,
    String? unit,
    bool? isActive,
    List<String>? actionSteps,
    String? status,
    String? userId,
    bool? isSynced,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      targetDate: targetDate ?? this.targetDate,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      actionSteps: actionSteps ?? this.actionSteps,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  double get progressPercentage => (currentValue / targetValue * 100).clamp(0.0, 100.0);
  
  bool get isCompleted => currentValue >= targetValue;
  
  bool get isOverdue => targetDate != null && DateTime.now().isAfter(targetDate!) && !isCompleted;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'isActive': isActive,
      'actionSteps': actionSteps,
      'status': status,
      'userId': userId,
      'isSynced': isSynced,
    };
  }

  // Firestore용 JSON (클라우드 저장용)
  Map<String, dynamic> toFirestoreJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'isActive': isActive,
      'actionSteps': actionSteps,
      'status': status,
      'userId': userId,
      // isSynced는 클라우드에 저장하지 않음
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      targetValue: (json['targetValue'] ?? 0.0).toDouble(),
      currentValue: (json['currentValue'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      isActive: json['isActive'] ?? true,
      actionSteps: json['actionSteps'] != null ? List<String>.from(json['actionSteps']) : [],
      status: json['status'] ?? '진행중',
      userId: json['userId'] ?? '', // 기존 데이터 호환성을 위해 기본값 제공
      isSynced: json['isSynced'] ?? false,
    );
  }

  // Firestore에서 불러올 때 사용
  factory Goal.fromFirestore(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      targetValue: (json['targetValue'] ?? 0.0).toDouble(),
      currentValue: (json['currentValue'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      isActive: json['isActive'] ?? true,
      actionSteps: json['actionSteps'] != null ? List<String>.from(json['actionSteps']) : [],
      status: json['status'] ?? '진행중',
      userId: json['userId'] ?? '',
      isSynced: true, // 클라우드에서 불러온 데이터는 동기화된 상태
    );
  }

  // 목표 유효성 검증
  bool get isValid {
    return id.isNotEmpty && 
           title.isNotEmpty && 
           userId.isNotEmpty &&
           targetValue > 0 &&
           currentValue >= 0;
  }

  // 디버그용 문자열
  @override
  String toString() {
    return 'Goal(id: $id, title: $title, userId: $userId, progress: ${progressPercentage.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Goal &&
        other.id == id &&
        other.userId == userId &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ updatedAt.hashCode;
  }
}
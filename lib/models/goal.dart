class Goal {
  final String id;
  final String title;
  final String description;
  final String category; // '감정관리', '습관형성', '성장목표', '자기돌봄'
  final DateTime createdAt;
  final DateTime? targetDate;
  final double targetValue; // 목표 수치 (예: 80% 긍정적 감정)
  final double currentValue; // 현재 진행률
  final String unit; // 단위 (%, 횟수, 일수 등)
  final bool isActive;
  final List<String> actionSteps; // 구체적 실행 단계들
  final String status; // '진행중', '완료', '지연', '포기'

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.targetDate,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.isActive,
    required this.actionSteps,
    required this.status,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? createdAt,
    DateTime? targetDate,
    double? targetValue,
    double? currentValue,
    String? unit,
    bool? isActive,
    List<String>? actionSteps,
    String? status,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      actionSteps: actionSteps ?? this.actionSteps,
      status: status ?? this.status,
    );
  }

  double get progressPercentage => (currentValue / targetValue * 100).clamp(0.0, 100.0);
  
  bool get isCompleted => currentValue >= targetValue;
  
  bool get isOverdue => targetDate != null && DateTime.now().isAfter(targetDate!);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'isActive': isActive,
      'actionSteps': actionSteps,
      'status': status,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      targetValue: json['targetValue'].toDouble(),
      currentValue: json['currentValue'].toDouble(),
      unit: json['unit'],
      isActive: json['isActive'],
      actionSteps: List<String>.from(json['actionSteps']),
      status: json['status'],
    );
  }
} 
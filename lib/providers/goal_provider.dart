import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/emotion_record.dart';
import '../services/ai_goal_service.dart';
import 'dart:math';

class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  final AIGoalService _aiGoalService = AIGoalService();

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((goal) => goal.isActive).toList();
  List<Goal> get completedGoals => _goals.where((goal) => goal.isCompleted).toList();

  // 목표 생성 (AI 추천 또는 사용자 직접 생성)
  Future<Goal> createGoal({
    required String title,
    required String description,
    required String category,
    required double targetValue,
    required String unit,
    DateTime? targetDate,
    List<String>? actionSteps,
  }) async {
    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      createdAt: DateTime.now(),
      targetDate: targetDate,
      targetValue: targetValue,
      currentValue: 0.0,
      unit: unit,
      isActive: true,
      actionSteps: actionSteps ?? [],
      status: '진행중',
    );

    _goals.add(goal);
    notifyListeners();
    return goal;
  }

  // AI 추천 목표 생성
  Future<List<Goal>> generateAIRecommendedGoals(List<EmotionRecord> records) async {
    try {
      final recommendations = await _aiGoalService.generateGoalRecommendations(records);
      final goals = <Goal>[];

      for (final recommendation in recommendations) {
        final goal = await createGoal(
          title: recommendation['title'],
          description: recommendation['description'],
          category: recommendation['category'],
          targetValue: recommendation['targetValue'].toDouble(),
          unit: recommendation['unit'],
          targetDate: recommendation['targetDate'] != null 
              ? DateTime.parse(recommendation['targetDate']) 
              : null,
          actionSteps: List<String>.from(recommendation['actionSteps']),
        );
        goals.add(goal);
      }

      return goals;
    } catch (e) {
      print('AI 목표 추천 오류: $e');
      return [];
    }
  }

  // 목표 진행률 업데이트 (감정 기록 기반)
  void updateGoalProgress(List<EmotionRecord> records) {
    for (final goal in _goals) {
      if (!goal.isActive) continue;

      double newValue = 0.0;
      
      switch (goal.category) {
        case '감정관리':
          newValue = _calculateEmotionManagementProgress(goal, records);
          break;
        case '습관형성':
          newValue = _calculateHabitFormationProgress(goal, records);
          break;
        case '성장목표':
          newValue = _calculateGrowthProgress(goal, records);
          break;
        case '자기돌봄':
          newValue = _calculateSelfCareProgress(goal, records);
          break;
      }

      final updatedGoal = goal.copyWith(
        currentValue: newValue,
        status: newValue >= goal.targetValue ? '완료' : 
                goal.isOverdue ? '지연' : '진행중',
      );

      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
      }
    }
    
    notifyListeners();
  }

  // 감정 관리 목표 진행률 계산
  double _calculateEmotionManagementProgress(Goal goal, List<EmotionRecord> records) {
    if (records.isEmpty) return 0.0;

    final recentRecords = records.where((r) => 
      r.date.isAfter(DateTime.now().subtract(const Duration(days: 30)))
    ).toList();

    if (recentRecords.isEmpty) return 0.0;

    final positiveEmotions = ['happy', 'love', 'calm', 'excited', 'confidence'];
    final positiveCount = recentRecords.where((r) => 
      positiveEmotions.contains(r.emotion)
    ).length;

    return (positiveCount / recentRecords.length * 100);
  }

  // 습관 형성 목표 진행률 계산
  double _calculateHabitFormationProgress(Goal goal, List<EmotionRecord> records) {
    if (records.isEmpty) return 0.0;

    final recentRecords = records.where((r) => 
      r.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).toList();

    return recentRecords.length.toDouble();
  }

  // 성장 목표 진행률 계산
  double _calculateGrowthProgress(Goal goal, List<EmotionRecord> records) {
    if (records.length < 2) return 0.0;

    // 감정 다양성 계산
    final uniqueEmotions = records.map((r) => r.emotion).toSet().length;
    return uniqueEmotions.toDouble();
  }

  // 자기 돌봄 목표 진행률 계산
  double _calculateSelfCareProgress(Goal goal, List<EmotionRecord> records) {
    if (records.isEmpty) return 0.0;

    // 자기 돌봄 관련 감정 기록 수
    final selfCareEmotions = ['calm', 'love', 'confidence'];
    final selfCareCount = records.where((r) => 
      selfCareEmotions.contains(r.emotion)
    ).length;

    return selfCareCount.toDouble();
  }

  // 목표 수정
  void updateGoal(Goal updatedGoal) {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      notifyListeners();
    }
  }

  // 목표 삭제
  void deleteGoal(String goalId) {
    _goals.removeWhere((goal) => goal.id == goalId);
    notifyListeners();
  }

  // 목표 활성화/비활성화
  void toggleGoalActive(String goalId) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(isActive: !_goals[index].isActive);
      notifyListeners();
    }
  }

  // 목표 달성 알림 체크
  List<Goal> getGoalsNeedingNotification() {
    return _goals.where((goal) => 
      goal.isActive && 
      (goal.isCompleted || goal.isOverdue)
    ).toList();
  }

  // 통계 정보
  Map<String, dynamic> getGoalStatistics() {
    final totalGoals = _goals.length;
    final completedGoals = _goals.where((g) => g.isCompleted).length;
    final activeGoals = _goals.where((g) => g.isActive).length;
    final overdueGoals = _goals.where((g) => g.isOverdue).length;

    return {
      'total': totalGoals,
      'completed': completedGoals,
      'active': activeGoals,
      'overdue': overdueGoals,
      'completionRate': totalGoals > 0 ? (completedGoals / totalGoals * 100) : 0.0,
    };
  }
} 
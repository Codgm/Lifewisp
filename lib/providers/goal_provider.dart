import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/emotion_record.dart';
import '../services/ai_goal_service.dart';
import '../services/local_storage_service.dart';
import '../services/cloud_storage_service.dart';
import 'dart:math';
import 'dart:convert';

class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  final AIGoalService _aiGoalService = AIGoalService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final CloudStorageService _cloudStorageService = CloudStorageService();

  String? _currentUserId;
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((goal) => goal.isActive).toList();
  List<Goal> get completedGoals => _goals.where((goal) => goal.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;

  // 사용자 초기화 - 필수
  Future<void> initializeUser(String userId) async {
    if (_currentUserId == userId && _goals.isNotEmpty) return;

    _isLoading = true;
    _currentUserId = userId;
    notifyListeners();

    try {
      await _loadGoalsForUser(userId);
    } catch (e) {
      print('목표 초기화 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자별 목표 불러오기
  Future<void> _loadGoalsForUser(String userId) async {
    try {
      final localGoals = await _loadLocalGoals(userId);
      _goals = localGoals;
      notifyListeners();

      if (await _cloudStorageService.isConnected()) {
        final cloudGoals = await _loadCloudGoals(userId);
        if (cloudGoals.isNotEmpty) {
          _goals = await _mergeGoals(localGoals, cloudGoals);
          await _saveLocalGoals(userId);
          notifyListeners();
        }
      }
    } catch (e) {
      print('사용자별 목표 불러오기 실패: $e');
    }
  }

  // 로컬 목표 불러오기
  Future<List<Goal>> _loadLocalGoals(String userId) async {
    try {
      final goalData = await _localStorageService.getUserData(userId, 'goals');
      if (goalData != null && goalData.isNotEmpty) {
        final List<dynamic> goalList = jsonDecode(goalData);
        return goalList.map((json) => Goal.fromJson(json)).toList();
      }
    } catch (e) {
      print('로컬 목표 불러오기 실패: $e');
    }
    return [];
  }

  // 클라우드 목표 불러오기
  Future<List<Goal>> _loadCloudGoals(String userId) async {
    try {
      return await _cloudStorageService.loadGoals(userId);
    } catch (e) {
      print('클라우드 목표 불러오기 실패: $e');
      return [];
    }
  }

  // 로컬 목표 저장
  Future<void> _saveLocalGoals(String userId) async {
    try {
      final goalJson = jsonEncode(_goals.map((goal) => goal.toJson()).toList());
      await _localStorageService.saveUserData(userId, 'goals', goalJson);
    } catch (e) {
      print('로컬 목표 저장 실패: $e');
    }
  }

  // 클라우드 목표 저장
  Future<void> _saveCloudGoals(String userId) async {
    try {
      if (await _cloudStorageService.isConnected()) {
        await _cloudStorageService.saveGoals(_goals, userId);
      }
    } catch (e) {
      print('클라우드 목표 저장 실패: $e');
    }
  }

  // 목표 병합 로직
  Future<List<Goal>> _mergeGoals(List<Goal> localGoals, List<Goal> cloudGoals) async {
    final Map<String, Goal> mergedMap = {};

    for (final goal in localGoals) {
      mergedMap[goal.id] = goal;
    }

    for (final cloudGoal in cloudGoals) {
      final localGoal = mergedMap[cloudGoal.id];

      if (localGoal == null) {
        mergedMap[cloudGoal.id] = cloudGoal;
      } else if (cloudGoal.updatedAt != null && localGoal.updatedAt != null) {
        if (cloudGoal.updatedAt!.isAfter(localGoal.updatedAt!)) {
          mergedMap[cloudGoal.id] = cloudGoal;
        }
      }
    }

    return mergedMap.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 목표 생성 - null 반환 오류 수정
  Future<Goal?> createGoal({
    required String title,
    required String description,
    required String category,
    required double targetValue,
    required String unit,
    DateTime? targetDate,
    List<String>? actionSteps,
  }) async {
    if (_currentUserId == null) {
      print('에러: 사용자가 초기화되지 않았습니다.');
      return null;
    }

    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      targetDate: targetDate,
      targetValue: targetValue,
      currentValue: 0.0,
      unit: unit,
      isActive: true,
      actionSteps: actionSteps ?? [],
      status: '진행중',
      userId: _currentUserId!, // 사용자 ID 추가
    );

    _goals.add(goal);

    // 저장
    await _saveLocalGoals(_currentUserId!);
    await _saveCloudGoals(_currentUserId!);

    notifyListeners();
    return goal;
  }

  // AI 추천 목표 생성
  Future<List<Goal>> generateAIRecommendedGoals(List<EmotionRecord> records) async {
    if (_currentUserId == null) {
      print('에러: 사용자가 초기화되지 않았습니다.');
      return [];
    }

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
        if (goal != null) {
          goals.add(goal);
        }
      }

      return goals;
    } catch (e) {
      print('AI 목표 추천 오류: $e');
      return [];
    }
  }

  // 목표 진행률 업데이트
  Future<void> updateGoalProgress(List<EmotionRecord> records) async {
    if (_currentUserId == null) return;

    bool hasUpdates = false;

    for (int i = 0; i < _goals.length; i++) {
      final goal = _goals[i];
      if (!goal.isActive || goal.userId != _currentUserId) continue;

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

      if (newValue != goal.currentValue) {
        _goals[i] = goal.copyWith(
          currentValue: newValue,
          status: newValue >= goal.targetValue ? '완료' :
          goal.isOverdue ? '지연' : '진행중',
          updatedAt: DateTime.now(),
        );
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      await _saveLocalGoals(_currentUserId!);
      await _saveCloudGoals(_currentUserId!);
      notifyListeners();
    }
  }

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

  double _calculateHabitFormationProgress(Goal goal, List<EmotionRecord> records) {
    if (records.isEmpty) return 0.0;

    final recentRecords = records.where((r) =>
        r.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).toList();

    return recentRecords.length.toDouble();
  }

  double _calculateGrowthProgress(Goal goal, List<EmotionRecord> records) {
    if (records.length < 2) return 0.0;

    final uniqueEmotions = records.map((r) => r.emotion).toSet().length;
    return uniqueEmotions.toDouble();
  }

  double _calculateSelfCareProgress(Goal goal, List<EmotionRecord> records) {
    if (records.isEmpty) return 0.0;

    final selfCareEmotions = ['calm', 'love', 'confidence'];
    final selfCareCount = records.where((r) =>
        selfCareEmotions.contains(r.emotion)
    ).length;

    return selfCareCount.toDouble();
  }

  // 목표 수정
  Future<void> updateGoal(Goal updatedGoal) async {
    if (_currentUserId == null || updatedGoal.userId != _currentUserId) {
      print('에러: 권한이 없습니다.');
      return;
    }

    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal.copyWith(updatedAt: DateTime.now());

      await _saveLocalGoals(_currentUserId!);
      await _saveCloudGoals(_currentUserId!);
      notifyListeners();
    }
  }

  // 목표 삭제 - null 체크 수정
  Future<void> deleteGoal(String goalId) async {
    if (_currentUserId == null) return;

    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) return;

    final goalToDelete = _goals[goalIndex];
    if (goalToDelete.userId != _currentUserId) {
      print('에러: 권한이 없습니다.');
      return;
    }

    _goals.removeWhere((goal) => goal.id == goalId);

    await _saveLocalGoals(_currentUserId!);
    await _saveCloudGoals(_currentUserId!);
    notifyListeners();
  }

  // 목표 활성화/비활성화
  Future<void> toggleGoalActive(String goalId) async {
    if (_currentUserId == null) return;

    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      if (goal.userId != _currentUserId) {
        print('에러: 권한이 없습니다.');
        return;
      }

      _goals[index] = goal.copyWith(
        isActive: !goal.isActive,
        updatedAt: DateTime.now(),
      );

      await _saveLocalGoals(_currentUserId!);
      await _saveCloudGoals(_currentUserId!);
      notifyListeners();
    }
  }

  // 사용자 변경 시 데이터 클리어
  void clearGoalsForUserChange() {
    _goals.clear();
    _currentUserId = null;
    notifyListeners();
  }

  // 현재 사용자의 목표만 반환하는 필터된 getter들
  List<Goal> get currentUserGoals => _goals.where((goal) =>
  _currentUserId != null && goal.userId == _currentUserId
  ).toList();

  List<Goal> get currentUserActiveGoals => currentUserGoals.where((goal) => goal.isActive).toList();
  List<Goal> get currentUserCompletedGoals => currentUserGoals.where((goal) => goal.isCompleted).toList();

  // 목표 달성 알림 체크
  List<Goal> getGoalsNeedingNotification() {
    return currentUserGoals.where((goal) =>
    goal.isActive &&
        (goal.isCompleted || goal.isOverdue)
    ).toList();
  }

  // 통계 정보
  Map<String, dynamic> getGoalStatistics() {
    final userGoals = currentUserGoals;
    final totalGoals = userGoals.length;
    final completedGoals = userGoals.where((g) => g.isCompleted).length;
    final activeGoals = userGoals.where((g) => g.isActive).length;
    final overdueGoals = userGoals.where((g) => g.isOverdue).length;

    return {
      'total': totalGoals,
      'completed': completedGoals,
      'active': activeGoals,
      'overdue': overdueGoals,
      'completionRate': totalGoals > 0 ? (completedGoals / totalGoals * 100) : 0.0,
      'userId': _currentUserId,
    };
  }

  // 동기화 메서드
  Future<void> syncWithCloud() async {
    if (_currentUserId == null) return;

    try {
      if (await _cloudStorageService.isConnected()) {
        final cloudGoals = await _loadCloudGoals(_currentUserId!);
        final localGoals = _goals;

        _goals = await _mergeGoals(localGoals, cloudGoals);
        await _saveLocalGoals(_currentUserId!);
        await _saveCloudGoals(_currentUserId!);

        notifyListeners();
      }
    } catch (e) {
      print('목표 동기화 실패: $e');
    }
  }
}
// utils/growth_badge_system.dart
import 'package:flutter/material.dart';
import '../models/emotion_record.dart';
import '../utils/theme.dart';

enum BadgeType {
  consistentRecording,
  emotionExplorer,
  growthMindset,
  weeklyGoal,
  monthlyChampion,
  diverseEmotion,
  positiveStreak,
  selfReflection,
  creativeWriter,
  photoMemory,
}

class GrowthBadge {
  final BadgeType type;
  final String emoji;
  final String title;
  final String description;
  final String detailDescription;
  final bool isAchieved;

  const GrowthBadge({
    required this.type,
    required this.emoji,
    required this.title,
    required this.description,
    required this.detailDescription,
    required this.isAchieved,
  });
}

class GrowthBadgeSystem {
  static List<GrowthBadge> getBadges(List<EmotionRecord> records) {
    final badges = <GrowthBadge>[];

    // 1. 꾸준한 기록 배지 (7일 연속)
    badges.add(GrowthBadge(
      type: BadgeType.consistentRecording,
      emoji: '🎯',
      title: '꾸준한 기록',
      description: '7일 연속 기록',
      detailDescription: '7일 동안 매일 감정을 기록했어요',
      isAchieved: _checkConsistentRecording(records, 7),
    ));

    // 2. 감정 탐험가 배지 (5가지 이상 다른 감정)
    badges.add(GrowthBadge(
      type: BadgeType.emotionExplorer,
      emoji: '🌟',
      title: '감정 탐험가',
      description: '다양한 감정 경험',
      detailDescription: '5가지 이상의 다양한 감정을 경험했어요',
      isAchieved: _checkEmotionDiversity(records, 5),
    ));

    // 3. 성장하는 마음 배지 (긍정적 감정 비율)
    badges.add(GrowthBadge(
      type: BadgeType.growthMindset,
      emoji: '💪',
      title: '성장하는 마음',
      description: '긍정적 변화',
      detailDescription: '긍정적인 감정의 비율이 높아요',
      isAchieved: _checkPositiveGrowth(records),
    ));

    // 4. 주간 목표 달성 배지 (일주일에 5회 이상)
    badges.add(GrowthBadge(
      type: BadgeType.weeklyGoal,
      emoji: '📅',
      title: '주간 달성',
      description: '주 5회 이상 기록',
      detailDescription: '한 주에 5번 이상 감정을 기록했어요',
      isAchieved: _checkWeeklyGoal(records),
    ));

    // 5. 월간 챔피언 배지 (한 달에 20회 이상)
    badges.add(GrowthBadge(
      type: BadgeType.monthlyChampion,
      emoji: '🏆',
      title: '월간 챔피언',
      description: '월 20회 이상 기록',
      detailDescription: '한 달에 20번 이상 감정을 기록했어요',
      isAchieved: _checkMonthlyChampion(records),
    ));

    // 6. 창작 작가 배지 (긴 일기 10개 이상)
    badges.add(GrowthBadge(
      type: BadgeType.creativeWriter,
      emoji: '✍️',
      title: '창작 작가',
      description: '상세한 일기 작성',
      detailDescription: '100자 이상의 긴 일기를 10번 이상 작성했어요',
      isAchieved: _checkCreativeWriter(records),
    ));

    // 7. 추억 수집가 배지 (사진 포함 기록 5개 이상)
    badges.add(GrowthBadge(
      type: BadgeType.photoMemory,
      emoji: '📸',
      title: '추억 수집가',
      description: '사진으로 기록',
      detailDescription: '사진과 함께 감정을 5번 이상 기록했어요',
      isAchieved: _checkPhotoMemory(records),
    ));

    // 8. 성찰하는 마음 배지 (카테고리 태그 사용)
    badges.add(GrowthBadge(
      type: BadgeType.selfReflection,
      emoji: '🧘',
      title: '성찰하는 마음',
      description: '깊이 있는 기록',
      detailDescription: '카테고리 태그를 활용해 감정을 세심하게 기록했어요',
      isAchieved: _checkSelfReflection(records),
    ));

    return badges;
  }

  // 연속 기록 체크
  static bool _checkConsistentRecording(List<EmotionRecord> records, int days) {
    if (records.length < days) return false;

    final sortedRecords = records.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    int consecutiveDays = 1;
    for (int i = 1; i < sortedRecords.length; i++) {
      final prevDate = sortedRecords[i - 1].date;
      final currentDate = sortedRecords[i].date;

      if (currentDate.difference(prevDate).inDays == 1) {
        consecutiveDays++;
        if (consecutiveDays >= days) return true;
      } else {
        consecutiveDays = 1;
      }
    }

    return consecutiveDays >= days;
  }

  // 감정 다양성 체크
  static bool _checkEmotionDiversity(List<EmotionRecord> records, int minTypes) {
    final emotions = records.map((r) => r.emotion).toSet();
    return emotions.length >= minTypes;
  }

  // 긍정적 성장 체크
  static bool _checkPositiveGrowth(List<EmotionRecord> records) {
    if (records.length < 10) return false;

    final positiveEmotions = ['happy', 'excited', 'love', 'calm'];
    final positiveCount = records
        .where((r) => positiveEmotions.contains(r.emotion))
        .length;

    return (positiveCount / records.length) > 0.6; // 60% 이상 긍정적
  }

  // 주간 목표 체크
  static bool _checkWeeklyGoal(List<EmotionRecord> records) {
    if (records.isEmpty) return false;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));

    final weekRecords = records.where((r) {
      return r.date.isAfter(weekStart.subtract(Duration(days: 1))) &&
          r.date.isBefore(weekEnd.add(Duration(days: 1)));
    }).toList();

    return weekRecords.length >= 5;
  }

  // 월간 챔피언 체크
  static bool _checkMonthlyChampion(List<EmotionRecord> records) {
    if (records.length < 20) return false;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final monthRecords = records.where((r) {
      return r.date.isAfter(monthStart.subtract(Duration(days: 1))) &&
          r.date.isBefore(monthEnd.add(Duration(days: 1)));
    }).toList();

    return monthRecords.length >= 20;
  }

  // 창작 작가 체크
  static bool _checkCreativeWriter(List<EmotionRecord> records) {
    final longDiaries = records
        .where((r) => r.diary.length >= 100)
        .toList();

    return longDiaries.length >= 10;
  }

  // 추억 수집가 체크
  static bool _checkPhotoMemory(List<EmotionRecord> records) {
    final photoRecords = records
        .where((r) => r.imagePaths != null && r.imagePaths!.isNotEmpty)
        .toList();

    return photoRecords.length >= 5;
  }

  // 성찰하는 마음 체크
  static bool _checkSelfReflection(List<EmotionRecord> records) {
    final categoryRecords = records
        .where((r) => r.categories != null && r.categories!.isNotEmpty)
        .toList();

    return categoryRecords.length >= 10;
  }

  // 배지 달성률 계산
  static double getAchievementRate(List<EmotionRecord> records) {
    final badges = getBadges(records);
    final achievedCount = badges.where((b) => b.isAchieved).length;
    return achievedCount / badges.length;
  }

  // 다음 달성 가능한 배지 추천
  static List<GrowthBadge> getNextAchievableBadges(List<EmotionRecord> records) {
    final allBadges = getBadges(records);
    return allBadges.where((badge) => !badge.isAchieved).take(3).toList();
  }
}
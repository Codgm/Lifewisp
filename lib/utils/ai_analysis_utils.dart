import 'package:flutter/material.dart';
import '../models/emotion_record.dart';

class AIAnalysisUtils {
  /// 감정 패턴 분석
  static Map<String, dynamic> analyzeEmotionPatterns(List<EmotionRecord> records) {
    if (records.isEmpty) {
      return {
        'dominantEmotion': 'none',
        'emotionStability': 0.0,
        'weeklyPattern': {
          'dominantEmotions': <String, String>{},
          'recordCounts': <String, int>{},
        },
        'timePattern': {
          'dominantEmotions': <String, String>{},
          'recordCounts': <String, int>{},
        },
        'growthTrend': 'stable',
        'insights': ['기록된 감정이 없습니다.'],
        'totalRecords': 0,
        'emotionCounts': <String, int>{},
      };
    }

    // 감정별 빈도 분석
    final Map<String, int> emotionCounts = {};
    for (final record in records) {
      emotionCounts[record.emotion] = (emotionCounts[record.emotion] ?? 0) + 1;
    }

    // 주요 감정 찾기
    String dominantEmotion = 'none';
    int maxCount = 0;
    emotionCounts.forEach((emotion, count) {
      if (count > maxCount) {
        dominantEmotion = emotion;
        maxCount = count;
      }
    });

    // 감정 안정성 계산 (연속된 같은 감정의 비율)
    double emotionStability = _calculateEmotionStability(records);

    // 주간 패턴 분석
    Map<String, dynamic> weeklyPattern = _analyzeWeeklyPattern(records);

    // 시간대별 패턴 분석
    Map<String, dynamic> timePattern = _analyzeTimePattern(records);

    // 성장 트렌드 분석
    String growthTrend = _analyzeGrowthTrend(records);

    // 인사이트 생성
    List<String> insights = _generateInsights(
      dominantEmotion,
      emotionStability,
      weeklyPattern,
      timePattern,
      growthTrend,
      records.length,
    );

    return {
      'dominantEmotion': dominantEmotion,
      'emotionStability': emotionStability,
      'weeklyPattern': weeklyPattern,
      'timePattern': timePattern,
      'growthTrend': growthTrend,
      'insights': insights,
      'totalRecords': records.length,
      'emotionCounts': emotionCounts,
    };
  }

  /// 감정 안정성 계산
  static double _calculateEmotionStability(List<EmotionRecord> records) {
    if (records.length < 2) return 0.0;

    int consecutiveCount = 0;
    int totalConsecutive = 0;
    String? previousEmotion;

    for (final record in records) {
      if (previousEmotion == null) {
        previousEmotion = record.emotion;
        consecutiveCount = 1;
      } else if (record.emotion == previousEmotion) {
        consecutiveCount++;
      } else {
        if (consecutiveCount > 1) {
          totalConsecutive += consecutiveCount;
        }
        consecutiveCount = 1;
        previousEmotion = record.emotion;
      }
    }

    if (consecutiveCount > 1) {
      totalConsecutive += consecutiveCount;
    }

    return totalConsecutive / records.length;
  }

  /// 주간 패턴 분석 - NULL 안전성 개선
  static Map<String, dynamic> _analyzeWeeklyPattern(List<EmotionRecord> records) {
    final Map<int, Map<String, int>> weeklyData = {};

    for (final record in records) {
      final weekday = record.date.weekday;
      weeklyData.putIfAbsent(weekday, () => <String, int>{});

      weeklyData[weekday]![record.emotion] =
          (weeklyData[weekday]![record.emotion] ?? 0) + 1;
    }

    // 각 요일별 주요 감정 찾기 - 명시적 타입 지정
    final Map<String, String> dominantEmotions = <String, String>{};
    final Map<String, int> recordCounts = <String, int>{};

    if (weeklyData.isNotEmpty) {
      weeklyData.forEach((weekday, emotions) {
        String dominant = 'none';
        int maxCount = 0;

        emotions.forEach((emotion, count) {
          if (count > maxCount) {
            dominant = emotion;
            maxCount = count;
          }
        });

        final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
        if (weekday >= 1 && weekday <= 7) {
          final dayName = dayNames[weekday - 1];
          dominantEmotions[dayName] = dominant;
          recordCounts[dayName] = emotions.values.fold(0, (sum, count) => sum + count);
        }
      });
    }

    return {
      'dominantEmotions': dominantEmotions,
      'recordCounts': recordCounts,
    };
  }

  /// 시간대별 패턴 분석 - NULL 안전성 개선
  static Map<String, dynamic> _analyzeTimePattern(List<EmotionRecord> records) {
    final Map<String, Map<String, int>> timeData = {};

    for (final record in records) {
      final hour = record.date.hour;
      String timeSlot;

      if (hour < 6) timeSlot = '새벽 (00-06)';
      else if (hour < 12) timeSlot = '오전 (06-12)';
      else if (hour < 18) timeSlot = '오후 (12-18)';
      else timeSlot = '저녁 (18-24)';

      timeData.putIfAbsent(timeSlot, () => <String, int>{});

      timeData[timeSlot]![record.emotion] =
          (timeData[timeSlot]![record.emotion] ?? 0) + 1;
    }

    // 각 시간대별 주요 감정 찾기 - 명시적 타입 지정
    final Map<String, String> dominantEmotions = <String, String>{};
    final Map<String, int> recordCounts = <String, int>{};

    if (timeData.isNotEmpty) {
      timeData.forEach((timeSlot, emotions) {
        String dominant = 'none';
        int maxCount = 0;

        emotions.forEach((emotion, count) {
          if (count > maxCount) {
            dominant = emotion;
            maxCount = count;
          }
        });

        dominantEmotions[timeSlot] = dominant;
        recordCounts[timeSlot] = emotions.values.fold(0, (sum, count) => sum + count);
      });
    }

    return {
      'dominantEmotions': dominantEmotions,
      'recordCounts': recordCounts,
    };
  }

  /// 성장 트렌드 분석
  static String _analyzeGrowthTrend(List<EmotionRecord> records) {
    if (records.length < 7) return 'stable';

    // 최근 7일과 그 이전 7일 비교
    final now = DateTime.now();
    final recentRecords = records.where((r) =>
        r.date.isAfter(now.subtract(const Duration(days: 7)))).toList();

    final previousRecords = records.where((r) =>
    r.date.isAfter(now.subtract(const Duration(days: 14))) &&
        r.date.isBefore(now.subtract(const Duration(days: 7)))).toList();

    if (recentRecords.isEmpty || previousRecords.isEmpty) return 'stable';

    // 긍정적 감정 비율 계산
    final positiveEmotions = ['happy', 'love', 'calm', 'excited', 'confidence'];

    final recentPositive = recentRecords.where((r) =>
        positiveEmotions.contains(r.emotion)).length;
    final previousPositive = previousRecords.where((r) =>
        positiveEmotions.contains(r.emotion)).length;

    final recentRatio = recentPositive / recentRecords.length;
    final previousRatio = previousPositive / previousRecords.length;

    if (recentRatio > previousRatio + 0.1) return 'improving';
    if (recentRatio < previousRatio - 0.1) return 'declining';
    return 'stable';
  }

  /// AI 인사이트 생성 - NULL 안전성 개선
  static List<String> _generateInsights(
      String dominantEmotion,
      double emotionStability,
      Map<String, dynamic> weeklyPattern,
      Map<String, dynamic> timePattern,
      String growthTrend,
      int totalRecords,
      ) {
    final List<String> insights = [];

    // 주요 감정 인사이트
    if (dominantEmotion != 'none') {
      final emotionMessages = {
        'happy': '당신은 대체로 행복한 감정을 많이 경험하고 있어요! 🌟',
        'sad': '슬픈 감정이 자주 나타나고 있어요. 마음 케어가 필요할 수 있어요 💙',
        'angry': '분노 감정이 자주 나타나고 있어요. 스트레스 관리가 도움이 될 수 있어요 🔥',
        'anxious': '불안한 감정이 자주 나타나고 있어요. 마음의 평화를 찾는 시간이 필요해요 🫂',
        'tired': '피곤한 감정이 자주 나타나고 있어요. 충분한 휴식이 필요해요 😴',
        'love': '사랑스러운 감정을 많이 경험하고 있어요! 관계가 건강해 보여요 💕',
        'calm': '차분한 감정을 많이 경험하고 있어요. 마음의 평화를 잘 유지하고 있어요 🧘‍♀️',
        'excited': '신나는 감정을 많이 경험하고 있어요! 활력이 넘치는 삶을 살고 있어요 🎉',
        'confidence': '자신감 있는 감정을 많이 경험하고 있어요! 긍정적인 자아상을 가지고 있어요 💪',
      };

      insights.add(emotionMessages[dominantEmotion] ?? '감정 패턴을 분석하고 있어요 📊');
    }

    // 감정 안정성 인사이트
    if (emotionStability > 0.7) {
      insights.add('감정이 비교적 안정적이에요. 일관된 마음 상태를 유지하고 있어요 🎯');
    } else if (emotionStability < 0.3) {
      insights.add('감정 변화가 자주 나타나고 있어요. 감정 조절 연습이 도움이 될 수 있어요 🔄');
    }

    // 주간 패턴 인사이트 - NULL 체크 추가
    final weeklyData = weeklyPattern['dominantEmotions'] as Map<String, String>?;
    if (weeklyData != null) {
      if (weeklyData.containsKey('월') && weeklyData['월'] == 'tired') {
        insights.add('월요일에 피곤함을 느끼는 경향이 있어요. 주말 휴식을 더 충분히 취해보세요 😴');
      }
      if (weeklyData.containsKey('금') && weeklyData['금'] == 'happy') {
        insights.add('금요일에 행복감을 많이 느끼고 있어요! 주말을 기대하는 마음이 보여요 🎉');
      }
    }

    // 시간대 패턴 인사이트 - NULL 체크 추가
    final timeData = timePattern['dominantEmotions'] as Map<String, String>?;
    if (timeData != null && timeData.containsKey('새벽 (00-06)') && timeData['새벽 (00-06)'] == 'anxious') {
      insights.add('새벽 시간에 불안감을 느끼는 경향이 있어요. 수면 환경 개선을 고려해보세요 🌙');
    }

    // 성장 트렌드 인사이트
    if (growthTrend == 'improving') {
      insights.add('최근 감정 상태가 개선되고 있어요! 긍정적인 변화를 경험하고 있어요 📈');
    } else if (growthTrend == 'declining') {
      insights.add('최근 감정 상태가 다소 어려워지고 있어요. 전문가 상담을 고려해보세요 🤝');
    }

    // 기록 빈도 인사이트
    if (totalRecords >= 30) {
      insights.add('꾸준한 감정 기록을 하고 있어요! 자기 성찰에 대한 의지가 인상적이에요 📝');
    } else if (totalRecords < 10) {
      insights.add('더 많은 감정 기록을 통해 패턴을 발견할 수 있어요. 꾸준히 기록해보세요 ✨');
    }

    // 최소한 하나의 인사이트는 보장
    if (insights.isEmpty) {
      insights.add('감정 기록을 통해 자신을 더 잘 알아가는 여정을 시작했어요! 🌟');
    }

    return insights;
  }

  /// 개인화된 추천 생성
  static List<Map<String, dynamic>> generatePersonalizedRecommendations(
      Map<String, dynamic> analysis,
      ) {
    final List<Map<String, dynamic>> recommendations = [];
    final String dominantEmotion = analysis['dominantEmotion'] ?? 'none';
    final double emotionStability = (analysis['emotionStability'] as num?)?.toDouble() ?? 0.0;
    final String growthTrend = analysis['growthTrend'] ?? 'stable';

    // 감정별 맞춤 추천
    switch (dominantEmotion) {
      case 'sad':
        recommendations.addAll([
          {
            'icon': '🌅',
            'title': '아침 산책하기',
            'description': '자연 속에서 마음의 평화를 찾아보세요',
            'difficulty': '쉬움',
            'category': '활동',
          },
          {
            'icon': '📖',
            'title': '긍정적 독서',
            'description': '희망을 주는 책을 읽어보세요',
            'difficulty': '보통',
            'category': '지식',
          },
          {
            'icon': '🎨',
            'title': '창작 활동',
            'description': '그림 그리기나 글쓰기로 감정을 표현해보세요',
            'difficulty': '보통',
            'category': '창작',
          },
        ]);
        break;
      case 'anxious':
        recommendations.addAll([
          {
            'icon': '🧘‍♀️',
            'title': '명상 앱 사용',
            'description': '하루 10분 명상으로 마음의 평화를 찾아보세요',
            'difficulty': '쉬움',
            'category': '명상',
          },
          {
            'icon': '🫁',
            'title': '호흡 운동',
            'description': '깊은 호흡으로 긴장을 풀어보세요',
            'difficulty': '쉬움',
            'category': '운동',
          },
          {
            'icon': '📝',
            'title': '걱정 일기',
            'description': '걱정을 적어보고 해결책을 찾아보세요',
            'difficulty': '보통',
            'category': '기록',
          },
        ]);
        break;
      case 'angry':
        recommendations.addAll([
          {
            'icon': '🏃‍♀️',
            'title': '격렬한 운동',
            'description': '스트레스를 몸으로 풀어보세요',
            'difficulty': '보통',
            'category': '운동',
          },
          {
            'icon': '🎵',
            'title': '음악 감상',
            'description': '차분한 음악으로 마음을 진정시켜보세요',
            'difficulty': '쉬움',
            'category': '문화',
          },
          {
            'icon': '🌿',
            'title': '자연 속 시간',
            'description': '공원이나 산에서 시간을 보내보세요',
            'difficulty': '보통',
            'category': '활동',
          },
        ]);
        break;
      case 'tired':
        recommendations.addAll([
          {
            'icon': '😴',
            'title': '수면 패턴 개선',
            'description': '규칙적인 수면 시간을 만들어보세요',
            'difficulty': '보통',
            'category': '건강',
          },
          {
            'icon': '🍎',
            'title': '영양 관리',
            'description': '균형 잡힌 식사로 에너지를 충전해보세요',
            'difficulty': '보통',
            'category': '건강',
          },
          {
            'icon': '🧘‍♂️',
            'title': '요가',
            'description': '부드러운 스트레칭으로 몸을 풀어보세요',
            'difficulty': '보통',
            'category': '운동',
          },
        ]);
        break;
      default:
        recommendations.addAll([
          {
            'icon': '📚',
            'title': '새로운 취미',
            'description': '새로운 것을 배우며 성장해보세요',
            'difficulty': '보통',
            'category': '성장',
          },
          {
            'icon': '🤝',
            'title': '사람들과 만나기',
            'description': '소중한 사람들과 시간을 보내보세요',
            'difficulty': '보통',
            'category': '관계',
          },
          {
            'icon': '🎯',
            'title': '목표 설정',
            'description': '작은 목표를 세우고 달성해보세요',
            'difficulty': '보통',
            'category': '성장',
          },
        ]);
    }

    // 감정 안정성에 따른 추천
    if (emotionStability < 0.3) {
      recommendations.add({
        'icon': '🧘‍♀️',
        'title': '감정 조절 연습',
        'description': '마음챙김 명상으로 감정을 관찰해보세요',
        'difficulty': '어려움',
        'category': '명상',
      });
    }

    // 성장 트렌드에 따른 추천
    if (growthTrend == 'declining') {
      recommendations.add({
        'icon': '💙',
        'title': '전문가 상담',
        'description': '전문가와 상담하여 도움을 받아보세요',
        'difficulty': '어려움',
        'category': '치료',
      });
    }

    // 기본 추천이 비어있다면 최소한의 추천 제공
    if (recommendations.isEmpty) {
      recommendations.addAll([
        {
          'icon': '🌱',
          'title': '감정 일기 쓰기',
          'description': '매일 감정을 기록하여 패턴을 파악해보세요',
          'difficulty': '쉬움',
          'category': '기록',
        },
        {
          'icon': '🧘‍♀️',
          'title': '명상하기',
          'description': '마음의 평화를 찾기 위해 명상을 시도해보세요',
          'difficulty': '보통',
          'category': '명상',
        },
      ]);
    }

    return recommendations;
  }

  /// 월간 AI 리포트 생성
  static Map<String, dynamic> generateMonthlyReport(List<EmotionRecord> records) {
    final analysis = analyzeEmotionPatterns(records);
    final recommendations = generatePersonalizedRecommendations(analysis);

    final now = DateTime.now();
    final monthRecords = records.where((r) =>
    r.date.year == now.year && r.date.month == now.month).toList();

    return {
      'month': '${now.month}월',
      'totalRecords': monthRecords.length,
      'analysis': analysis,
      'recommendations': recommendations,
      'generatedAt': now.toIso8601String(),
    };
  }
}
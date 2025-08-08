import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/emotion_record.dart';
import '../services/ai_config.dart';

class AIGoalService {
  final String _apiKey = AIConfig.openaiApiKey; // 실제 구현시 환경변수에서 가져오기

  /// 감정 기록을 기반으로 개인화된 목표 추천 생성
  Future<List<Map<String, dynamic>>> generateGoalRecommendations(List<EmotionRecord> records) async {
    try {
      // API 연결 없이 기본 추천만 반환 (나중에 API 연결 시 수정)
      return _getDefaultRecommendations(records);
      
      // 실제 API 연결 시 사용할 코드 (주석 처리)
      /*
      final analysisData = _prepareEmotionAnalysis(records);
      
      final response = await http.post(
        Uri.parse('${AIConfig.openaiBaseUrl}/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": AIConfig.gpt4Model,
          "messages": [
            {
              "role": "system",
              "content": """당신은 감정 관리 전문가입니다. 
              사용자의 감정 기록을 분석하여 개인화된 목표를 추천해주세요.
              
              응답 형식:
              {
                "recommendations": [
                  {
                    "title": "목표 제목",
                    "description": "목표 설명",
                    "category": "감정관리/습관형성/성장목표/자기돌봄",
                    "targetValue": 80.0,
                    "unit": "%",
                    "targetDate": "2024-03-15",
                    "actionSteps": ["구체적 실행 단계 1", "구체적 실행 단계 2"],
                    "reason": "이 목표를 추천하는 이유"
                  }
                ]
              }
              
              목표 카테고리별 특징:
              - 감정관리: 긍정적 감정 비율, 감정 안정성 등
              - 습관형성: 일일 기록, 명상, 운동 등
              - 성장목표: 감정 다양성, 자기 이해 등
              - 자기돌봄: 휴식, 취미, 관계 개선 등
              """
            },
            {
              "role": "user",
              "content": "감정 분석 데이터: ${jsonEncode(analysisData)}"
            }
          ],
          "temperature": 0.7,
          "max_tokens": 1500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final result = jsonDecode(content);
        return List<Map<String, dynamic>>.from(result['recommendations']);
      } else {
        throw Exception('목표 추천 생성 실패: ${response.statusCode}');
      }
      */
    } catch (e) {
      print('AI 목표 추천 오류: $e');
      // 오류 시 기본 추천 반환
      return _getDefaultRecommendations(records);
    }
  }

  /// 감정 분석 데이터 준비
  Map<String, dynamic> _prepareEmotionAnalysis(List<EmotionRecord> records) {
    if (records.isEmpty) {
      return {
        'totalRecords': 0,
        'emotionCounts': {},
        'recentEmotions': [],
        'patterns': [],
        'suggestions': ['감정 기록을 시작해보세요']
      };
    }

    // 감정별 카운트
    final emotionCounts = <String, int>{};
    for (final record in records) {
      emotionCounts[record.emotion] = (emotionCounts[record.emotion] ?? 0) + 1;
    }

    // 최근 감정들 (최근 7일)
    final recentRecords = records.where((r) => 
      r.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).toList();

    final recentEmotions = recentRecords.map((r) => r.emotion).toList();

    // 감정 패턴 분석
    final positiveEmotions = ['happy', 'love', 'calm', 'excited', 'confidence'];
    final negativeEmotions = ['sad', 'angry', 'anxious', 'despair', 'tired'];
    
    final positiveCount = records.where((r) => positiveEmotions.contains(r.emotion)).length;
    final negativeCount = records.where((r) => negativeEmotions.contains(r.emotion)).length;
    final totalRecords = records.length;
    
    final positiveRatio = totalRecords > 0 ? (positiveCount / totalRecords * 100) : 0.0;
    final negativeRatio = totalRecords > 0 ? (negativeCount / totalRecords * 100) : 0.0;

    // 주요 감정 찾기
    String dominantEmotion = 'none';
    int maxCount = 0;
    emotionCounts.forEach((emotion, count) {
      if (count > maxCount) {
        dominantEmotion = emotion;
        maxCount = count;
      }
    });

    return {
      'totalRecords': totalRecords,
      'emotionCounts': emotionCounts,
      'recentEmotions': recentEmotions,
      'dominantEmotion': dominantEmotion,
      'positiveRatio': positiveRatio,
      'negativeRatio': negativeRatio,
      'patterns': _analyzeEmotionPatterns(records),
      'suggestions': _generateSuggestions(dominantEmotion, positiveRatio, negativeRatio),
    };
  }

  /// 감정 패턴 분석
  List<String> _analyzeEmotionPatterns(List<EmotionRecord> records) {
    final patterns = <String>[];
    
    if (records.isEmpty) return patterns;

    // 연속 기록 패턴
    final sortedRecords = records.toList()..sort((a, b) => a.date.compareTo(b.date));
    int consecutiveDays = 1;
    int maxConsecutive = 1;
    
    for (int i = 1; i < sortedRecords.length; i++) {
      final daysDiff = sortedRecords[i].date.difference(sortedRecords[i-1].date).inDays;
      if (daysDiff == 1) {
        consecutiveDays++;
        maxConsecutive = maxConsecutive < consecutiveDays ? consecutiveDays : maxConsecutive;
      } else {
        consecutiveDays = 1;
      }
    }
    
    if (maxConsecutive >= 7) {
      patterns.add('일주일 이상 연속 기록');
    } else if (maxConsecutive >= 3) {
      patterns.add('3일 이상 연속 기록');
    }

    // 감정 다양성
    final uniqueEmotions = records.map((r) => r.emotion).toSet().length;
    if (uniqueEmotions >= 5) {
      patterns.add('다양한 감정 표현');
    } else if (uniqueEmotions <= 2) {
      patterns.add('감정 표현이 제한적');
    }

    // 긍정/부정 비율
    final positiveEmotions = ['happy', 'love', 'calm', 'excited', 'confidence'];
    final positiveCount = records.where((r) => positiveEmotions.contains(r.emotion)).length;
    final positiveRatio = (positiveCount / records.length * 100);
    
    if (positiveRatio >= 70) {
      patterns.add('주로 긍정적 감정');
    } else if (positiveRatio <= 30) {
      patterns.add('부정적 감정이 많음');
    }

    return patterns;
  }

  /// 제안사항 생성
  List<String> _generateSuggestions(String dominantEmotion, double positiveRatio, double negativeRatio) {
    final suggestions = <String>[];
    
    if (dominantEmotion == 'sad' || negativeRatio > 60) {
      suggestions.add('긍정적 감정을 늘리는 목표 설정');
      suggestions.add('스트레스 관리 기법 연습');
    }
    
    if (dominantEmotion == 'anxious') {
      suggestions.add('마음의 평화를 찾는 목표');
      suggestions.add('명상 습관 형성');
    }
    
    if (dominantEmotion == 'angry') {
      suggestions.add('분노 관리 기법 학습');
      suggestions.add('건설적 감정 표현 연습');
    }
    
    if (dominantEmotion == 'tired') {
      suggestions.add('충분한 휴식 목표');
      suggestions.add('에너지 회복 활동');
    }
    
    if (positiveRatio >= 70) {
      suggestions.add('긍정적 감정 유지 목표');
      suggestions.add('감사 습관 형성');
    }
    
    return suggestions;
  }

  /// 기본 추천 목표 (API 오류 시)
  List<Map<String, dynamic>> _getDefaultRecommendations(List<EmotionRecord> records) {
    final recommendations = <Map<String, dynamic>>[];
    
    if (records.isEmpty) {
      recommendations.add({
        'title': '감정 기록 습관 형성',
        'description': '매일 감정을 기록하여 자기 이해를 높여보세요',
        'category': '습관형성',
        'targetValue': 7.0,
        'unit': '일',
        'targetDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'actionSteps': ['매일 감정 기록하기', '감정 변화 관찰하기'],
        'reason': '감정 기록을 통해 자기 이해를 높일 수 있습니다'
      });
    } else {
      recommendations.add({
        'title': '긍정적 감정 늘리기',
        'description': '일상에서 작은 기쁨을 찾고 긍정적 감정을 늘려보세요',
        'category': '감정관리',
        'targetValue': 70.0,
        'unit': '%',
        'targetDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'actionSteps': ['감사 일기 쓰기', '긍정적 활동 찾기', '주변 사람과 소통하기'],
        'reason': '긍정적 감정이 많을수록 삶의 만족도가 높아집니다'
      });
    }
    
    return recommendations;
  }
} 
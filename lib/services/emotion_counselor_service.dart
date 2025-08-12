import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/emotion_record.dart';

class EmotionCounselorService {
  final String openaiApiKey;

  EmotionCounselorService({required this.openaiApiKey});

  // 상담 세션 시작
  Future<Map<String, dynamic>> startCounselingSession({
    required String userMessage,
    required List<EmotionRecord> userHistory,
    required String sessionContext,
  }) async {
    try {
      // 사용자 히스토리 분석
      final emotionPatterns = _analyzeEmotionPatterns(userHistory);

      // 개인화된 상담 응답 생성
      final response = await _generateCounselingResponse(
        userMessage: userMessage,
        emotionPatterns: emotionPatterns,
        sessionContext: sessionContext,
      );

      return {
        'response': response,
        'emotion_analysis': emotionPatterns,
        'recommendations': _generateRecommendations(emotionPatterns),
        'session_summary': _generateSessionSummary(userMessage, response),
      };
    } catch (e) {
      debugPrint('상담 세션 오류: $e');
      return {
        'response': _getFallbackResponse(userMessage),
        'emotion_analysis': {},
        'recommendations': [],
        'session_summary': '상담 세션이 진행되었습니다.',
      };
    }
  }

  // 감정 패턴 분석
  Map<String, dynamic> _analyzeEmotionPatterns(List<EmotionRecord> records) {
    if (records.isEmpty) {
      return {
        'dominant_emotions': [],
        'emotional_trend': 'neutral',
        'pattern_insights': '충분한 데이터가 없습니다.',
      };
    }

    // 최근 7일간의 감정 분석
    final recentRecords = records.where((record) {
      return DateTime.now().difference(record.date).inDays <= 7;
    }).toList();

    // 감정별 빈도 계산
    final emotionCounts = <String, int>{};
    for (final record in recentRecords) {
      if (record.emotion.isNotEmpty) {
        emotionCounts[record.emotion] = (emotionCounts[record.emotion] ?? 0) + 1;
      }
    }

    // 지배적인 감정 찾기
    final dominantEmotions = emotionCounts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toList();

    // 감정 트렌드 분석
    String emotionalTrend = 'stable';
    if (dominantEmotions.any((emotion) => ['😢', '😰', '😤'].contains(emotion))) {
      emotionalTrend = 'challenging';
    } else if (dominantEmotions.any((emotion) => ['😊', '🥰', '😌'].contains(emotion))) {
      emotionalTrend = 'positive';
    }

    return {
      'dominant_emotions': dominantEmotions,
      'emotional_trend': emotionalTrend,
      'pattern_insights': _generatePatternInsights(emotionCounts, emotionalTrend),
      'emotion_counts': emotionCounts,
    };
  }

  // 상담 응답 생성
  Future<String> _generateCounselingResponse({
    required String userMessage,
    required Map<String, dynamic> emotionPatterns,
    required String sessionContext,
  }) async {
    // 실제 구현에서는 OpenAI API 호출
    // 지금은 패턴 기반 응답 생성

    final lowerMessage = userMessage.toLowerCase();
    final emotionalTrend = emotionPatterns['emotional_trend'] as String;
    final dominantEmotions = (emotionPatterns['dominant_emotions'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    // 컨텍스트 기반 응답 생성
    String response = '';

    // 감정 인식 및 공감
    if (lowerMessage.contains('힘들') || lowerMessage.contains('우울') || lowerMessage.contains('슬프')) {
      response = '지금 많이 힘드신 것 같네요. 😔 당신의 감정을 충분히 이해해요.\n\n';

      if (emotionalTrend == 'challenging') {
        response += '최근 계속 어려운 감정을 경험하고 계시는군요. 이런 시기에는 자신을 돌보는 것이 특히 중요해요.\n\n';
      }

      response += '💡 **맞춤 조언:**\n';
      response += '• 깊은 호흡을 통해 현재 순간에 집중해보세요\n';
      response += '• 작은 것이라도 감사할 수 있는 것을 찾아보세요\n';
      response += '• 충분한 휴식과 수면을 취하세요\n\n';
      response += '혼자가 아니라는 것을 기억해주세요. 더 이야기하고 싶은 것이 있다면 언제든 들어드릴게요.';

    } else if (lowerMessage.contains('불안') || lowerMessage.contains('걱정') || lowerMessage.contains('두려')) {
      response = '불안한 마음이 느껴지시는군요. 😰 불안은 자연스러운 감정이에요.\n\n';

      response += '💡 **불안 관리 전략:**\n';
      response += '• 4-7-8 호흡법: 4초 들이마시고, 7초 참고, 8초 내쉬기\n';
      response += '• 현재 순간에 집중하는 마음챙김 연습\n';
      response += '• 걱정을 종이에 적어서 객관화하기\n\n';
      response += '어떤 것이 당신을 불안하게 만드는지 더 자세히 이야기해주실 수 있나요?';

    } else if (lowerMessage.contains('행복') || lowerMessage.contains('기쁘') || lowerMessage.contains('좋')) {
      response = '정말 좋은 감정을 느끼고 계시는군요! 😊✨\n\n';

      if (emotionalTrend == 'positive') {
        response += '최근 계속 긍정적인 감정을 경험하고 계시는 것 같아요. 정말 훌륭해요!\n\n';
      }

      response += '💡 **긍정 감정 유지하기:**\n';
      response += '• 이 순간을 일기에 기록해보세요\n';
      response += '• 주변 사람들과 이 기쁨을 나눠보세요\n';
      response += '• 감사 일기를 써보세요\n\n';
      response += '무엇이 당신을 이렇게 행복하게 만들었는지 더 들려주세요!';

    } else if (lowerMessage.contains('화나') || lowerMessage.contains('짜증') || lowerMessage.contains('분노')) {
      response = '화가 나는 상황이군요. 😤 분노는 경계를 설정하고 변화를 만드는 자연스러운 감정이에요.\n\n';

      response += '💡 **건설적인 분노 관리:**\n';
      response += '• 잠시 멈추고 깊게 숨쉬기\n';
      response += '• 화의 원인을 구체적으로 파악하기\n';
      response += '• 건설적인 방법으로 감정 표현하기\n\n';
      response += '어떤 일이 당신을 화나게 만들었는지 이야기해주세요. 함께 해결방법을 찾아보아요.';

    } else {
      // 일반적인 상담 응답
      response = '당신의 이야기를 들어주셔서 감사해요. 💕\n\n';

      if (dominantEmotions.isNotEmpty) {
        response += '최근 ${_getEmotionDescription(dominantEmotions)} 감정을 자주 경험하고 계시는군요.\n\n';
      }

      response += '지금 이 순간 어떤 감정을 느끼고 계신가요? 더 자세히 이야기해주시면 더 구체적인 도움을 드릴 수 있어요.';
    }

    return response;
  }

  // 추천사항 생성
  List<String> _generateRecommendations(Map<String, dynamic> emotionPatterns) {
    final emotionalTrend = emotionPatterns['emotional_trend'] as String;
    final recommendations = <String>[];

    switch (emotionalTrend) {
      case 'challenging':
        recommendations.addAll([
          '전문 상담사와의 대화를 고려해보세요',
          '규칙적인 운동이나 산책을 시도해보세요',
          '충분한 수면과 휴식을 취하세요',
          '신뢰할 수 있는 사람과 이야기하세요',
        ]);
        break;
      case 'positive':
        recommendations.addAll([
          '긍정적인 감정을 일기에 기록해보세요',
          '감사 연습을 지속해보세요',
          '주변 사람들과 기쁨을 나눠보세요',
          '새로운 목표를 설정해보세요',
        ]);
        break;
      default:
        recommendations.addAll([
          '매일 감정을 기록하는 습관을 만들어보세요',
          '마음챙김이나 명상을 시도해보세요',
          '자신에게 친절한 말을 해주세요',
          '작은 성취라도 인정하고 축하하세요',
        ]);
    }

    return recommendations;
  }

  // 세션 요약 생성
  String _generateSessionSummary(String userMessage, String response) {
    return '사용자가 자신의 감정을 표현하고, AI 상담사가 공감적이고 전문적인 조언을 제공했습니다.';
  }

  // 패턴 인사이트 생성
  String _generatePatternInsights(Map<String, int> emotionCounts, String trend) {
    if (emotionCounts.isEmpty) {
      return '아직 충분한 감정 데이터가 없습니다. 꾸준한 기록으로 패턴을 파악해보세요.';
    }

    final mostFrequent = emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    String insight = '최근 가장 자주 경험한 감정은 ${_getEmotionName(mostFrequent.key)}입니다. ';

    switch (trend) {
      case 'challenging':
        insight += '어려운 감정들을 자주 경험하고 계시네요. 자기돌봄에 더 신경써주세요.';
        break;
      case 'positive':
        insight += '긍정적인 감정들을 많이 경험하고 계시는군요! 이 상태를 유지해보세요.';
        break;
      default:
        insight += '감정 상태가 안정적인 편이네요. 지속적인 관찰이 도움이 될 것 같아요.';
    }

    return insight;
  }

  // 감정 설명 반환
  String _getEmotionDescription(List<String> emotions) {
    final descriptions = emotions.map((e) => _getEmotionName(e)).join(', ');
    return descriptions;
  }

  // 감정 이름 반환
  String _getEmotionName(String emoji) {
    switch (emoji) {
      case '😊': return '행복';
      case '😢': return '슬픔';
      case '😤': return '분노';
      case '😰': return '불안';
      case '😴': return '피곤함';
      case '🥰': return '사랑';
      case '😌': return '평온함';
      default: return '복합적인';
    }
  }

  // 폴백 응답
  String _getFallbackResponse(String userMessage) {
    return '''안녕하세요! 저는 당신의 감정을 이해하고 함께 성장하는 AI 상담사입니다. 😊

지금 어떤 감정을 느끼고 계신가요? 솔직한 마음을 들려주세요. 
당신의 이야기를 듣고 도움이 되는 조언을 드리고 싶어요.

혹시 지금 힘든 상황이라면:
• 깊은 호흡을 해보세요
• 현재 순간에 집중해보세요  
• 자신에게 친절한 말을 해주세요

더 자세히 이야기해주시면 더 구체적인 도움을 드릴 수 있어요. 💕''';
  }
}
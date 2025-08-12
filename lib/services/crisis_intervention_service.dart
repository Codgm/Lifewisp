import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/emotion_record.dart';

class CrisisInterventionService {
  // 위기 키워드 목록
  static const List<String> _crisisKeywords = [
    '자살', '죽고싶', '죽음', '자해', '상처', '칼', '독', '목매',
    '뛰어내리', '사라지고싶', '없어지고싶', '끝내고싶', '포기',
    '절망', '무의미', '혼자', '외롭', '버려졌', '쓸모없',
    '괴롭', '힘들어죽겠', '못살겠', '지쳐죽겠'
  ];

  // 고위험 키워드 목록
  static const List<String> _highRiskKeywords = [
    '자살', '죽고싶', '죽음', '자해', '목매', '뛰어내리',
    '독', '칼', '끝내고싶'
  ];

  // 중위험 키워드 목록
  static const List<String> _mediumRiskKeywords = [
    '사라지고싶', '없어지고싶', '포기', '절망',
    '무의미', '쓸모없', '못살겠', '지쳐죽겠'
  ];

  // 저위험 키워드 목록
  static const List<String> _lowRiskKeywords = [
    '혼자', '외롭', '버려졌', '괴롭', '힘들어죽겠'
  ];

  CrisisInterventionService();

  /// 위기 상황 감지 및 대응
  Future<Map<String, dynamic>> handleCrisisSituation({
    required String userMessage,
    required List<EmotionRecord> recentRecords,
    required String userId,
  }) async {
    try {
      // 위험도 분석
      final riskAssessment = _assessRiskLevel(userMessage, recentRecords);

      // 위기 상황별 응답 생성
      final response = _generateCrisisResponse(riskAssessment);

      // 위기 로그 기록 (실제 구현에서는 서버에 전송)
      if (riskAssessment['risk_level'] != '낮음') {
        await _logCrisisEvent(userId, userMessage, riskAssessment);
      }

      return {
        'risk_level': riskAssessment['risk_level'],
        'confidence': riskAssessment['confidence'],
        'response': response,
        'emergency_contacts': _getEmergencyContacts(),
        'immediate_actions': _getImmediateActions(riskAssessment['risk_level']),
        'keywords_detected': riskAssessment['detected_keywords'],
      };
    } catch (e) {
      debugPrint('위기 개입 서비스 오류: $e');
      // 오류 발생 시 안전한 기본 응답 제공
      return {
        'risk_level': '보통',
        'confidence': 0.5,
        'response': _getFallbackCrisisResponse(),
        'emergency_contacts': _getEmergencyContacts(),
        'immediate_actions': _getImmediateActions('보통'),
        'keywords_detected': <String>[],
      };
    }
  }

  /// 위험도 평가
  Map<String, dynamic> _assessRiskLevel(String message, List<EmotionRecord> recentRecords) {
    final lowerMessage = message.toLowerCase();
    final detectedKeywords = <String>[];

    // 키워드 감지
    int riskScore = 0;

    // 고위험 키워드 체크
    for (String keyword in _highRiskKeywords) {
      if (lowerMessage.contains(keyword)) {
        detectedKeywords.add(keyword);
        riskScore += 10;
      }
    }

    // 중위험 키워드 체크
    for (String keyword in _mediumRiskKeywords) {
      if (lowerMessage.contains(keyword)) {
        detectedKeywords.add(keyword);
        riskScore += 5;
      }
    }

    // 저위험 키워드 체크
    for (String keyword in _lowRiskKeywords) {
      if (lowerMessage.contains(keyword)) {
        detectedKeywords.add(keyword);
        riskScore += 2;
      }
    }

    // 최근 감정 기록 분석
    final emotionScore = _analyzeRecentEmotions(recentRecords);
    riskScore += emotionScore;

    // 메시지 길이 및 반복 패턴 분석
    if (message.length > 200) riskScore += 1; // 긴 메시지는 심각한 고민의 신호
    if (_hasRepeatingPatterns(message)) riskScore += 2;

    // 위험도 결정
    String riskLevel;
    double confidence;

    if (riskScore >= 15) {
      riskLevel = '긴급';
      confidence = 0.9;
    } else if (riskScore >= 8) {
      riskLevel = '높음';
      confidence = 0.8;
    } else if (riskScore >= 4) {
      riskLevel = '보통';
      confidence = 0.6;
    } else if (riskScore >= 2) {
      riskLevel = '낮음';
      confidence = 0.4;
    } else {
      riskLevel = '정상';
      confidence = 0.2;
    }

    return {
      'risk_level': riskLevel,
      'confidence': confidence,
      'risk_score': riskScore,
      'detected_keywords': detectedKeywords,
    };
  }

  /// 최근 감정 기록 분석
  int _analyzeRecentEmotions(List<EmotionRecord> records) {
    if (records.isEmpty) return 0;

    int emotionScore = 0;
    final recentRecords = records.where((record) {
      return DateTime.now().difference(record.date).inDays <= 7;
    }).toList();

    // 부정적 감정의 빈도 체크
    final negativeEmotions = ['😢', '😰', '😤', '😔', '😞', '😭'];
    int negativeCount = 0;

    for (final record in recentRecords) {
      if (negativeEmotions.contains(record.emotion)) {
        negativeCount++;
      }

      // 일기 내용에서 위험 신호 체크
      if (record.diary.isNotEmpty) {
        final lowerDiary = record.diary.toLowerCase();
        for (String keyword in _crisisKeywords) {
          if (lowerDiary.contains(keyword)) {
            emotionScore += 3;
          }
        }
      }
    }

    // 최근 7일 중 5일 이상 부정적 감정
    if (negativeCount >= 5) emotionScore += 5;
    // 최근 7일 중 3-4일 부정적 감정
    else if (negativeCount >= 3) emotionScore += 3;

    return emotionScore;
  }

  /// 반복 패턴 감지
  bool _hasRepeatingPatterns(String message) {
    // 같은 단어나 구문이 반복되는지 체크
    final words = message.toLowerCase().split(' ');
    final wordCount = <String, int>{};

    for (String word in words) {
      if (word.length > 2) { // 2글자 이상 단어만 체크
        wordCount[word] = (wordCount[word] ?? 0) + 1;
      }
    }

    // 같은 단어가 3번 이상 반복되면 패턴으로 간주
    return wordCount.values.any((count) => count >= 3);
  }

  /// 위기 상황별 응답 생성
  String _generateCrisisResponse(Map<String, dynamic> riskAssessment) {
    final riskLevel = riskAssessment['risk_level'] as String;
    final detectedKeywords = riskAssessment['detected_keywords'] as List<String>;

    switch (riskLevel) {
      case '긴급':
        return _generateEmergencyResponse(detectedKeywords);
      case '높음':
        return _generateHighRiskResponse(detectedKeywords);
      case '보통':
        return _generateMediumRiskResponse(detectedKeywords);
      case '낮음':
        return _generateLowRiskResponse(detectedKeywords);
      default:
        return _generateNormalResponse();
    }
  }

  /// 긴급 상황 응답
  String _generateEmergencyResponse(List<String> keywords) {
    return '''🚨 **긴급 상황이 감지되었습니다** 🚨

당신의 안전이 가장 중요합니다. 지금 당장 도움을 받으세요.

📞 **즉시 연락하세요:**
• **자살예방상담전화: 1393** (24시간, 무료)
• **정신건강상담전화: 1577-0199** (24시간)
• **생명의전화: 1588-9191** (24시간)
• **응급실: 119**

🆘 **지금 당장 해야 할 것:**
1. 위 번호 중 하나로 즉시 전화하기
2. 가까운 사람에게 연락하기
3. 안전한 곳으로 이동하기
4. 위험한 물건들 치우기

💝 **기억해주세요:**
• 당신은 혼자가 아닙니다
• 이런 감정은 일시적입니다
• 도움을 요청하는 것은 용기 있는 행동입니다
• 당신의 생명은 소중합니다

전문가들이 당신을 기다리고 있습니다. 지금 전화하세요.''';
  }

  /// 높은 위험도 응답
  String _generateHighRiskResponse(List<String> keywords) {
    return '''⚠️ **심각한 상황이 감지되었습니다** ⚠️

당신이 겪고 있는 고통을 이해합니다. 하지만 혼자 견디지 마세요.

📞 **전문가 상담받기:**
• **자살예방상담전화: 1393** (24시간 무료)
• **정신건강상담전화: 1577-0199**
• **청소년전화: 1388**

🛡️ **당장 할 수 있는 것:**
1. 깊게 숨쉬기 (4초 들이마시고 6초 내쉬기)
2. 신뢰할 수 있는 사람에게 연락하기
3. 안전한 환경 만들기
4. 전문가와 상담 예약하기

💪 **기억하세요:**
• 이 감정은 영원하지 않습니다
• 도움을 받을 수 있습니다
• 당신은 가치 있는 사람입니다

지금 이 순간을 버텨내는 것만으로도 충분히 용감합니다.''';
  }

  /// 보통 위험도 응답
  String _generateMediumRiskResponse(List<String> keywords) {
    return '''💛 **당신의 마음이 걱정됩니다** 💛

힘든 시간을 보내고 계시는군요. 이런 감정을 느끼는 것은 자연스러운 일이지만, 혼자 감당하지 마세요.

🤝 **도움받을 곳:**
• **정신건강상담전화: 1577-0199**
• **마음건강 바우처 서비스**
• **지역 정신건강복지센터**

🌱 **지금 시도해볼 수 있는 것:**
1. 신뢰하는 사람과 이야기하기
2. 규칙적인 수면과 식사
3. 가벼운 산책이나 운동
4. 좋아했던 활동 다시 해보기
5. 전문 상담 받아보기

📝 **자기돌봄 체크리스트:**
• 오늘 충분히 잤나요?
• 제대로 된 식사를 했나요?
• 누군가와 대화를 나눴나요?

당신의 감정은 소중하고, 도움을 받을 자격이 있습니다.''';
  }

  /// 낮은 위험도 응답
  String _generateLowRiskResponse(List<String> keywords) {
    return '''🫂 **당신의 마음을 이해합니다** 🫂

어려운 감정을 느끼고 계시는군요. 이런 감정을 표현해주셔서 고마워요.

💚 **마음 돌보기:**
1. **자기 공감하기:** "지금 힘들어하는 내가 당연해"
2. **작은 성취 인정하기:** 오늘 해낸 일들 돌아보기
3. **연결감 느끼기:** 소중한 사람들 떠올리기

🌟 **시도해볼 수 있는 것:**
• 따뜻한 차 마시며 잠시 휴식
• 좋아하는 음악 듣기
• 간단한 일기 쓰기
• 친구나 가족과 안부 나누기

📞 **필요할 때 연락하세요:**
• **정신건강상담전화: 1577-0199**

혼자가 아니라는 것을 기억해주세요. 당신의 감정은 충분히 이해받을 만합니다.''';
  }

  /// 정상 상황 응답
  String _generateNormalResponse() {
    return '''😊 **건강한 마음 상태를 유지하고 계시는군요!**

지금처럼 자신의 감정을 잘 살피고 표현하는 것은 정말 중요한 일이에요.

✨ **마음 건강 유지하기:**
• 규칙적인 생활 리듬
• 균형 잡힌 식사와 충분한 수면
• 적절한 운동과 휴식
• 좋은 사람들과의 소통

🌈 **계속해서 성장하세요:**
당신이 자신을 돌보는 모습이 아름답습니다. 앞으로도 건강한 마음을 유지하시길 응원해요!''';
  }

  /// 폴백 위기 응답
  String _getFallbackCrisisResponse() {
    return '''🤗 **언제든 도움을 받으세요**

시스템에 일시적인 문제가 있었지만, 당신의 안전이 가장 중요합니다.

📞 **24시간 상담 가능:**
• **자살예방상담전화: 1393**
• **정신건강상담전화: 1577-0199**

힘들 때는 혼자 견디지 마시고 언제든 도움을 요청하세요.''';
  }

  /// 응급 연락처 목록
  Map<String, String> _getEmergencyContacts() {
    return {
      '자살예방상담전화': '1393',
      '정신건강상담전화': '1577-0199',
      '생명의전화': '1588-9191',
      '청소년전화': '1388',
      '응급실': '119',
      '경찰서': '112',
    };
  }

  /// 즉시 행동 사항
  List<String> _getImmediateActions(String riskLevel) {
    switch (riskLevel) {
      case '긴급':
        return [
          '즉시 전문가에게 연락하기',
          '가까운 사람에게 도움 요청하기',
          '안전한 환경 확보하기',
          '위험한 물건 제거하기',
          '응급실 방문 고려하기',
        ];
      case '높음':
        return [
          '전문 상담사와 대화하기',
          '신뢰할 수 있는 사람과 연락하기',
          '안전 계획 세우기',
          '의료진 상담 받기',
        ];
      case '보통':
        return [
          '상담 전화 이용하기',
          '지역 정신건강센터 방문하기',
          '가족이나 친구와 대화하기',
          '전문가 상담 예약하기',
        ];
      case '낮음':
        return [
          '자기돌봄 활동하기',
          '충분한 휴식 취하기',
          '좋아하는 활동하기',
          '지지적인 사람들과 시간 보내기',
        ];
      default:
        return [
          '건강한 생활습관 유지하기',
          '스트레스 관리하기',
          '정기적인 자기점검하기',
        ];
    }
  }

  /// 위기 이벤트 로그 기록 (실제 구현에서는 서버 전송)
  Future<void> _logCrisisEvent(
      String userId,
      String message,
      Map<String, dynamic> assessment,
      ) async {
    // 실제 구현에서는 서버에 위기 상황을 기록하고
    // 필요시 관련 기관에 알림을 보낼 수 있음

    final logData = {
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'risk_level': assessment['risk_level'],
      'confidence': assessment['confidence'],
      'message_length': message.length,
      'detected_keywords': assessment['detected_keywords'],
    };

    debugPrint('위기 상황 로그: ${jsonEncode(logData)}');

    // TODO: 실제 서버 전송 로직 구현
    // await _sendToServer(logData);
  }

  /// 위험도별 색상 반환
  String getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case '긴급': return '#FF0000'; // 빨강
      case '높음': return '#FF6B00'; // 주황
      case '보통': return '#FFD700'; // 노랑
      case '낮음': return '#90EE90'; // 연두
      default: return '#87CEEB'; // 하늘색
    }
  }

  /// 위험도별 아이콘 반환
  String getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case '긴급': return '🚨';
      case '높음': return '⚠️';
      case '보통': return '💛';
      case '낮음': return '💚';
      default: return '😊';
    }
  }
}
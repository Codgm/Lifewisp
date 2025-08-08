import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ai_config.dart';

class GPTService {
  final String apiKey;
  final bool useCostOptimization;

  GPTService({required this.apiKey, this.useCostOptimization = true});

  /// 감정 분석 (기본)
  Future<String> analyzeEmotion(String text) async {
    try {
      // API 연결 없이 기본 분석만 반환 (나중에 API 연결 시 수정)
      return _generateBasicEmotionAnalysis(text);
      
      // 실제 API 연결 시 사용할 코드 (주석 처리)
      /*
      final model = _isSimpleAnalysis(text) ? AIConfig.gpt35Model : AIConfig.gpt4Model;
      
      final response = await http.post(
        Uri.parse('${AIConfig.openaiBaseUrl}/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {
              "role": "system",
              "content": "당신은 감정 분석 전문가입니다. 사용자의 텍스트를 분석하여 주요 감정을 파악하고 공감적인 응답을 제공해주세요."
            },
            {
              "role": "user",
              "content": text
            }
          ],
          "temperature": 0.7,
          "max_tokens": 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('감정 분석 실패: ${response.statusCode}');
      }
      */
    } catch (e) {
      print('감정 분석 오류: $e');
      return '당신의 감정을 이해하려고 노력하고 있어요. 더 자세히 이야기해주세요.';
    }
  }

  /// 기본 감정 분석 생성
  String _generateBasicEmotionAnalysis(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('힘들') || lowerText.contains('슬프')) {
      return '힘든 시간을 보내고 계시는군요. 당신의 감정을 충분히 이해해요. 이런 기분이 드는 것은 자연스러운 일이에요.';
    } else if (lowerText.contains('화나') || lowerText.contains('짜증')) {
      return '화가 나는 상황이 있었군요. 그런 감정을 느끼는 것은 당연해요. 잠시 멈춰서 깊은 호흡을 해보세요.';
    } else if (lowerText.contains('걱정') || lowerText.contains('불안')) {
      return '걱정이 많으시군요. 불안한 마음을 이해해요. 지금 이 순간에 집중해보세요.';
    } else if (lowerText.contains('행복') || lowerText.contains('좋아')) {
      return '좋은 기분이시군요! 그런 긍정적인 감정을 느끼고 계시다니 기뻐요.';
    } else {
      return '당신의 감정을 이해하려고 노력하고 있어요. 더 자세히 이야기해주세요.';
    }
  }

  /// 위기 상황 감지
  Future<bool> detectCrisis(String text) async {
    try {
      final lowerText = text.toLowerCase();
      
      // 키워드 기반 위기 감지
      for (String keyword in AIConfig.crisisKeywords) {
        if (lowerText.contains(keyword.toLowerCase())) {
          return true;
        }
      }

      // AI 기반 위기 감지 (필요시)
      if (lowerText.length > 50) {
        final response = await http.post(
          Uri.parse('${AIConfig.openaiBaseUrl}/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "model": AIConfig.gpt35Model,
            "messages": [
              {
                "role": "system",
                "content": "위험 신호를 감지하는 전문가입니다. 사용자 메시지에서 자해, 자살, 극단적 절망 등의 위험 신호가 있는지 판단하세요. JSON 형식으로 {\"is_crisis\": true/false, \"risk_level\": \"낮음/보통/높음/긴급\", \"reason\": \"판단 근거\"}를 반환하세요."
              },
              {"role": "user", "content": text}
            ],
            "temperature": 0.1,
            "max_tokens": 200,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices'][0]['message']['content'];
          final result = jsonDecode(content);
          return result['is_crisis'] == true;
        }
      }

      return false;
    } catch (e) {
      print('위기 감지 오류: $e');
      return false; // 오류 시 안전하게 false 반환
    }
  }

  /// 전문가 상담 필요성 판단
  Future<bool> needsProfessionalHelp(String text, List<String> emotionHistory) async {
    try {
      final lowerText = text.toLowerCase();
      
      // 키워드 기반 판단
      for (String keyword in AIConfig.professionalHelpKeywords) {
        if (lowerText.contains(keyword.toLowerCase())) {
          return true;
        }
      }

      // 감정 히스토리 기반 판단
      final negativeEmotions = emotionHistory.where((emotion) => 
        ['sad', 'angry', 'anxious', 'despair'].contains(emotion)
      ).length;
      
      if (negativeEmotions >= emotionHistory.length * 0.7) {
        return true;
      }

      return false;
    } catch (e) {
      print('전문가 상담 필요성 판단 오류: $e');
      return false;
    }
  }

  /// 비용 최적화를 위한 간단한 분석 판단
  bool _isSimpleAnalysis(String text) {
    // 짧은 텍스트나 단순한 감정 표현은 GPT-3.5 사용
    return text.length < 100 || 
           text.split(' ').length < 20 ||
           _containsSimpleEmotionKeywords(text);
  }

  bool _containsSimpleEmotionKeywords(String text) {
    final simpleKeywords = [
      '행복', '슬픔', '화남', '기쁨', '우울', '불안', '피곤', '사랑', '평온', '흥분',
      'happy', 'sad', 'angry', 'joy', 'depressed', 'anxious', 'tired', 'love', 'calm', 'excited'
    ];
    
    final lowerText = text.toLowerCase();
    return simpleKeywords.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }

  /// 사용량 및 비용 추적
  Map<String, dynamic> getUsageStats() {
    // 실제 구현에서는 API 사용량을 추적해야 함
    return {
      'total_requests': 0,
      'gpt4_requests': 0,
      'gpt35_requests': 0,
      'estimated_cost': 0.0,
      'crisis_detections': 0,
      'professional_help_recommendations': 0,
    };
  }
} 

class AIConfig {
  // OpenAI 설정
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String gpt4Model = 'gpt-4';
  static const String gpt35Model = 'gpt-3.5-turbo';
  
  // 임시 API 키 (실제 구현시 환경변수에서 가져오기)
  static const String openaiApiKey = 'your-openai-api-key-here';
  static const String huggingfaceApiKey = 'your-huggingface-api-key-here';
  
  // Hugging Face 설정
  static const String huggingfaceBaseUrl = 'https://api-inference.huggingface.co/models';
  static const String emotionAnalysisModel = 'j-hartmann/emotion-english-distilroberta-base';
  
  // API 비용 및 제한
  static const double gpt4CostPer1kTokens = 0.03;
  static const double gpt35CostPer1kTokens = 0.002;
  static const int maxTokensPerRequest = 4000;
  static const int maxRequestsPerMinute = 60;
  
  // 상담 세션 설정
  static const int maxSessionLength = 50; // 대화 턴 수
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const double emotionThreshold = 0.7; // 감정 감지 임계값
  
  // 감정 분석 임계값
  static const double positiveEmotionThreshold = 0.6;
  static const double negativeEmotionThreshold = 0.6;
  static const double crisisThreshold = 0.8;
  
  // 안전 및 윤리 키워드
  static const List<String> crisisKeywords = [
    '자살', '죽고 싶다', '끝내고 싶다', '자해', '더 이상 못 살겠다',
    '힘들다', '끝이다', '고통', '절망', '희망이 없다'
  ];
  
  static const List<String> professionalHelpKeywords = [
    '상담사', '정신과', '치료', '병원', '전문가', '의사'
  ];
  
  // 한국 위기 대응 리소스
  static const Map<String, String> koreanCrisisResources = {
    '자살예방상담전화': '1393',
    '정신건강상담전화': '1577-0199',
    '여성긴급전화': '1366',
    '아동학대신고': '1391',
    '응급실': '119'
  };
  
  // 응답 템플릿
  static const Map<String, String> responseTemplates = {
    'crisis_detected': '위기 상황이 감지되었습니다. 즉시 전문가의 도움을 받으세요.',
    'positive_feedback': '긍정적인 변화를 보이고 있습니다. 계속 노력해주세요.',
    'negative_pattern': '부정적인 패턴이 감지되었습니다. 전문가 상담을 고려해보세요.',
    'neutral_response': '당신의 감정을 이해합니다. 더 자세히 이야기해주세요.'
  };
  
  // 비용 최적화 설정
  static const bool useCostOptimization = true;
  static const double simpleAnalysisThreshold = 0.5;
  static const List<String> simpleEmotionKeywords = [
    '좋다', '나쁘다', '행복', '슬프다', '화나다', '걱정'
  ];
  
  // 개인정보 보호 설정
  static const bool enableDataAnonymization = true;
  static const bool enableLocalProcessing = false;
  static const Duration dataRetentionPeriod = Duration(days: 365);
} 
// screens/chat_screen.dart (AI 상담사 플로우 개선)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../widgets/common_app_bar.dart';
import '../widgets/premium_gate.dart';
import '../providers/subscription_provider.dart';
import '../providers/emotion_provider.dart';
import '../services/emotion_counselor_service.dart';
import '../services/gpt_service.dart';
import '../services/crisis_intervention_service.dart';
import '../providers/goal_provider.dart';
import '../utils/theme.dart';
import '../widgets/rabbit_emoticon.dart';
import 'result_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Map<String, String>> messages = [
    {'role': 'ai', 'text': '안녕하세요! 저는 당신의 감정을 이해하고 함께 성장하는 AI 상담사입니다 😊\n\n오늘 하루는 어땠나요? 솔직한 마음을 들려주세요. 저는 당신의 이야기를 듣고 개인화된 조언을 드릴게요 💕'},
  ];
  final controller = TextEditingController();
  bool isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // 상담 세션 관리
  int _sessionCount = 0;
  static const int _maxSessionCount = 5;
  bool _sessionComplete = false;
  
  // AI 서비스 초기화
  late EmotionCounselorService _counselorService;
  late GPTService _gptService;
  late CrisisInterventionService _crisisService;
  bool _isAIServiceInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAIServices();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  void _initializeAIServices() {
    try {
      _counselorService = EmotionCounselorService(openaiApiKey: 'temp-api-key');
      _gptService = GPTService(apiKey: 'temp-api-key');
      _crisisService = CrisisInterventionService();
      _isAIServiceInitialized = true;
    } catch (e) {
      print('AI 서비스 초기화 오류: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 프리미엄이 아닌 경우 Premium Gate 표시
    if (!subscription.isPremium) {
    return Scaffold(
        appBar: CommonAppBar(title: 'AI 상담사', emoji: '🤖'),
      body: Container(
                  decoration: BoxDecoration(
            gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
          ),
          child: PremiumGate(
            child: Container(),
            featureName: 'ai_counselor',
            title: 'AI 상담사',
            description: 'AI가 당신의 감정을 깊이 이해하고\n개인화된 상담을 제공합니다',
            features: [
              '💬 무제한 AI 상담',
              '🤖 개인화된 감정 분석',
              '📊 고급 감정 패턴 분석',
              '🛡️ 위기 상황 대응',
              '📈 성장 추적 및 목표 설정',
              '🎯 맞춤형 케어 조언',
            ],
          ),
      ),
    );
  }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CommonAppBar(
        title: 'AI 상담사',
        emoji: '🤖',
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
        ),
          child: Column(
            children: [
                            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isLoading) {
                      return _buildLoadingMessage(isDark);
                    }
                    return _buildMessage(messages[index], isDark);
                  },
                                ),
                              ),
                            ),
            _buildInputArea(isDark, subscription),
                          ],
                        ),
                      ),
                    );
  }

  Widget _buildMessage(Map<String, String> message, bool isDark) {
    final isAI = message['role'] == 'ai';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isAI) ...[
                                            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: LifewispColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
                                            ),
                                    const SizedBox(width: 12),
          ],
                                    Expanded(
                                      child: Container(
              padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                color: isAI
                    ? (isDark ? LifewispColors.darkCardBg : Colors.white)
                    : LifewispColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: isAI
                    ? Border.all(color: Colors.grey.withOpacity(0.2))
                    : null,
                                              ),
                                              child: Text(
                message['text']!,
                                              style: GoogleFonts.notoSans(
                  fontSize: 15,
                  color: isDark ? LifewispColors.darkMainText : Colors.black87,
                                                height: 1.5,
                                              ),
                                            ),
            ),
          ),
          if (!isAI) ...[
                                    const SizedBox(width: 12),
                                    Container(
              width: 40,
              height: 40,
                                      decoration: BoxDecoration(
                color: LifewispColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
                                    ),
                                  ],
                                ],
                              ),
                            );
  }

  Widget _buildLoadingMessage(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: LifewispColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? LifewispColors.darkCardBg : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                      Text(
                    'AI가 생각하고 있어요...',
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      color: isDark ? LifewispColors.darkSubText : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark, SubscriptionProvider subscription) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                  color: isDark ? LifewispColors.darkSubBg : Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: controller,
                          style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: isDark ? LifewispColors.darkMainText : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: '마음을 들려주세요...',
                            hintStyle: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: isDark ? LifewispColors.darkSubText : Colors.grey[500],
                            ),
                            border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(subscription),
                        ),
                      ),
                    ),
            const SizedBox(width: 12),
            ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTap: () => _sendMessage(subscription),
                child: Container(
                  width: 48,
                  height: 48,
                      decoration: BoxDecoration(
                    color: LifewispColors.accent,
                        borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
        ),
      ),
    );
  }

  void _sendMessage(SubscriptionProvider subscription) async {
    if (controller.text.trim().isEmpty) return;

    final userMessage = controller.text.trim();
    controller.clear();

    setState(() {
      messages.add({'role': 'user', 'text': userMessage});
      isLoading = true;
    });

    _scaleController.forward().then((_) => _scaleController.reverse());

    try {
      String aiResponse;
      
      if (_isAIServiceInitialized) {
        // 고급 AI 상담사 서비스 사용
        aiResponse = await _getAdvancedAIResponse(userMessage, subscription);
      } else {
        // 기본 AI 응답 사용
        aiResponse = _generateBasicAIResponse(userMessage);
      }

    setState(() {
      messages.add({'role': 'ai', 'text': aiResponse});
      isLoading = false;
        _sessionCount++;
    });

    // 상담 완료 체크 (무료 사용자 5회, 프리미엄 사용자는 계속)
      if (subscription.isFree && _sessionCount >= 3 && !_sessionComplete) {
      _sessionComplete = true;
      _showSessionCompleteDialog();
    }
    } catch (e) {
      setState(() {
        messages.add({
          'role': 'ai', 
          'text': '죄송합니다. 일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'
        });
        isLoading = false;
      });
      print('AI 응답 생성 오류: $e');
    }
  }

  Future<String> _getAdvancedAIResponse(String userMessage, SubscriptionProvider subscription) async {
    try {
      // 위기 상황 감지 및 대응
      final emotionProvider = context.read<EmotionProvider>();
      final goalProvider = context.read<GoalProvider>();
      final userHistory = emotionProvider.records ?? [];
      
      // 위기 상황 체크
      final crisisResult = await _crisisService.handleCrisisSituation(
        userMessage: userMessage,
        recentRecords: userHistory,
        userId: 'user-id', // 실제 구현시 사용자 ID 사용
      );

      // 목표 진행률 업데이트
      goalProvider.updateGoalProgress(userHistory);

      // 위기 상황이 감지된 경우
      if (crisisResult['risk_level'] == '긴급' || crisisResult['risk_level'] == '높음') {
        return crisisResult['response'];
      }

      // 일반 상담 세션
      final counselingResult = await _counselorService.startCounselingSession(
        userMessage: userMessage,
        userHistory: userHistory,
        sessionContext: '상담 세션 #$_sessionCount',
      );

      return counselingResult['response'] ?? _generateBasicAIResponse(userMessage);
    } catch (e) {
      print('고급 AI 응답 오류: $e');
      return _generateBasicAIResponse(userMessage);
    }
  }

  String _handleCrisisSituation(String userMessage) {
    return '''
안전이 가장 중요합니다. 지금 당신의 감정을 충분히 이해합니다.

📞 즉시 도움을 받을 수 있는 연락처:
• 자살예방상담전화: 1393 (24시간)
• 정신건강상담전화: 1577-0199

혼자가 아니라는 것을 기억해주세요. 도움을 요청하는 것은 용기 있는 행동입니다.

지금 이 순간, 당신의 안전이 가장 중요합니다. 
위 연락처 중 하나로 전화를 걸어보세요. 
전문가들이 당신을 도와드릴 것입니다.
''';
  }

  String _generateBasicAIResponse(String userMessage) {
    // 개선된 AI 상담사 응답 로직
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('힘들') || lowerMessage.contains('스트레스') || lowerMessage.contains('우울')) {
      return '힘든 시간을 보내고 계시는군요 😔\n당신의 감정을 충분히 이해해요. 이런 기분이 드는 것은 자연스러운 일이에요.\n\n💡 제안: 깊은 호흡을 하면서 지금 이 순간에 집중해보세요. 작은 것이라도 감사할 수 있는 것을 찾아보는 것도 도움이 될 거예요.\n\n더 자세히 이야기해주시면 더 구체적인 도움을 드릴 수 있어요.';
    } else if (lowerMessage.contains('행복') || lowerMessage.contains('기쁘') || lowerMessage.contains('좋')) {
      return '정말 좋은 감정을 느끼고 계시는군요! 😊✨\n행복한 순간들을 소중히 여기고 기억해두세요.\n\n💡 제안: 이 긍정적인 에너지를 주변 사람들과 나눠보세요. 감사 일기를 써보는 것도 이런 좋은 감정을 더 오래 유지하는 데 도움이 될 거예요.\n\n어떤 일이 당신을 이렇게 행복하게 만들었나요?';
    } else if (lowerMessage.contains('불안') || lowerMessage.contains('걱정') || lowerMessage.contains('두려')) {
      return '불안한 감정을 느끼고 계시는군요 😰\n불안은 우리가 무언가를 소중히 여긴다는 신호이기도 해요.\n\n💡 제안: 4-7-8 호흡법을 시도해보세요. 4초 들이마시고, 7초 숨을 참고, 8초 내쉬세요. 이렇게 몇 번 반복하면 마음이 진정될 거예요.\n\n무엇이 당신을 불안하게 만들고 있나요?';
    } else if (lowerMessage.contains('화나') || lowerMessage.contains('짜증') || lowerMessage.contains('분노')) {
      return '화가 나는 감정을 느끼고 계시는군요 😤\n분노는 경계를 설정하고 변화를 만드는 자연스러운 감정이에요.\n\n💡 제안: 화가 날 때는 잠시 멈추고 깊은 호흡을 해보세요. 이 감정을 건설적으로 표현하는 방법을 찾아보는 것도 좋아요.\n\n어떤 일이 당신을 화나게 만들었나요?';
    } else if (lowerMessage.contains('피곤') || lowerMessage.contains('지쳐') || lowerMessage.contains('힘없')) {
      return '피곤하고 지친 감정을 느끼고 계시는군요 😴\n충분한 휴식이 필요할 때예요.\n\n💡 제안: 작은 휴식을 취해보세요. 따뜻한 차를 마시거나, 잠시 눈을 감고 휴식을 취하는 것도 좋아요. 자기 돌봄은 결코 이기적이지 않아요.\n\n어떤 일이 당신을 지치게 만들었나요?';
    } else if (lowerMessage.contains('사랑') || lowerMessage.contains('따뜻') || lowerMessage.contains('감사')) {
      return '따뜻하고 사랑스러운 감정을 느끼고 계시는군요! 🥰\n이런 긍정적인 감정들을 소중히 여기세요.\n\n💡 제안: 이 따뜻한 감정을 주변 사람들과 나눠보세요. 감사한 마음을 표현하는 것도 좋은 방법이에요.\n\n어떤 일이 당신을 이렇게 따뜻하게 만들었나요?';
    } else {
      return '당신의 이야기를 들려주셔서 감사해요 💕\n\n더 자세히 이야기해주시면 더 구체적인 도움을 드릴 수 있어요. 어떤 감정을 느끼고 계신가요?';
    }
  }

  void _showSessionCompleteDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '상담 세션 완료! 🎉',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? LifewispColors.darkMainText : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AI가 당신의 감정을 깊이 분석했어요!\n개인화된 상담 결과와 성장 방향을 확인해보세요 ✨',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: isDark
                    ? LifewispColors.darkSubText
                    : Colors.grey[600],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                    child: Text(
                      '계속 상담',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // 대화 내용을 바탕으로 감정 분석 결과 생성
                      String analyzedEmotion = _analyzeEmotionFromChat();
                      String generatedDiary = _generateDiaryFromChat();

                      // 상담 분석 데이터 생성
                      Map<String, dynamic> analysisData = _generateAnalysisData();

                      // ResultScreen으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(
                            emotion: analyzedEmotion,
                            diary: generatedDiary,
                            date: DateTime.now(),
                            chatMessages: messages, // 상담 메시지 전달
                            analysisData: analysisData, // 분석 데이터 전달
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LifewispColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '결과 보러가기 🚀',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 채팅 내용을 분석해서 감정 이모지 반환
  String _analyzeEmotionFromChat() {
    String allUserMessages = messages
        .where((msg) => msg['role'] == 'user')
        .map((msg) => msg['text']!)
        .join(' ')
        .toLowerCase();

    // 감정 키워드 분석
    if (allUserMessages.contains('힘들') || allUserMessages.contains('스트레스') || allUserMessages.contains('우울')) {
      return '😔';
    } else if (allUserMessages.contains('행복') || allUserMessages.contains('기쁘') || allUserMessages.contains('좋')) {
      return '😊';
    } else if (allUserMessages.contains('불안') || allUserMessages.contains('걱정') || allUserMessages.contains('두려')) {
      return '😰';
    } else if (allUserMessages.contains('화나') || allUserMessages.contains('짜증') || allUserMessages.contains('분노')) {
      return '😤';
    } else if (allUserMessages.contains('피곤') || allUserMessages.contains('지쳐') || allUserMessages.contains('힘없')) {
      return '😴';
    } else if (allUserMessages.contains('사랑') || allUserMessages.contains('따뜻') || allUserMessages.contains('감사')) {
      return '🥰';
    } else {
      return '😊'; // 기본값
    }
  }

  // 채팅 내용을 바탕으로 일기 생성
  String _generateDiaryFromChat() {
    final userMessages = messages
        .where((msg) => msg['role'] == 'user')
        .map((msg) => msg['text']!)
        .toList();

    if (userMessages.isEmpty) {
      return '오늘 AI 상담사와 대화를 나누었다.';
    }

    String diary = '오늘 AI 상담사와 대화를 나누었다.\n\n';
    
    final lastMessage = userMessages.last;
    diary += 'AI 상담사와 대화하면서 내 감정에 대해 더 깊이 생각해볼 수 있었다.\n\n';

    if (userMessages.length > 1) {
      diary += '대화를 나누면서 점점 더 솔직해질 수 있었고, ';
      if (lastMessage.length > 30) {
        diary += '"${lastMessage.substring(0, 30)}..."라는 마지막 이야기까지 ';
      } else {
        diary += '"$lastMessage"라는 마지막 이야기까지 ';
      }
      diary += '나누면서 감정을 정리할 수 있었다.\n\n';
    }

    diary += 'AI 상담사가 내 이야기를 들어주고 조언해주니 마음이 한결 가벼워졌다. ';
    diary += '이런 시간들이 나에게는 소중한 자기 돌봄의 순간인 것 같다.';

    return diary;
  }

  // 상담 분석 데이터 생성 (예시)
  Map<String, dynamic> _generateAnalysisData() {
    String allUserMessages = messages
        .where((msg) => msg['role'] == 'user')
        .map((msg) => msg['text']!)
        .join(' ')
        .toLowerCase();

    Map<String, int> emotionCounts = {
      '힘들': 0,
      '스트레스': 0,
      '우울': 0,
      '슬프': 0,
      '행복': 0,
      '기쁘': 0,
      '좋아': 0,
      '즐거': 0,
      '불안': 0,
      '걱정': 0,
      '두려': 0,
      '화나': 0,
      '짜증': 0,
      '분노': 0,
      '피곤': 0,
      '지쳐': 0,
      '힘없': 0,
    };

    for (var msg in messages) {
      if (msg['role'] == 'user') {
        for (var key in emotionCounts.keys) {
          if (allUserMessages.contains(key)) {
            emotionCounts[key] = (emotionCounts[key] ?? 0) + 1;
          }
        }
      }
    }

    return {
      'totalMessages': messages.length,
      'userMessages': messages.where((msg) => msg['role'] == 'user').length,
      'aiMessages': messages.where((msg) => msg['role'] == 'ai').length,
      'emotionCounts': emotionCounts,
    };
  }
}

// screens/chat_screen.dart (AI 상담사 플로우 개선)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../widgets/common_app_bar.dart';
import '../widgets/premium_gate.dart';
import '../providers/subscription_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        // 무료 사용자의 월 사용량 확인
        if (subscription.isFree && subscription.aiChatUsesThisMonth >= _maxSessionCount) {
          return _buildUsageLimitScreen(context, subscription);
        }

        return _buildChatInterface(context, subscription);
      },
    );
  }

  Widget _buildUsageLimitScreen(BuildContext context, SubscriptionProvider subscription) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CommonAppBar(title: 'AI 상담사', emoji: '🤖', showBackButton: true),
      body: Container(
        decoration: LifewispGradients.onboardingBgFor('emotion', dark: isDark).asBoxDecoration,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text('🔥', style: TextStyle(fontSize: 48)),
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  '이번 달 상담 완료!',
                  style: isDark
                      ? LifewispTextStyles.darkTitle.copyWith(fontSize: 24)
                      : LifewispTextStyles.title.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'AI 상담사와의 상담이 완료되었어요!\n더 깊은 분석과 무제한 상담을 원하시면\n프리미엄으로 업그레이드해보세요 ✨',
                  style: isDark
                      ? LifewispTextStyles.darkSubtitle.copyWith(height: 1.6)
                      : LifewispTextStyles.subtitle.copyWith(height: 1.6),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _buildFeatureItem('🤖 무제한 AI 상담'),
                      _buildFeatureItem('📊 고급 감정 분석'),
                      _buildFeatureItem('💡 개인화된 성장 계획'),
                      _buildFeatureItem('📈 월간 AI 리포트'),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 32),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/subscription');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      '프리미엄 시작하기 🚀',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '나중에 하기',
                    style: TextStyle(
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Text(feature, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildChatInterface(BuildContext context, SubscriptionProvider subscription) {
    final today = DateTime.now();
    String dateStr = '${today.year}년 ${today.month}월 ${today.day}일';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 반응형을 위한 기본값
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isDesktop = screenWidth > 1024;
    final horizontalPadding = isDesktop ? 120.0 : isTablet ? 60.0 : screenWidth > 600 ? 24.0 : 12.0;
    final dateFontSize = isTablet ? 15.0 : 14.0;
    final bodyFontSize = isTablet ? 16.0 : 15.0;
    final hintFontSize = isTablet ? 15.0 : 14.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      appBar: CommonAppBar(
        title: 'AI 상담사',
        emoji: '🤖',
        showBackButton: true,
        actions: [
          // 상담 진행률 표시
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: subscription.isPremium
                    ? [LifewispColors.accent, LifewispColors.accentDark]
                    : [Colors.orange, Colors.deepOrange],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(subscription.isPremium ? '✨' : '🔥', style: TextStyle(fontSize: 10)),
                SizedBox(width: 4),
                Text(
                  subscription.isPremium ? '무제한' : '${_sessionCount}/${_maxSessionCount}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // 테스트용 결과 화면 버튼
          IconButton(
            onPressed: () => _testResultScreen(context),
            icon: Icon(Icons.science, color: Colors.orange),
            tooltip: '결과 화면 테스트',
          ),
        ],
      ),
      body: Container(
        decoration: LifewispGradients.onboardingBgFor('emotion', dark: isDark).asBoxDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // 상담 진행률 표시
              if (!subscription.isPremium) ...[
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.withOpacity(0.1),
                              Colors.deepOrange.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '상담 진행률: $_sessionCount/$_maxSessionCount',
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],

              // 메시지 리스트
              Expanded(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: messages.length,
                          itemBuilder: (context, idx) {
                            final msg = messages[idx];
                            final isAI = msg['role'] == 'ai';

                            // 반응형 아바타 및 메시지 크기
                            double avatarSize = 40;
                            double messagePadding = 12;
                            if (isTablet) {
                              avatarSize = 48;
                              messagePadding = 16;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isAI) ...[
                                                                                // AI 아바타 (토끼)
                                            Container(
                                              width: avatarSize,
                                              height: avatarSize,
                                              child: RabbitEmoticon(
                                                emotion: RabbitEmotion.calm,
                                                size: avatarSize,
                                                backgroundColor: Colors.transparent,
                                                borderColor: Colors.transparent,
                                                borderWidth: 0,
                                              ),
                                            ),
                                    const SizedBox(width: 12),
                                    // AI 메시지
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(messagePadding),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? LifewispColors.darkCardBg.withOpacity(0.9)
                                              : Colors.white.withOpacity(0.9),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark
                                                  ? Colors.black.withOpacity(0.3)
                                                  : Colors.black.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: LifewispColors.accent.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // AI 라벨
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [LifewispColors.accent, LifewispColors.accentDark],
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '✨ AI 상담사',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              msg['text']!,
                                              style: GoogleFonts.notoSans(
                                                fontSize: bodyFontSize,
                                                fontWeight: FontWeight.w400,
                                                color: isDark
                                                    ? LifewispColors.darkMainText
                                                    : const Color(0xFF2D3748),
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    // 사용자 메시지
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(messagePadding),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isDark
                                                ? [LifewispColors.darkPurple, LifewispColors.darkPurpleDark]
                                                : [LifewispColors.purple, LifewispColors.purpleDark],
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(4),
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark
                                                  ? LifewispColors.darkPurple.withOpacity(0.3)
                                                  : LifewispColors.purple.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          msg['text']!,
                                          style: GoogleFonts.notoSans(
                                            fontSize: bodyFontSize,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // 사용자 아바타
                                    Container(
                                      width: avatarSize,
                                      height: avatarSize,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDark
                                              ? [LifewispColors.darkPurple, LifewispColors.darkPurpleDark]
                                              : [LifewispColors.purple, LifewispColors.purpleDark],
                                        ),
                                        borderRadius: BorderRadius.circular(avatarSize / 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? LifewispColors.darkPurple.withOpacity(0.3)
                                                : LifewispColors.purple.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text('👤', style: TextStyle(fontSize: avatarSize * 0.4)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 로딩 인디케이터
              if (isLoading)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? LifewispColors.darkCardBg.withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: LifewispColors.accent.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(LifewispColors.accent),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'AI 상담사가 생각하고 있어요...',
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                        ),
                      ),
                    ],
                  ),
                ),

              // 입력 필드
              Container(
                margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? LifewispColors.darkCardBg.withOpacity(0.9)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? LifewispColors.darkPrimary.withOpacity(0.3)
                                : LifewispColors.accent.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: controller,
                          style: GoogleFonts.notoSans(
                            fontSize: bodyFontSize,
                            color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                          ),
                          decoration: InputDecoration(
                            hintText: '마음을 들려주세요...',
                            hintStyle: GoogleFonts.notoSans(
                              fontSize: hintFontSize,
                              color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [LifewispColors.accent, LifewispColors.accentDark],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: LifewispColors.accent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: isLoading ? null : _sendMessage,
                        icon: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final subscription = context.read<SubscriptionProvider>();

    // 무료 사용자의 사용량 증가
    if (subscription.isFree) {
      subscription.incrementAiChatUsage();
      _sessionCount++;
    }

    setState(() {
      messages.add({'role': 'user', 'text': text});
      controller.clear();
      isLoading = true;
    });

    // AI 응답 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    // AI 응답 생성
    String aiResponse = _generateAIResponse(text);

    setState(() {
      messages.add({'role': 'ai', 'text': aiResponse});
      isLoading = false;
    });

    // 상담 완료 체크 (무료 사용자 5회, 프리미엄 사용자는 계속)
    if (subscription.isFree && _sessionCount >= 3 && !_sessionComplete) { // 테스트용으로 3회로 변경
      _sessionComplete = true;
      _showSessionCompleteDialog();
    }
  }

  String _generateAIResponse(String userMessage) {
    // 개선된 AI 상담사 응답 로직
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('힘들') || lowerMessage.contains('스트레스') || lowerMessage.contains('우울')) {
      return '힘든 시간을 보내고 계시는군요 😔\n당신의 감정을 충분히 이해해요. 이런 기분이 드는 것은 자연스러운 일이에요.\n\n💡 제안: 깊은 호흡을 하면서 지금 이 순간에 집중해보세요. 작은 것이라도 감사할 수 있는 것을 찾아보는 것도 도움이 될 거예요.\n\n더 자세히 이야기해주시면 더 구체적인 도움을 드릴 수 있어요.';
    } else if (lowerMessage.contains('행복') || lowerMessage.contains('기쁘') || lowerMessage.contains('좋')) {
      return '정말 좋은 감정을 느끼고 계시는군요! 😊✨\n행복한 순간들을 소중히 여기고 기억해두세요.\n\n💡 제안: 이 긍정적인 에너지를 주변 사람들과 나눠보세요. 감사 일기를 써보는 것도 이런 좋은 감정을 더 오래 유지하는 데 도움이 될 거예요.\n\n어떤 일이 당신을 이렇게 행복하게 만들었나요?';
    } else if (lowerMessage.contains('불안') || lowerMessage.contains('걱정') || lowerMessage.contains('두려')) {
      return '불안한 마음이 드시는군요 😰\n불안은 미래에 대한 우려에서 나오는 경우가 많아요. 당신의 감정을 충분히 이해해요.\n\n💡 제안: 지금 당장 컨트롤할 수 있는 것에 집중해보세요. 4-7-8 호흡법(4초 들이마시고, 7초 참고, 8초 내쉬기)을 시도해보는 것도 좋겠어요.\n\n구체적으로 어떤 일이 걱정되시나요?';
    } else if (lowerMessage.contains('화나') || lowerMessage.contains('짜증') || lowerMessage.contains('분노')) {
      return '화가 나시는군요 😠\n분노는 자연스러운 감정이에요. 중요한 것은 이를 건강하게 표현하는 방법을 찾는 것이죠.\n\n💡 제안: 잠시 멈추고 10까지 세어보세요. 또는 화가 난 이유를 적어보는 것도 도움이 될 수 있어요.\n\n어떤 상황이 당신을 화나게 만들었나요?';
    } else if (lowerMessage.contains('피곤') || lowerMessage.contains('지쳐') || lowerMessage.contains('힘없')) {
      return '피곤하시군요 😴\n충분한 휴식이 필요해 보여요. 당신의 몸과 마음이 쉬고 싶어하고 있어요.\n\n💡 제안: 오늘은 자신에게 작은 선물을 해주세요. 따뜻한 차 한 잔, 좋아하는 음악, 또는 잠시 누워있는 것도 좋아요.\n\n언제부터 이런 피곤함을 느끼셨나요?';
    } else {
      return '당신의 이야기를 들려주셔서 고마워요 🤗\n감정을 표현하는 것 자체가 큰 용기예요. 당신의 감정은 모두 소중하고 의미가 있어요.\n\n💡 더 자세히 이야기해주시면, 더욱 개인화된 조언을 드릴 수 있어요. 지금 가장 신경 쓰이는 것이 무엇인지 말씀해주세요.\n\n어떤 감정을 느끼고 계신가요?';
    }
  }

  void _showSessionCompleteDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: isDark
            ? LifewispColors.darkCardBg
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [LifewispColors.accent, LifewispColors.accentDark],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: LifewispColors.accent.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AI 상담 완료!',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? LifewispColors.darkMainText
                    : const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
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

    if (allUserMessages.contains('힘들') ||
        allUserMessages.contains('스트레스') ||
        allUserMessages.contains('우울') ||
        allUserMessages.contains('슬프')) {
      return '😔';
    } else if (allUserMessages.contains('행복') ||
        allUserMessages.contains('기쁘') ||
        allUserMessages.contains('좋아') ||
        allUserMessages.contains('즐거')) {
      return '😊';
    } else if (allUserMessages.contains('불안') ||
        allUserMessages.contains('걱정') ||
        allUserMessages.contains('두려')) {
      return '😰';
    } else if (allUserMessages.contains('화나') ||
        allUserMessages.contains('짜증') ||
        allUserMessages.contains('분노')) {
      return '😠';
    } else if (allUserMessages.contains('피곤') ||
        allUserMessages.contains('지쳐') ||
        allUserMessages.contains('힘없')) {
      return '😴';
    } else {
      return '🤔'; // 기본값: 생각하는 표정
    }
  }

  // 채팅 내용을 바탕으로 일기 생성
  String _generateDiaryFromChat() {
    List<String> userMessages = messages
        .where((msg) => msg['role'] == 'user')
        .map((msg) => msg['text']!)
        .toList();

    if (userMessages.isEmpty) {
      return '오늘은 AI 상담사와 짧은 대화를 나누었습니다. 감정을 표현하는 것만으로도 의미 있는 시간이었어요.';
    }

    String firstMessage = userMessages.first;
    String lastMessage = userMessages.last;

    // 개선된 일기 생성 로직
    String diary = '오늘 AI 상담사와의 대화를 통해 내 마음을 들여다보는 시간을 가졌다.\n\n';

    if (firstMessage.length > 20) {
      diary += '처음에는 "${firstMessage.substring(0, 20)}..."라고 이야기했는데, ';
    } else {
      diary += '처음에는 "$firstMessage"라고 이야기했는데, ';
    }

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

  void _testResultScreen(BuildContext context) {
    // 대화 내용을 분석해서 감정 이모지 반환
    String analyzedEmotion = _analyzeEmotionFromChat();
    // 대화 내용을 바탕으로 일기 생성
    String generatedDiary = _generateDiaryFromChat();

    // 상담 분석 데이터 생성 (예시)
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
  }
}
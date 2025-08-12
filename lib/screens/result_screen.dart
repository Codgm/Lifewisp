import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/common_app_bar.dart';
import 'package:provider/provider.dart';
import '../models/emotion_record.dart';
import '../providers/emotion_provider.dart';
import '../providers/subscription_provider.dart';
import '../utils/theme.dart';
import '../widgets/rabbit_emoticon.dart';

class ResultScreen extends StatefulWidget {
  final String emotion;
  final String diary;
  final DateTime date;
  final List<Map<String, String>>? chatMessages; // 상담 메시지 추가
  final Map<String, dynamic>? analysisData; // 분석 데이터 추가
  
  const ResultScreen({
    Key? key, 
    required this.emotion, 
    required this.diary, 
    required this.date,
    this.chatMessages,
    this.analysisData,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 상담 결과 데이터 생성
    final counselingResult = _generateCounselingResult();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CommonAppBar(title: 'AI 상담 결과', emoji: '🤖'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: LifewispGradients.onboardingBgFor('emotion', dark: isDark).asBoxDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 메인 감정 카드
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildMainEmotionCard(counselingResult),
                    ),
                  ),

                  SizedBox(height: 24),

                  // 상담 요약
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildCounselingSummary(counselingResult),
                  ),

                  SizedBox(height: 24),

                  // 감정 분석
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildEmotionAnalysis(counselingResult),
                  ),

                  SizedBox(height: 24),

                  // 개선 방안
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildImprovementSuggestions(counselingResult),
                  ),

                  SizedBox(height: 24),

                  // 다음 단계
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildNextSteps(context),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainEmotionCard(Map<String, dynamic> counselingResult) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emotion = counselingResult['primaryEmotion'];
    final emotionName = counselingResult['emotionName'];
    final confidence = counselingResult['confidence'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? LifewispColors.darkCardBg.withOpacity(0.9) : Colors.white.withOpacity(0.9),
            isDark ? LifewispColors.darkCardBg.withOpacity(0.7) : Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? LifewispColors.darkPrimary.withOpacity(0.3) : LifewispColors.accent.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // 배경 장식
          Positioned(
            top: 20,
            right: 25,
            child: Text('✨', style: TextStyle(fontSize: 20)),
          ),

          Column(
            children: [
              // 감정 토끼 이모티콘 - 배경 제거
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [LifewispColors.darkPrimary.withOpacity(0.1), LifewispColors.darkPrimary.withOpacity(0.05)]
                        : [LifewispColors.accent.withOpacity(0.1), LifewispColors.accent.withOpacity(0.05)],
                  ),
                  border: Border.all(
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    width: 2,
                  ),
                ),
                child: RabbitEmoticon(
                  emotion: _convertEmotionToRabbit(emotion),
                  size: 90,
                ),
              ),

              SizedBox(height: 16),

              // 감정 이름
              Text(
                emotionName,
                style: GoogleFonts.jua(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8),

              // 신뢰도
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    width: 1,
                  ),
                ),
                child: Text(
                  '분석 신뢰도: ${(confidence * 100).toInt()}%',
                  style: LifewispTextStyles.getStaticFont(
                    context,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 감정 이모지를 토끼 감정으로 변환
  RabbitEmotion _convertEmotionToRabbit(String emotion) {
    switch (emotion) {
      case '😔':
        return RabbitEmotion.sad;
      case '😊':
        return RabbitEmotion.happy;
      case '😰':
        return RabbitEmotion.anxious;
      case '😠':
        return RabbitEmotion.angry;
      case '😴':
        return RabbitEmotion.tired;
      case '😍':
        return RabbitEmotion.love;
      case '😤':
        return RabbitEmotion.confidence;
      case '😌':
        return RabbitEmotion.calm;
      case '🤩':
        return RabbitEmotion.excited;
      case '😞':
        return RabbitEmotion.despair;
      default:
        return RabbitEmotion.calm; // 기본값
    }
  }

  Widget _buildCounselingSummary(Map<String, dynamic> counselingResult) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = counselingResult['summary'];
    final keywords = List<String>.from(counselingResult['keywords'] ?? []); // 타입 안전성 확보

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? LifewispColors.darkCardBg.withOpacity(0.9) : Colors.white.withOpacity(0.9),
            isDark ? LifewispColors.darkCardBg.withOpacity(0.7) : Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology,
                  color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'AI 상담 요약',
                style: LifewispTextStyles.getStaticFont(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            summary,
            style: LifewispTextStyles.getStaticFont(
              context,
              fontSize: 16,
              color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              height: 1.6,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords.map<Widget>((keyword) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    LifewispColors.pink.withOpacity(0.1),
                    LifewispColors.purple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: LifewispColors.pink.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                keyword,
                style: LifewispTextStyles.getStaticFont(
                  context,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkPink : LifewispColors.pink,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionAnalysis(Map<String, dynamic> counselingResult) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insights = List<String>.from(counselingResult['insights'] ?? []); // 타입 안전성 확보

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? LifewispColors.darkCardBg.withOpacity(0.9) : Colors.white.withOpacity(0.9),
            isDark ? LifewispColors.darkCardBg.withOpacity(0.7) : Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics,
                  color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '감정 분석 인사이트',
                style: GoogleFonts.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...insights.map<Widget>((insight) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Text(
                    insight,
                    style: LifewispTextStyles.getStaticFont(
                      context,
                      fontSize: 14,
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildImprovementSuggestions(Map<String, dynamic> counselingResult) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final suggestions = List<String>.from(counselingResult['suggestions'] ?? []); // 타입 안전성 확보

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? LifewispColors.darkCardBg.withOpacity(0.9) : Colors.white.withOpacity(0.9),
            isDark ? LifewispColors.darkCardBg.withOpacity(0.7) : Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '개선 방안',
                style: GoogleFonts.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...suggestions.map<Widget>((suggestion) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    suggestion,
                    style: GoogleFonts.jua(
                      fontSize: 14,
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildNextSteps(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscription = context.watch<SubscriptionProvider>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? LifewispColors.darkCardBg.withOpacity(0.9) : Colors.white.withOpacity(0.9),
            isDark ? LifewispColors.darkCardBg.withOpacity(0.7) : Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '다음 단계',
                style: LifewispTextStyles.getStaticFont(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (subscription.isPremium) ...[
            _buildNextStepItem(
              context,
              '📊 AI 고급 분석',
              '더 깊은 감정 패턴 분석을 확인해보세요',
              () => Navigator.pushNamed(context, '/advanced_analysis'),
            ),
            _buildNextStepItem(
              context,
              '📝 감정 기록',
              '오늘의 감정을 기록해보세요',
              () => Navigator.pushNamed(context, '/emotion_record'),
            ),
            _buildNextStepItem(
              context,
              '📈 월간 리포트',
              '월간 감정 변화 리포트를 확인해보세요',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('곧 출시될 기능입니다! 🚀')),
                );
              },
            ),
          ] else ...[
            _buildNextStepItem(
              context,
              '📝 감정 기록',
              '정기적으로 감정을 기록해보세요',
              () => Navigator.pushNamed(context, '/emotion_record'),
            ),
            _buildNextStepItem(
              context,
              '🤖 AI 상담사',
              '더 많은 상담을 위해 프리미엄을 고려해보세요',
              () => Navigator.pushNamed(context, '/subscription'),
            ),
            _buildNextStepItem(
              context,
              '📊 기본 분석',
              '현재 감정 통계를 확인해보세요',
              () => Navigator.pushNamed(context, '/analysis'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextStepItem(
    BuildContext context,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? LifewispColors.darkCardBg.withOpacity(0.9) : Colors.white.withOpacity(0.9),
              isDark ? LifewispColors.darkCardBg.withOpacity(0.7) : Colors.white.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: LifewispTextStyles.getStaticFont(
                      context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: LifewispTextStyles.getStaticFont(
                      context,
                      fontSize: 14,
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _generateCounselingResult() {
    // 상담 메시지에서 감정 분석
    final emotion = widget.emotion;
    final diary = widget.diary;

    // 감정별 분석 데이터
    final emotionData = <String, Map<String, dynamic>>{
      '😔': {
        'name': '슬픔/우울',
        'confidence': 0.85,
        'summary': '현재 슬픔이나 우울한 감정을 경험하고 계시는 것 같습니다. 이런 감정은 자연스러운 반응이며, 충분히 이해받을 가치가 있습니다.',
        'keywords': ['#위로', '#자기돌봄', '#감정인정'],
        'insights': [
          '슬픔은 자연스러운 감정 반응입니다',
          '자신의 감정을 인정하는 것이 중요합니다',
          '작은 것부터 시작해보세요',
        ],
        'suggestions': [
          '따뜻한 차 한 잔과 함께 마음의 평화를 찾아보세요',
          '좋아하는 음악을 들어보세요',
          '자연 속에서 시간을 보내보세요',
        ],
      },
      '😊': {
        'name': '행복/기쁨',
        'confidence': 0.90,
        'summary': '긍정적인 감정을 경험하고 계시는군요! 이런 순간들을 소중히 여기고 기억해두세요.',
        'keywords': ['#감사', '#긍정', '#기쁨'],
        'insights': [
          '긍정적인 감정은 건강에 좋습니다',
          '이런 순간들을 기록해두세요',
          '주변 사람들과 나누어보세요',
        ],
        'suggestions': [
          '감사 일기를 써보세요',
          '좋은 에너지를 주변과 나누어보세요',
          '이 순간을 사진으로 남겨보세요',
        ],
      },
      '😰': {
        'name': '불안/걱정',
        'confidence': 0.88,
        'summary': '불안한 마음이 드시는군요. 불안은 미래에 대한 우려에서 나오는 경우가 많습니다.',
        'keywords': ['#호흡', '#마음챙김', '#현재집중'],
        'insights': [
          '불안은 미래에 대한 걱정입니다',
          '현재에 집중하는 것이 도움이 됩니다',
          '깊은 호흡이 긴장을 풀어줍니다',
        ],
        'suggestions': [
          '4-7-8 호흡법을 시도해보세요',
          '지금 할 수 있는 것에 집중해보세요',
          '마음챙김 명상을 해보세요',
        ],
      },
      '😠': {
        'name': '분노/화남',
        'confidence': 0.82,
        'summary': '화가 나시는군요. 분노는 자연스러운 감정이지만, 건강하게 표현하는 것이 중요합니다.',
        'keywords': ['#감정조절', '#호흡', '#시간'],
        'insights': [
          '분노는 자연스러운 감정입니다',
          '잠시 멈추고 생각해보세요',
          '건강한 방법으로 표현해보세요',
        ],
        'suggestions': [
          '10까지 세어보세요',
          '화가 난 이유를 적어보세요',
          '잠시 다른 일을 해보세요',
        ],
      },
      '😴': {
        'name': '피곤/지침',
        'confidence': 0.85,
        'summary': '피곤하시군요. 충분한 휴식이 필요해 보입니다. 몸과 마음이 쉬고 싶어하고 있어요.',
        'keywords': ['#휴식', '#수면', '#자기돌봄'],
        'insights': [
          '피곤함은 휴식이 필요하다는 신호입니다',
          '충분한 수면이 중요합니다',
          '자기 돌봄이 필요합니다',
        ],
        'suggestions': [
          '충분한 수면을 취해보세요',
          '따뜻한 차 한 잔을 마셔보세요',
          '좋아하는 음악을 들어보세요',
        ],
      },
    };

    final defaultData = <String, dynamic>{
      'name': '복합 감정',
      'confidence': 0.75,
      'summary': '다양한 감정을 경험하고 계시는군요. 이런 감정들이 모두 소중하고 의미가 있습니다.',
      'keywords': ['#감정인정', '#자기이해', '#성장'],
      'insights': [
        '모든 감정은 의미가 있습니다',
        '감정을 표현하는 것이 중요합니다',
        '자신을 이해하는 시간이 필요합니다',
      ],
      'suggestions': [
        '감정 일기를 써보세요',
        '자신에게 친절해지세요',
        '전문가와 상담을 고려해보세요',
      ],
    };

    final data = emotionData[emotion] ?? defaultData;

    return <String, dynamic>{
      'primaryEmotion': emotion,
      'emotionName': data['name'],
      'confidence': data['confidence'],
      'summary': data['summary'],
      'keywords': data['keywords'],
      'insights': data['insights'],
      'suggestions': data['suggestions'],
    };
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/rabbit_emoticon.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/premium_gate.dart';
import '../utils/theme.dart';
import '../models/emotion_record.dart';
import '../utils/ai_analysis_utils.dart';
import '../widgets/emotion_charts.dart';
import 'package:google_fonts/google_fonts.dart';

class AdvancedAnalysisScreen extends StatefulWidget {
  const AdvancedAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedAnalysisScreen> createState() => _AdvancedAnalysisScreenState();
}

class _AdvancedAnalysisScreenState extends State<AdvancedAnalysisScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;

  // 추천 리스트 추가
  final List<Map<String, String>> recommendations = [
    {
      'icon': '🧘‍♀️',
      'title': '명상 앱 사용하기',
      'description': '스트레스 관리를 위해 하루 10분 명상을 추천해요',
      'difficulty': '쉬움',
    },
    {
      'icon': '📖',
      'title': '감정 일기 쓰기',
      'description': '더 깊은 자기 성찰을 위해 상세한 일기를 써보세요',
      'difficulty': '보통',
    },
    {
      'icon': '🏃‍♀️',
      'title': '규칙적인 운동',
      'description': '신체 활동으로 감정 조절 능력을 향상시켜보세요',
      'difficulty': '보통',
    },
    {
      'icon': '🌅',
      'title': '아침 루틴 만들기',
      'description': '긍정적인 하루를 시작하기 위한 아침 습관을 만들어보세요',
      'difficulty': '어려움',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartAnimationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 프리미엄이 아닌 경우 Premium Gate 표시
    if (!subscription.isPremium) {
      return Scaffold(
        appBar: CommonAppBar(title: 'AI 고급 분석', emoji: '📊'),
        body: Container(
          decoration: BoxDecoration(
            gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
          ),
          child: PremiumGate(
            child: Container(),
            featureName: 'advanced_analysis',
            title: 'AI 고급 분석',
            description: 'AI가 당신의 감정 패턴을 깊이 있게 분석하고\n개인화된 인사이트를 제공합니다',
            features: [
              '📈 감정 패턴 AI 분석',
              '🤖 월간 AI 회고 리포트',
              '💡 맞춤형 감정 케어 조언',
              '📊 고급 통계 및 차트',
              '🎯 개인화된 성장 목표',
              '🔄 상담 데이터 기반 분석',
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CommonAppBar(
        title: 'AI 고급 분석',
        emoji: '🤖',
        backgroundColor: isDark 
            ? LifewispColors.darkCardBg.withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [LifewispColors.accent, LifewispColors.accentDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('✨', style: TextStyle(fontSize: 12)),
                SizedBox(width: 4),
                Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
        ),
        child: Column(
          children: [
            Container(
              color: isDark 
                  ? LifewispColors.darkCardBg.withOpacity(0.95)
                  : Colors.white.withOpacity(0.95),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🤖', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 4),
                        Text('AI 회고'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📊', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 4),
                        Text('패턴 분석'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🚀', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 4),
                        Text('성장 추적'),
                      ],
                    ),
                  ),
                ],
                labelColor: isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
                unselectedLabelColor: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                indicatorColor: isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAIReflectionTab(),
                    _buildPatternAnalysisTab(),
                    _buildGrowthTrackingTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIReflectionTab() {
    final records = context.watch<EmotionProvider>().records ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // AI 분석 실행
    final analysis = AIAnalysisUtils.analyzeEmotionPatterns(records);
    final recommendations = AIAnalysisUtils.generatePersonalizedRecommendations(analysis);

    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMonthlyHeader('${DateTime.now().month}월'),
            SizedBox(height: 20),
            _buildAIReflectionCard(analysis),
            SizedBox(height: 20),
            _buildCounselingInsights(records), // 상담 인사이트 추가
            SizedBox(height: 20),
            _buildPersonalizedRecommendations(recommendations),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // 상담 인사이트 위젯 추가
  Widget _buildCounselingInsights(List<EmotionRecord> records) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 최근 상담 데이터 분석 (실제로는 상담 데이터를 저장하고 불러와야 함)
    final recentCounselingData = _analyzeRecentCounseling(records);

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
                'AI 상담 인사이트',
                style: GoogleFonts.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...recentCounselingData['insights'].map((insight) => Padding(
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

  // 최근 상담 데이터 분석 (예시)
  Map<String, dynamic> _analyzeRecentCounseling(List<EmotionRecord> records) {
    // 실제로는 상담 데이터를 저장하고 불러와야 함
    // 현재는 감정 기록을 기반으로 상담 인사이트 생성
    
    final recentRecords = records.take(7).toList(); // 최근 7일
    final positiveEmotions = ['happy', 'love', 'calm', 'excited', 'confidence'];
    final negativeEmotions = ['sad', 'angry', 'anxious', 'tired', 'despair'];
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (var record in recentRecords) {
      if (positiveEmotions.contains(record.emotion)) {
        positiveCount++;
      } else if (negativeEmotions.contains(record.emotion)) {
        negativeCount++;
      }
    }
    
    List<String> insights = [];
    
    if (positiveCount > negativeCount) {
      insights.add('최근 상담에서 긍정적인 감정이 많이 나타났어요. 좋은 변화가 일어나고 있는 것 같습니다!');
      insights.add('자기 돌봄에 대한 의식이 높아진 것으로 보입니다.');
    } else if (negativeCount > positiveCount) {
      insights.add('최근 상담에서 어려운 감정들이 많이 나타났어요. 이런 감정들을 충분히 인정하고 위로받으세요.');
      insights.add('전문가 상담을 고려해보시는 것도 좋겠어요.');
    } else {
      insights.add('감정의 기복이 있는 것으로 보입니다. 이는 자연스러운 현상입니다.');
      insights.add('감정 조절 연습이 도움이 될 수 있어요.');
    }
    
    insights.add('정기적인 상담이 감정 건강에 도움이 됩니다.');
    
    return {
      'insights': insights,
      'positiveCount': positiveCount,
      'negativeCount': negativeCount,
    };
  }

  Widget _buildPatternAnalysisTab() {
    final records = context.watch<EmotionProvider>().records ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // AI 분석 실행
    final analysis = AIAnalysisUtils.analyzeEmotionPatterns(records);
    final emotionCounts = Map<String, int>.from(analysis['emotionCounts'] ?? {});
    final timePattern = Map<String, dynamic>.from(analysis['timePattern'] ?? {});

    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildEmotionDistributionChart(emotionCounts, isDark),
            SizedBox(height: 20),
            _buildWeeklyPatternChart(records, isDark),
            SizedBox(height: 20),
            _buildTimeOfDayAnalysis(timePattern, isDark),
            SizedBox(height: 20),
            _buildEmotionStabilityCard(analysis),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthTrackingTab() {
    final records = context.watch<EmotionProvider>().records ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // AI 분석 실행
    final analysis = AIAnalysisUtils.analyzeEmotionPatterns(records);
    final recommendations = AIAnalysisUtils.generatePersonalizedRecommendations(analysis);

    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProgressOverview(analysis),
            SizedBox(height: 20),
            _buildGoalTracker(),
            SizedBox(height: 20),
            _buildMilestoneAchievements(records),
            SizedBox(height: 20),
            _buildPersonalizedRecommendations(recommendations),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // AI 회고 관련 위젯들
  Widget _buildMonthlyHeader(String monthName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDark ? LifewispGradients.onboardingBgDark : LifewispGradients.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? LifewispColors.darkPrimary.withOpacity(0.3)
                : LifewispColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$monthName AI 감정 분석',
                      style: isDark
                          ? LifewispTextStyles.darkTitle.copyWith(color: Colors.white)
                          : LifewispTextStyles.title.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '인공지능이 당신의 감정 패턴을 깊이 분석했습니다',
                      style: isDark
                          ? LifewispTextStyles.darkSubtitle.copyWith(color: Colors.white.withOpacity(0.9))
                          : LifewispTextStyles.subtitle.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIReflectionCard(Map<String, dynamic> analysis) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insights = List<String>.from(analysis['insights'] ?? ['분석 데이터가 없습니다.']);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
          colors: [LifewispColors.darkCardBg, LifewispColors.darkCardBg.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LifewispGradients.secondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? LifewispColors.darkSecondary.withOpacity(0.3)
                : LifewispColors.secondary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 감정 분석 리포트',
                      style: isDark
                          ? LifewispTextStyles.darkTitle.copyWith(color: Colors.white)
                          : LifewispTextStyles.title.copyWith(color: Colors.white),
                    ),
                    Text(
                      '인공지능이 당신의 감정을 분석했습니다',
                      style: isDark
                          ? LifewispTextStyles.darkSubtitle.copyWith(color: Colors.white.withOpacity(0.8))
                          : LifewispTextStyles.subtitle.copyWith(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...insights.map((insight) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: isDark
                        ? LifewispTextStyles.darkSubtitle.copyWith(color: Colors.white.withOpacity(0.9))
                        : LifewispTextStyles.subtitle.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmotionDistributionChart(Map<String, int> emotionCounts, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                '감정 분포 분석',
                style: isDark ? LifewispTextStyles.darkTitle : LifewispTextStyles.title,
              ),
            ],
          ),
          SizedBox(height: 20),
          EmotionCharts.buildEmotionDistributionChart(emotionCounts, isDark),
        ],
      ),
    );
  }

  Widget _buildWeeklyPatternChart(List<EmotionRecord> records, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📅', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                '주간 감정 패턴',
                style: isDark ? LifewispTextStyles.darkTitle : LifewispTextStyles.title,
              ),
            ],
          ),
          SizedBox(height: 20),
          EmotionCharts.buildWeeklyPatternChart(records, isDark),
        ],
      ),
    );
  }

  Widget _buildTimeOfDayAnalysis(Map<String, dynamic> timePattern, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('⏰', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                '시간대별 감정 분석',
                style: isDark ? LifewispTextStyles.darkTitle : LifewispTextStyles.title,
              ),
            ],
          ),
          SizedBox(height: 20),
          EmotionCharts.buildTimeOfDayChart(timePattern, isDark),
        ],
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeSlots = ['오전', '오후', '저녁', '밤'];
    final emotions = ['😊', '😢', '😤', '😰'];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? LifewispColors.darkCardBg.withOpacity(0.5) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emotions[index], style: TextStyle(fontSize: 24)),
              SizedBox(height: 8),
              Text(
                timeSlots[index],
                style: isDark ? LifewispTextStyles.darkSubtitle : LifewispTextStyles.subtitle,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmotionStabilityCard(Map<String, dynamic> analysis) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emotionStability = (analysis['emotionStability'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🎯', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                '감정 안정성 분석',
                style: isDark ? LifewispTextStyles.darkTitle : LifewispTextStyles.title,
              ),
            ],
          ),
          SizedBox(height: 20),
          EmotionCharts.buildEmotionStabilityGauge(emotionStability, isDark),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(Map<String, dynamic> analysis) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final growthTrend = (analysis['growthTrend'] as String?) ?? 'stable';
    final totalRecords = (analysis['totalRecords'] as num?)?.toInt() ?? 0;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [LifewispColors.darkPrimary, LifewispColors.darkSecondary]
              : [LifewispColors.accent, LifewispColors.accentDark],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? LifewispColors.darkPrimary.withOpacity(0.4)
                : LifewispColors.accent.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🚀', style: TextStyle(fontSize: 32)),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '감정 성장 현황',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getProgressDescription(growthTrend, totalRecords),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem('📈', '성장률', '+25%', Colors.white),
              SizedBox(width: 16),
              _buildStatItem('🎯', '목표 달성', '3/4', Colors.white),
              SizedBox(width: 16),
              _buildStatItem('🔥', '연속 기록', '7일', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value, Color textColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            RabbitEmoticon(
              emotion: _convertEmojiToRabbitEmotion(emoji),
              size: 20,
              backgroundColor: Colors.transparent,
              borderColor: Colors.transparent,
              borderWidth: 0,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTracker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final goals = [
      {'title': '일주일 연속 감정 기록', 'progress': 1.0, 'status': '완료', 'icon': '✅'},
      {'title': '긍정적 감정 늘리기', 'progress': 0.7, 'status': '진행중', 'icon': '😊'},
      {'title': '스트레스 관리 기법 연습', 'progress': 0.4, 'status': '시작', 'icon': '🧘‍♀️'},
      {'title': '감정 일기 쓰기', 'progress': 0.9, 'status': '거의 완료', 'icon': '📖'},
    ];

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
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
              Text('🎯', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                '목표 달성 현황',
                style: isDark ? LifewispTextStyles.darkTitle : LifewispTextStyles.title,
              ),
            ],
          ),
          SizedBox(height: 20),
          ...goals.map((goal) => Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? LifewispColors.darkPrimary.withOpacity(0.1)
                  : LifewispColors.accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? LifewispColors.darkPrimary.withOpacity(0.3)
                    : LifewispColors.accent.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(goal['icon'] as String, style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(goal['status'] as String).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        goal['status'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(goal['status'] as String),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: goal['progress'] as double,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(goal['status'] as String),
                            _getStatusColor(goal['status'] as String).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${((goal['progress'] as double) * 100).toInt()}% 완료',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildMilestoneAchievements(List<EmotionRecord> records) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalRecords = records.length;
    final now = DateTime.now();
    final firstRecord = records.isNotEmpty ? records.first.date : null;
    
    // 동적으로 업적 계산
    final achievements = [
      {
        'title': '첫 감정 기록',
        'date': firstRecord != null ? '${firstRecord.year}.${firstRecord.month.toString().padLeft(2, '0')}.${firstRecord.day.toString().padLeft(2, '0')}' : '미달성',
        'icon': '🎉',
        'earned': totalRecords > 0
      },
      {
        'title': '일주일 연속 기록',
        'date': _calculateStreak(records) >= 7 ? '달성!' : '미달성',
        'icon': '🔥',
        'earned': _calculateStreak(records) >= 7
      },
      {
        'title': '한 달 완주',
        'date': _calculateMonthlyRecords(records) >= 30 ? '달성!' : '미달성',
        'icon': '🏆',
        'earned': _calculateMonthlyRecords(records) >= 30
      },
      {
        'title': '100일 달성',
        'date': totalRecords >= 100 ? '달성!' : '미달성',
        'icon': '💎',
        'earned': totalRecords >= 100
      },
    ];

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
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
              Text('🏆', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                '달성한 마일스톤',
                style: isDark ? LifewispTextStyles.darkTitle : LifewispTextStyles.title,
              ),
            ],
          ),
          SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final earned = achievement['earned'] as bool;

              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: earned
                      ? LinearGradient(
                    colors: [
                      LifewispColors.accent.withOpacity(0.1),
                      LifewispColors.accentDark.withOpacity(0.1),
                    ],
                  )
                      : null,
                  color: earned ? null : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: earned
                        ? LifewispColors.accent.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      achievement['icon'] as String,
                      style: TextStyle(
                        fontSize: 32,
                        color: earned ? null : Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      achievement['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: earned
                            ? (isDark ? LifewispColors.darkMainText : LifewispColors.mainText)
                            : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      achievement['date'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: earned
                            ? (isDark ? LifewispColors.darkSubText : LifewispColors.subText)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedRecommendations(List<Map<String, dynamic>> recommendations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
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
              Text('💡', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                'AI 맞춤 추천',
                style: isDark ? LifewispTextStyles.darkTitle : LifewispTextStyles.title,
              ),
            ],
          ),
          SizedBox(height: 20),
          ...recommendations.map((rec) => Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? LifewispColors.darkPrimary.withOpacity(0.1)
                  : LifewispColors.accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? LifewispColors.darkPrimary.withOpacity(0.3)
                    : LifewispColors.accent.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [LifewispColors.accent, LifewispColors.accentDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(rec['icon'] as String, style: TextStyle(fontSize: 24)),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              rec['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(rec['difficulty'] as String).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              rec['difficulty'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getDifficultyColor(rec['difficulty'] as String),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        rec['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildGrowthInsights(Map<String, dynamic> analysis) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final growthTrend = (analysis['growthTrend'] as String?) ?? 'stable';
    final emotionStability = (analysis['emotionStability'] as num?)?.toDouble() ?? 0.0;

    final insights = [
      {
        'icon': '📈',
        'title': '감정 인식 능력 향상',
        'description': '이전 달보다 더 다양한 감정을 인식하고 표현하고 있어요',
        'progress': 0.8,
        'color': Colors.green,
      },
      {
        'icon': '🎯',
        'title': '감정 조절 연습',
        'description': '부정적인 감정을 건강하게 처리하는 방법을 터득했어요',
        'progress': 0.65,
        'color': Colors.blue,
      },
      {
        'icon': '🌱',
        'title': '자기 이해 증진',
        'description': '감정 패턴을 파악하며 자신을 더 잘 알아가고 있어요',
        'progress': 0.9,
        'color': Colors.purple,
      },
    ];

    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-50 * (1 - _chartAnimation.value), 0),
          child: Opacity(
            opacity: _chartAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [LifewispColors.darkCardBg, LifewispColors.darkCardBg.withOpacity(0.8)]
                      : [Colors.white, Colors.white.withOpacity(0.9)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [LifewispColors.accent, LifewispColors.accentDark],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('🚀', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '성장 인사이트',
                        style: isDark
                            ? LifewispTextStyles.darkTitle
                            : LifewispTextStyles.title,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...insights.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> insight = entry.value;

                    return AnimatedBuilder(
                      animation: _chartAnimation,
                      builder: (context, child) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 800 + (index * 200)),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? LifewispColors.darkPrimary.withOpacity(0.1)
                                : (insight['color'] as Color).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (insight['color'] as Color).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    insight['icon'] as String,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      insight['title'] as String,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? LifewispColors.darkMainText
                                            : LifewispColors.mainText,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (insight['color'] as Color).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${((insight['progress'] as double) * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: insight['color'] as Color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                insight['description'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? LifewispColors.darkSubText
                                      : LifewispColors.subText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1000 + (index * 300)),
                                  width: MediaQuery.of(context).size.width *
                                      (insight['progress'] as double) * _chartAnimation.value,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        insight['color'] as Color,
                                        (insight['color'] as Color).withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalizedTips(List<Map<String, dynamic>> recommendations) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [LifewispColors.darkSecondary, LifewispColors.darkSecondary.withOpacity(0.8)]
              : [LifewispColors.purple, LifewispColors.purpleDark],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? LifewispColors.darkSecondary.withOpacity(0.4)
                : LifewispColors.purple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('💡', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI 맞춤 케어 팁',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...recommendations.take(4).map((recommendation) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(recommendation['icon']!, style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              recommendation['category']!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(recommendation['difficulty']!).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              recommendation['difficulty']!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        recommendation['title']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        recommendation['description']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildNextMonthGoals(Map<String, dynamic> analysis) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dominantEmotion = (analysis['dominantEmotion'] as String?) ?? 'none';
    final growthTrend = (analysis['growthTrend'] as String?) ?? 'stable';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [LifewispColors.darkPrimary, LifewispColors.darkPrimary.withOpacity(0.8)]
              : [LifewispColors.accent, LifewispColors.accentDark],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? LifewispColors.darkPrimary.withOpacity(0.4)
                : LifewispColors.accent.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🎯', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI 추천 목표',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGoalTitle(dominantEmotion, growthTrend),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getGoalDescription(dominantEmotion, growthTrend),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'AI 목표 설정하기',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('🤖', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEmotionName(String emotion) {
    Map<String, String> names = {
      'happy': '행복함',
      'sad': '슬픔',
      'angry': '화남',
      'love': '사랑',
      'anxious': '불안',
      'excited': '흥분',
      'calm': '평온',
      'tired': '피곤',
    };
    return names[emotion] ?? '알 수 없음';
  }

  String _getWeeklyInsight(Map<int, List<String>> weekdayEmotions) {
    // 가장 감정 기록이 많은 요일 찾기
    int maxDay = 1;
    int maxCount = 0;
    weekdayEmotions.forEach((day, emotions) {
      if (emotions.length > maxCount) {
        maxCount = emotions.length;
        maxDay = day;
      }
    });
    
    List<String> dayNames = ['', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return 'AI 분석: ${dayNames[maxDay]}에 가장 활발한 감정 활동을 보이고 있어요. 이날에 더 의식적으로 감정을 관찰해보시는 것을 추천드려요!';
  }

  String _generateAIComment(String? topEmotion, int recordCount) {
    if (recordCount == 0) {
      return '🤖 AI 분석: 아직 이번 달 감정 기록이 없어요. 꾸준한 기록이 정확한 분석의 시작입니다! 오늘부터 감정 여행을 시작해보세요.';
    }

    switch (topEmotion) {
      case 'happy':
      case '😊':
        return '🤖 AI 분석: 이번 달은 긍정적인 감정이 ${((recordCount * 0.6).round())}% 이상을 차지했어요! 행복한 순간들을 잘 포착하고 계시네요. 이런 긍정적 패턴을 유지하면서, 가끔 오는 부정적 감정도 자연스럽게 받아들이는 연습을 해보세요. 감정의 균형이 건강한 정신 건강의 열쇠입니다.';

      case 'sad':
      case '😢':
        return '🤖 AI 분석: 이번 달 슬픔의 감정이 많이 감지되었어요. 하지만 이런 감정을 솔직하게 기록하신 것 자체가 큰 용기입니다. 슬픔은 치유와 성장의 과정에서 중요한 역할을 해요. 점차 밝은 감정도 함께 기록해보시길 추천드려요. 작은 기쁨도 소중한 감정이니까요.';

      case 'angry':
      case '😤':
        return '🤖 AI 분석: 분노의 패턴을 발견했어요. 화가 나는 상황을 명확히 인식하고 기록하신 점이 인상적입니다. 분노는 경계를 설정하고 변화를 만드는 자연스러운 감정이에요. 이제 이 에너지를 건설적으로 활용하는 방법을 찾아보세요. 운동, 창작 활동, 또는 건설적인 대화를 통해 표현해보는 건 어떨까요?';

      case 'love':
      case '🥰':
        return '🤖 AI 분석: 사랑과 애정이 가득한 한 달이었네요! 따뜻한 감정들이 많이 기록되어 있어요. 이런 긍정적 에너지를 주변 사람들과 나누면서 더욱 풍요로운 감정 생활을 만들어가세요. 사랑은 나눌수록 더 커지는 감정이에요.';

      case 'anxious':
      case '😰':
        return '🤖 AI 분석: 불안 감정이 주를 이뤘어요. 불안을 느끼는 것은 자연스럽고, 이를 인식하신 것만으로도 큰 발전이에요. 심호흡이나 명상 등 불안 관리 기법을 시도해보시고, 작은 성취들도 함께 기록해보세요. 불안은 우리가 무언가를 소중히 여긴다는 신호이기도 해요.';

      default:
        return '🤖 AI 분석: 다양한 감정이 균형있게 나타났어요! 풍부한 감정 표현력을 가지고 계시네요. 각각의 감정이 주는 메시지를 이해하면서, 더욱 깊이 있는 자기 인식을 키워가시길 바랍니다. 꾸준한 기록이 성장의 밑거름입니다!';
    }
  }

  String _getProgressDescription(String growthTrend, int totalRecords) {
    if (totalRecords == 0) {
      return '아직 기록된 감정이 없어요. 오늘부터 감정 여행을 시작해보세요!';
    }
    
    switch (growthTrend) {
      case 'improving':
        return '최근 감정 상태가 개선되고 있어요! 긍정적인 변화를 경험하고 있습니다.';
      case 'declining':
        return '최근 감정 상태가 다소 어려워지고 있어요. 전문가 상담을 고려해보세요.';
      default:
        return '감정 상태가 비교적 안정적이에요. 일관된 마음 상태를 유지하고 있습니다.';
    }
  }

  int _calculateStreak(List<EmotionRecord> records) {
    if (records.isEmpty) return 0;
    
    final sortedRecords = records.toList()..sort((a, b) => b.date.compareTo(a.date));
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 30; i++) { // 최대 30일 확인
      final checkDate = now.subtract(Duration(days: i));
      final hasRecord = sortedRecords.any((r) =>
          r.date.year == checkDate.year &&
          r.date.month == checkDate.month &&
          r.date.day == checkDate.day);
      
      if (hasRecord) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  int _calculateMonthlyRecords(List<EmotionRecord> records) {
    if (records.isEmpty) return 0;
    
    final now = DateTime.now();
    return records.where((r) =>
        r.date.year == now.year && r.date.month == now.month).length;
  }

  String _getGoalTitle(String dominantEmotion, String growthTrend) {
    if (dominantEmotion == 'none') {
      return '🌟 감정 기록 습관화하기';
    }
    
    switch (dominantEmotion) {
      case 'sad':
        return '💙 긍정적 감정 늘리기';
      case 'anxious':
        return '🧘‍♀️ 마음의 평화 찾기';
      case 'angry':
        return '🔥 스트레스 관리하기';
      case 'tired':
        return '😴 에너지 회복하기';
      default:
        return '🌟 감정 균형 유지하기';
    }
  }

  String _getGoalDescription(String dominantEmotion, String growthTrend) {
    if (dominantEmotion == 'none') {
      return 'AI 분석을 통해 당신에게 가장 적합한 감정 관리 목표를 제안합니다. 작은 변화도 소중한 성장입니다.';
    }
    
    switch (dominantEmotion) {
      case 'sad':
        return '슬픈 감정이 자주 나타나고 있어요. 작은 기쁨을 찾고 감사한 일들을 기록해보세요.';
      case 'anxious':
        return '불안한 감정이 많아 보여요. 명상과 호흡 운동으로 마음의 평화를 찾아보세요.';
      case 'angry':
        return '분노 감정이 자주 나타나고 있어요. 운동이나 창작 활동으로 스트레스를 해소해보세요.';
      case 'tired':
        return '피곤한 감정이 많아 보여요. 충분한 휴식과 규칙적인 생활로 에너지를 회복해보세요.';
      default:
        return 'AI 분석을 통해 당신에게 가장 적합한 감정 관리 목표를 제안합니다. 작은 변화도 소중한 성장입니다.';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '쉬움':
        return Colors.green;
      case '보통':
        return Colors.orange;
      case '어려움':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '완료':
        return Colors.green;
      case '진행중':
        return Colors.blue;
      case '거의 완료':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildWeeklyStreakWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🔥', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Text(
                '7일 연속 기록 달성!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            '꾸준한 감정 기록으로 건강한 습관을 만들어가고 있어요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '✓',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  RabbitEmotion _convertEmojiToRabbitEmotion(String emoji) {
    switch (emoji) {
      case '📈': return RabbitEmotion.confidence;
      case '🎯': return RabbitEmotion.happy;
      case '🔥': return RabbitEmotion.excited;
      case '😊': return RabbitEmotion.happy;
      case '😢': return RabbitEmotion.sad;
      case '😡': return RabbitEmotion.angry;
      case '😰': return RabbitEmotion.anxious;
      case '😴': return RabbitEmotion.tired;
      case '😍': return RabbitEmotion.love;
      case '😌': return RabbitEmotion.calm;
      case '🤩': return RabbitEmotion.excited;
      case '😞': return RabbitEmotion.despair;
      case '😤': return RabbitEmotion.confidence;
      default: return RabbitEmotion.happy;
    }
  }
}
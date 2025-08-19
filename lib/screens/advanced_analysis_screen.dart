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
import '../screens/goal_setting_screen.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
      backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.grey[50],
      appBar: CommonAppBar(
        title: 'AI 고급 분석',
        emoji: '🤖',
        backgroundColor: isDark
            ? LifewispColors.darkCardBg.withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenHeight * 0.008,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [LifewispColors.accent, LifewispColors.accentDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('✨', style: TextStyle(fontSize: screenWidth * 0.03)),
                SizedBox(width: 4),
                Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
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
            // 탭바 컨테이너
            Container(
              color: isDark
                  ? LifewispColors.darkCardBg.withOpacity(0.95)
                  : Colors.white.withOpacity(0.95),
              child: _buildResponsiveTabBar(screenWidth, isDark),
            ),
            // 탭뷰 컨텐츠
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAIReflectionTab(screenWidth, screenHeight),
                    _buildPatternAnalysisTab(screenWidth, screenHeight),
                    _buildGrowthTrackingTab(screenWidth, screenHeight),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveTabBar(double screenWidth, bool isDark) {
    // 화면 크기에 따른 탭 텍스트 크기 조정
    final fontSize = screenWidth < 360 ? 12.0 : 14.0;
    final iconSize = screenWidth < 360 ? 14.0 : 16.0;

    return TabBar(
      controller: _tabController,
      isScrollable: screenWidth < 400, // 작은 화면에서는 스크롤 가능
      tabs: [
        _buildResponsiveTab('🤖', 'AI 회고', iconSize, fontSize, screenWidth),
        _buildResponsiveTab('📊', '패턴 분석', iconSize, fontSize, screenWidth),
        _buildResponsiveTab('🚀', '성장 추적', iconSize, fontSize, screenWidth),
      ],
      labelColor: isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
      unselectedLabelColor: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
      indicatorColor: isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
      indicatorWeight: 3,
      labelStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildResponsiveTab(String emoji, String text, double iconSize, double fontSize, double screenWidth) {
    if (screenWidth < 360) {
      // 매우 작은 화면에서는 세로 배치
      return Tab(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: iconSize)),
            SizedBox(height: 2),
            Text(text, style: TextStyle(fontSize: fontSize - 2)),
          ],
        ),
      );
    } else {
      // 일반적인 가로 배치
      return Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: iconSize)),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: fontSize),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAIReflectionTab(double screenWidth, double screenHeight) {
    final records = context.watch<EmotionProvider>().records ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // AI 분석 실행
    final analysis = AIAnalysisUtils.analyzeEmotionPatterns(records);
    final recommendations = AIAnalysisUtils.generatePersonalizedRecommendations(analysis);

    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            _buildMonthlyHeader('${DateTime.now().month}월', screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            _buildAIReflectionCard(analysis, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            _buildCounselingInsights(records, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            _buildPersonalizedRecommendations(recommendations, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.12), // 하단 여백
          ],
        ),
      ),
    );
  }

  Widget _buildPatternAnalysisTab(double screenWidth, double screenHeight) {
    final records = context.watch<EmotionProvider>().records ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // AI 분석 실행
    final analysis = AIAnalysisUtils.analyzeEmotionPatterns(records);
    final emotionCounts = Map<String, int>.from(analysis['emotionCounts'] ?? {});
    final timePattern = Map<String, dynamic>.from(analysis['timePattern'] ?? {});

    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            _buildEmotionDistributionChart(emotionCounts, isDark, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            _buildWeeklyPatternChart(records, isDark, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            _buildTimeOfDayAnalysis(timePattern, isDark, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            _buildEmotionStabilityCard(analysis, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.12),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthTrackingTab(double screenWidth, double screenHeight) {
    final records = context.watch<EmotionProvider>().records ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // AI 분석 실행
    final analysis = AIAnalysisUtils.analyzeEmotionPatterns(records);
    final recommendations = AIAnalysisUtils.generatePersonalizedRecommendations(analysis);

    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            _buildProgressOverview(analysis, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            _buildGoalTracker(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            _buildMilestoneAchievements(records, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.025),
            _buildPersonalizedRecommendations(recommendations, screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.12),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyHeader(String monthName, double screenWidth, double screenHeight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
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
                width: screenWidth * 0.14,
                height: screenWidth * 0.14,
                constraints: BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                  maxWidth: 64,
                  maxHeight: 64,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    '🤖',
                    style: TextStyle(fontSize: screenWidth * 0.07),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$monthName AI 감정 분석',
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '인공지능이 당신의 감정 패턴을 깊이 분석했습니다',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
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

  Widget _buildAIReflectionCard(Map<String, dynamic> analysis, double screenWidth, double screenHeight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insights = List<String>.from(analysis['insights'] ?? ['분석 데이터가 없습니다.']);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
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
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                constraints: BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                  maxWidth: 56,
                  maxHeight: 56,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '🤖',
                    style: TextStyle(fontSize: screenWidth * 0.06),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 감정 분석 리포트',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '인공지능이 당신의 감정을 분석했습니다',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          ...insights.map((insight) => Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: screenHeight * 0.015),
            padding: EdgeInsets.all(screenWidth * 0.04),
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
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    insight,
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
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

  Widget _buildCounselingInsights(List<EmotionRecord> records, double screenWidth, double screenHeight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentCounselingData = _analyzeRecentCounseling(records);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
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
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology,
                  color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  size: screenWidth * 0.05,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  'AI 상담 인사이트',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          ...recentCounselingData['insights'].map((insight) => Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.015),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth * 0.02,
                  height: screenWidth * 0.02,
                  margin: EdgeInsets.only(top: screenHeight * 0.01, right: screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Text(
                    insight,
                    style: TextStyle(
                      fontSize: screenWidth * 0.037,
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

  Widget _buildEmotionDistributionChart(Map<String, int> emotionCounts, bool isDark, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
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
              Text('📊', style: TextStyle(fontSize: screenWidth * 0.06)),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  '감정 분포 분석',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.3,
              minHeight: screenHeight * 0.2,
            ),
            child: EmotionCharts.buildEmotionDistributionChart(emotionCounts, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPatternChart(List<EmotionRecord> records, bool isDark, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
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
              Text('📅', style: TextStyle(fontSize: screenWidth * 0.06)),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  '주간 감정 패턴',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.3,
              minHeight: screenHeight * 0.2,
            ),
            child: EmotionCharts.buildWeeklyPatternChart(records, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOfDayAnalysis(Map<String, dynamic> timePattern, bool isDark, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
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
              Text('⏰', style: TextStyle(fontSize: screenWidth * 0.06)),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  '시간대별 감정 분석',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.3,
              minHeight: screenHeight * 0.2,
            ),
            child: EmotionCharts.buildTimeOfDayChart(timePattern, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionStabilityCard(Map<String, dynamic> analysis, double screenWidth, double screenHeight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emotionStability = (analysis['emotionStability'] as num?)?.toDouble() ?? 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
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
              Text('🎯', style: TextStyle(fontSize: screenWidth * 0.06)),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  '감정 안정성 분석',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.25,
              minHeight: screenHeight * 0.15,
            ),
            child: EmotionCharts.buildEmotionStabilityGauge(emotionStability, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(Map<String, dynamic> analysis, double screenWidth, double screenHeight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final growthTrend = (analysis['growthTrend'] as String?) ?? 'stable';
    final totalRecords = (analysis['totalRecords'] as num?)?.toInt() ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
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
              Text('🚀', style: TextStyle(fontSize: screenWidth * 0.08)),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '감정 성장 현황',
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getProgressDescription(growthTrend, totalRecords),
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          // 반응형 통계 아이템들
          _buildResponsiveStatItems(screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildResponsiveStatItems(double screenWidth, double screenHeight) {
    final statItems = [
      {'emoji': '📈', 'label': '성장률', 'value': '+25%'},
      {'emoji': '🎯', 'label': '목표 달성', 'value': '3/4'},
      {'emoji': '🔥', 'label': '연속 기록', 'value': '7일'},
    ];

    // 화면 크기에 따라 레이아웃 결정
    if (screenWidth < 400) {
      // 작은 화면: 세로 배치
      return Column(
        children: statItems.map((item) => Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: screenHeight * 0.01),
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(item['emoji']!, style: TextStyle(fontSize: screenWidth * 0.06)),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  item['label']!,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              Text(
                item['value']!,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )).toList(),
      );
    } else {
      // 큰 화면: 가로 배치
      return Row(
        children: statItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < statItems.length - 1 ? screenWidth * 0.03 : 0,
              ),
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(item['emoji']!, style: TextStyle(fontSize: screenWidth * 0.06)),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    item['value']!,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    item['label']!,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildGoalTracker(double screenWidth, double screenHeight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final goals = [
      {'title': '일주일 연속 감정 기록', 'progress': 1.0, 'status': '완료', 'icon': '✅'},
      {'title': '긍정적 감정 늘리기', 'progress': 0.7, 'status': '진행중', 'icon': '😊'},
      {'title': '스트레스 관리 기법 연습', 'progress': 0.4, 'status': '시작', 'icon': '🧘‍♀️'},
      {'title': '감정 일기 쓰기', 'progress': 0.9, 'status': '거의 완료', 'icon': '📖'},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
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
              Text('🎯', style: TextStyle(fontSize: screenWidth * 0.06)),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  '목표 달성 현황',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  size: screenWidth * 0.06,
                ),
                tooltip: '목표 관리',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GoalSettingScreen()),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          ...goals.map((goal) => Container(
            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
            padding: EdgeInsets.all(screenWidth * 0.04),
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
                    Text(goal['icon'] as String, style: TextStyle(fontSize: screenWidth * 0.05)),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        goal['title'] as String,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(goal['status'] as String).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        goal['status'] as String,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(goal['status'] as String),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),
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
                SizedBox(height: screenHeight * 0.01),
                Text(
                  '${((goal['progress'] as double) * 100).toInt()}% 완료',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
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

  Widget _buildMilestoneAchievements(List<EmotionRecord> records, double screenWidth, double screenHeight) {
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
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
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
              Text('🏆', style: TextStyle(fontSize: screenWidth * 0.06)),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  '달성한 마일스톤',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          _buildResponsiveAchievementGrid(achievements, screenWidth, screenHeight, isDark),
        ],
      ),
    );
  }

  Widget _buildResponsiveAchievementGrid(List achievements, double screenWidth, double screenHeight, bool isDark) {
    // 화면 크기에 따라 그리드 컬럼 수 조정
    final crossAxisCount = screenWidth < 400 ? 1 : 2;
    final childAspectRatio = screenWidth < 400 ? 3.0 : 1.2;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: screenWidth * 0.03,
        mainAxisSpacing: screenHeight * 0.015,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final earned = achievement['earned'] as bool;

        return Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
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
          child: crossAxisCount == 1
              ? _buildAchievementRowLayout(achievement, earned, screenWidth, isDark)
              : _buildAchievementColumnLayout(achievement, earned, screenWidth, isDark),
        );
      },
    );
  }

  Widget _buildAchievementRowLayout(Map achievement, bool earned, double screenWidth, bool isDark) {
    return Row(
      children: [
        Text(
          achievement['icon'] as String,
          style: TextStyle(
            fontSize: screenWidth * 0.08,
            color: earned ? null : Colors.grey,
          ),
        ),
        SizedBox(width: screenWidth * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                achievement['title'] as String,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: earned
                      ? (isDark ? LifewispColors.darkMainText : LifewispColors.mainText)
                      : Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                achievement['date'] as String,
                style: TextStyle(
                  fontSize: screenWidth * 0.032,
                  color: earned
                      ? (isDark ? LifewispColors.darkSubText : LifewispColors.subText)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementColumnLayout(Map achievement, bool earned, double screenWidth, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          achievement['icon'] as String,
          style: TextStyle(
            fontSize: screenWidth * 0.08,
            color: earned ? null : Colors.grey,
          ),
        ),
        SizedBox(height: 8),
        Text(
          achievement['title'] as String,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w600,
            color: earned
                ? (isDark ? LifewispColors.darkMainText : LifewispColors.mainText)
                : Colors.grey,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Text(
          achievement['date'] as String,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: earned
                ? (isDark ? LifewispColors.darkSubText : LifewispColors.subText)
                : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPersonalizedRecommendations(List<Map<String, dynamic>> recommendations, double screenWidth, double screenHeight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.06),
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
              Text('💡', style: TextStyle(fontSize: screenWidth * 0.06)),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  'AI 맞춤 추천',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.025),
          ...recommendations.map((rec) => Container(
            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
            padding: EdgeInsets.all(screenWidth * 0.04),
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
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  constraints: BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                    maxWidth: 56,
                    maxHeight: 56,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [LifewispColors.accent, LifewispColors.accentDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      rec['icon'] as String,
                      style: TextStyle(fontSize: screenWidth * 0.06),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
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
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w600,
                                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenHeight * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(rec['difficulty'] as String).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              rec['difficulty'] as String,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                                color: _getDifficultyColor(rec['difficulty'] as String),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        rec['description'] as String,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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

  // 기존 헬퍼 메서드들
  Map<String, dynamic> _analyzeRecentCounseling(List<EmotionRecord> records) {
    final recentRecords = records.take(7).toList();
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

    for (int i = 0; i < 30; i++) {
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
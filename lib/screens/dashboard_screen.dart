// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/user_provider.dart';
import '../utils/emotion_utils.dart';
import '../widgets/rabbit_emoticon.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/premium_gate.dart';
import 'diary_list_screen.dart';
import '../utils/theme.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = context.watch<EmotionProvider>().records.reversed.toList();
    final subscription = context.watch<SubscriptionProvider>();
    final userProvider = context.watch<UserProvider>();
    final recent = records.isNotEmpty ? records.first : null;
    final emotion = recent?.emotion ?? '😊';
    final emoji = emotionEmojiString[emotion] ?? '😊';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CommonAppBar(
        title: '대시보드',
        showBackButton: false,
        automaticallyImplyLeading: false,
        actions: [
          _buildSubscriptionBadge(context, subscription, isDark),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 인사말 + 구독 상태 표시
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? LifewispColors.darkCardBg.withOpacity(0.8)
                            : LifewispColors.cardBg.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? LifewispColors.darkCardShadow
                                : LifewispColors.cardShadow,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Text('👋', style: TextStyle(fontSize: 32)),
                                  );
                                },
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '안녕하세요!',
                                          style: TextStyle(
                                            fontSize: userProvider.fontSize + 4,
                                            fontFamily: userProvider.selectedFont,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? LifewispColors.darkMainText
                                                : LifewispColors.mainText,
                                          ),
                                        ),
                                        if (subscription.isPremium) ...[
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [LifewispColors.accent, LifewispColors.accentDark],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '✨ 프리미엄',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      subscription.isPremium
                                          ? 'AI와 함께 더 깊이 있는 감정 분석을 시작해보세요!'
                                          : '오늘은 어떤 하루를 보내셨나요?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? LifewispColors.darkSubText
                                            : LifewispColors.subText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // 무료 사용자에게 AI 채팅 혜택 홍보
                          if (subscription.isFree) ...[
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _showPremiumDialog(context, 'ai_chat'),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      LifewispColors.accent.withOpacity(0.1),
                                      LifewispColors.accentDark.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: LifewispColors.accent.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text('🤖', style: TextStyle(fontSize: 24)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'AI 채팅으로 더 깊은 감정 분석을!',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: LifewispColors.accent,
                                            ),
                                          ),
                                          Text(
                                            '월 5회 무료 체험 • 프리미엄으로 무제한 이용',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: LifewispColors.subText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: LifewispColors.accent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // 오늘의 감정 섹션
                  _buildSectionTitle(context, '오늘의 감정', '✨'),
                  SizedBox(height: 12),
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            isDark
                                ? LifewispColors.darkPrimary.withOpacity(0.3)
                                : LifewispColors.accent.withOpacity(0.3),
                            isDark
                                ? LifewispColors.darkPrimary.withOpacity(0.1)
                                : LifewispColors.accent.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? LifewispColors.darkPrimary.withOpacity(0.2)
                                : LifewispColors.accent.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? LifewispColors.darkCardBg.withOpacity(0.9)
                              : LifewispColors.cardBg.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          isDark
                                              ? LifewispColors.darkPrimary
                                              : LifewispColors.accent,
                                          isDark
                                              ? LifewispColors.darkPrimary.withOpacity(0.7)
                                              : LifewispColors.accent.withOpacity(0.7),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? LifewispColors.darkPrimary.withOpacity(0.3)
                                              : LifewispColors.accent.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      child: RabbitEmoticon(
                                        emotion: _mapStringToRabbitEmotion(emoji),
                                        size: 68,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recent?.diary ?? '아직 감정 기록이 없어요',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? LifewispColors.darkMainText
                                          : LifewispColors.mainText,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  if (recent != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? LifewispColors.darkPrimary.withOpacity(0.2)
                                            : LifewispColors.accent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        '${recent.date.year}-${recent.date.month.toString().padLeft(2, '0')}-${recent.date.day.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? LifewispColors.darkSubText
                                              : LifewispColors.subText,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 12),
                                  // 오늘의 한마디 (프리미엄 사용자만)
                                  if (subscription.isPremium)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? LifewispColors.darkPurple.withOpacity(0.08)
                                            : LifewispColors.purple.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                              Icons.lightbulb_outline_rounded,
                                              color: isDark
                                                  ? LifewispColors.darkPrimary
                                                  : Color(0xFF6B73FF),
                                              size: 20
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'AI 추천: 긍정적인 마음으로 하루를 시작해보세요!',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark
                                                    ? LifewispColors.darkPrimary
                                                    : Color(0xFF6B73FF),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // 빠른 액션 카드 (AI 채팅 제거, 고급 분석 추가)
                  _buildSectionTitle(context, '빠른 액션', '⚡️'),
                  SizedBox(height: 12),

                  // 내 감정 일기와 고급 분석을 나란히 배치
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          emoji: '📖',
                          title: '내 감정 일기',
                          subtitle: '기록한 감정 보기',
                          colors: isDark
                              ? [LifewispColors.darkPurple.withOpacity(0.3), LifewispColors.darkPurple]
                              : [Color(0xFFEDE9FE), Color(0xFFD8B4FE)],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DiaryListScreen()),
                          ),
                          isPremiumFeature: false,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionCard(
                          emoji: subscription.isPremium ? '📊' : '🔒',
                          title: 'AI 고급 분석',
                          subtitle: subscription.isPremium ? '감정 패턴 분석' : '프리미엄 전용',
                          colors: subscription.isPremium
                              ? (isDark
                              ? [LifewispColors.darkSecondary.withOpacity(0.3), LifewispColors.darkSecondary]
                              : [Color(0xFFFDE68A), Color(0xFFF59E0B)])
                              : [Colors.grey.withOpacity(0.3), Colors.grey],
                          onTap: subscription.isPremium
                              ? () => Navigator.pushNamed(context, '/advanced_analysis')
                              : () => _showPremiumDialog(context, 'advanced_analysis'),
                          isPremiumFeature: true,
                        ),
                      ),
                    ],
                  ),

                  // 무료 사용자 사용량 표시
                  if (subscription.isFree) ...[
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? LifewispColors.darkCardBg.withOpacity(0.8)
                            : LifewispColors.cardBg.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '무료 플랜 이용 중',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                                Text(
                                  '월 ${subscription.maxRecordsPerMonth}회 기록 • AI 삼담 월 5회 • 현재 ${records.length}회 사용',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? LifewispColors.darkSubText
                                        : LifewispColors.subText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/subscription'),
                            child: Text(
                              '업그레이드',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Bottom navigation bar를 위한 추가 공간
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionBadge(BuildContext context, SubscriptionProvider subscription, bool isDark) {
    if (subscription.isFree) {
      return Container(
        margin: EdgeInsets.only(right: 16),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Text(
          'FREE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
        ),
      );
    } else {
      return Container(
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
      );
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title, String emoji) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark
                ? LifewispColors.darkMainText
                : LifewispColors.mainText,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
    required bool isPremiumFeature,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscription = context.watch<SubscriptionProvider>();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? LifewispColors.darkCardBg.withOpacity(0.8)
                          : LifewispColors.cardBg.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? LifewispColors.darkCardShadow
                              : LifewispColors.cardShadow,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? LifewispColors.darkMainText
                          : LifewispColors.mainText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? LifewispColors.darkSubText
                          : LifewispColors.subText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPremiumDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: PremiumGate(
          child: Container(), // 사용되지 않음
          featureName: featureName,
        ),
      ),
    );
  }

  RabbitEmotion _mapStringToRabbitEmotion(String emoji) {
    switch (emoji) {
      case '😊':
        return RabbitEmotion.happy;
      case '😢':
        return RabbitEmotion.sad;
      case '😤':
        return RabbitEmotion.angry;
      case '🤩':
        return RabbitEmotion.excited;
      case '😌':
        return RabbitEmotion.calm;
      case '😰':
        return RabbitEmotion.anxious;
      case '🥰':
        return RabbitEmotion.love;
      case '😴':
        return RabbitEmotion.tired;
      case '😭':
        return RabbitEmotion.despair;
      default:
        return RabbitEmotion.happy;
    }
  }
}

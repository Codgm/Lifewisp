// screens/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/common_app_bar.dart';
import '../utils/theme.dart';
import '../widgets/rabbit_emoticon.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int selectedPlanIndex = 1; // 0: 월간, 1: 연간 (기본값)

  final plans = [
    {
      'title': '월간 프리미엄',
      'price': '₩4,900',
      'period': '/월',
      'description': '한 달 단위로 자유롭게',
      'badge': '',
      'savings': '',
    },
    {
      'title': '연간 프리미엄',
      'price': '₩39,900',
      'period': '/년',
      'description': '2개월 무료 혜택',
      'badge': '🔥 인기',
      'savings': '33% 절약',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscription = context.watch<SubscriptionProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CommonAppBar(
        title: '프리미엄 업그레이드',
        emoji: '✨',
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark
                  ? LifewispColors.darkPrimary.withOpacity(0.1)
                  : LifewispColors.accent.withOpacity(0.1),
              isDark
                  ? LifewispColors.darkCardBg
                  : Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 헤더 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [LifewispColors.accent, LifewispColors.accentDark],
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: LifewispColors.accent.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🚀', style: TextStyle(fontSize: 48)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'AI와 함께하는\n감정 분석의 새로운 차원',
                          style: GoogleFonts.notoSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? LifewispColors.darkMainText
                                : LifewispColors.mainText,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '프리미엄으로 업그레이드하고\n더 깊이 있는 감정 분석을 경험해보세요',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: isDark
                                ? LifewispColors.darkSubText
                                : LifewispColors.subText,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 기능 비교 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? LifewispColors.darkCardBg.withOpacity(0.8)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: LifewispColors.accent.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '프리미엄 혜택',
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: LifewispColors.accent,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFeatureItem(
                            '🤖',
                            'AI 감정 분석 채팅',
                            'AI와 실시간으로 대화하며 감정 상태를 깊이 분석',
                            isDark,
                          ),
                          _buildFeatureItem(
                            '📝',
                            'AI 일기 자동 생성',
                            '대화 내용을 바탕으로 개인화된 감정 일기 자동 작성',
                            isDark,
                          ),
                          _buildFeatureItem(
                            '📊',
                            '고급 감정 분석',
                            '월별 리포트, 감정 패턴 분석, 개선 방안 제시',
                            isDark,
                          ),
                          _buildFeatureItem(
                            '🎯',
                            '개인 맞춤 조언',
                            '당신만을 위한 감정 관리 및 심리 건강 팁 제공',
                            isDark,
                          ),
                          _buildFeatureItem(
                            '🚫',
                            '광고 없는 경험',
                            '방해받지 않는 온전한 감정 기록 환경',
                            isDark,
                          ),
                          _buildFeatureItem(
                            '⭐',
                            '우선 고객지원',
                            '빠른 응답과 개인화된 고객 서비스',
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 요금제 선택 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '요금제 선택',
                          style: GoogleFonts.notoSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? LifewispColors.darkMainText
                                : LifewispColors.mainText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...plans.asMap().entries.map((entry) {
                          final index = entry.key;
                          final plan = entry.value;
                          final isSelected = selectedPlanIndex == index;
                          final isPopular = (plan['badge'] as String?)?.isNotEmpty == true;

                          return GestureDetector(
                            onTap: () => setState(() => selectedPlanIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                  colors: [
                                    LifewispColors.accent.withOpacity(0.1),
                                    LifewispColors.accentDark.withOpacity(0.1),
                                  ],
                                )
                                    : null,
                                color: isSelected
                                    ? null
                                    : (isDark
                                    ? LifewispColors.darkCardBg.withOpacity(0.6)
                                    : Colors.white.withOpacity(0.8)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? LifewispColors.accent
                                      : (isDark
                                      ? Colors.grey.withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.2)),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: LifewispColors.accent.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? LifewispColors.accent
                                                : Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Center(
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: LifewispColors.accent,
                                            ),
                                          ),
                                        )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  plan['title']!,
                                                  style: GoogleFonts.notoSans(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? LifewispColors.darkMainText
                                                        : LifewispColors.mainText,
                                                  ),
                                                ),
                                                if ((plan['savings'] as String?)?.isNotEmpty == true) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      plan['savings']!,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              plan['description']!,
                                              style: GoogleFonts.notoSans(
                                                fontSize: 14,
                                                color: isDark
                                                    ? LifewispColors.darkSubText
                                                    : LifewispColors.subText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                plan['price']!,
                                                style: GoogleFonts.notoSans(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w700,
                                                  color: LifewispColors.accent,
                                                ),
                                              ),
                                              Text(
                                                plan['period']!,
                                                style: GoogleFonts.notoSans(
                                                  fontSize: 16,
                                                  color: isDark
                                                      ? LifewispColors.darkSubText
                                                      : LifewispColors.subText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (index == 1) // 연간 플랜
                                            Text(
                                              '월 ₩3,325',
                                              style: GoogleFonts.notoSans(
                                                fontSize: 12,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (isPopular)
                                    Positioned(
                                      top: -8,
                                      right: 20,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.orange, Colors.deepOrange],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.orange.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          plan['badge']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 결제 버튼
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: subscription.isLoading
                                ? null
                                : () => _processPurchase(context, subscription),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LifewispColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: LifewispColors.accent.withOpacity(0.3),
                            ),
                            child: subscription.isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              '프리미엄 시작하기 🚀',
                              style: GoogleFonts.notoSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '• 언제든지 취소 가능\n• 첫 7일 무료 체험\n• 안전한 결제 시스템',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: isDark
                                ? LifewispColors.darkSubText
                                : LifewispColors.subText,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 무료 기능 안내
                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? LifewispColors.darkCardBg.withOpacity(0.6)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '무료 버전으로 계속하기',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? LifewispColors.darkMainText
                                  : LifewispColors.mainText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '기본적인 감정 기록과 간단한 통계는\n무료로 계속 이용하실 수 있어요',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: isDark
                                  ? LifewispColors.darkSubText
                                  : LifewispColors.subText,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              '무료로 계속하기',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String description, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  LifewispColors.accent.withOpacity(0.1),
                  LifewispColors.accentDark.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: LifewispColors.accent.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: RabbitEmoticon(
                emotion: _convertEmojiToRabbitEmotion(emoji),
                size: 24,
                backgroundColor: Colors.transparent,
                borderColor: Colors.transparent,
                borderWidth: 0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? LifewispColors.darkMainText
                        : LifewispColors.mainText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: isDark
                        ? LifewispColors.darkSubText
                        : LifewispColors.subText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPurchase(BuildContext context, SubscriptionProvider subscription) async {
    try {
      // 실제로는 여기서 인앱결제 처리
      final success = await subscription.upgradeToPremium();

      if (success && mounted) {
        // 성공 다이얼로그
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _buildSuccessDialog(context),
        );
      } else if (mounted) {
        // 실패 스낵바
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 처리 중 오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('네트워크 오류가 발생했습니다. 연결을 확인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSuccessDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(32),
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
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text('🎉', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '프리미엄 업그레이드 완료!',
            style: GoogleFonts.notoSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '이제 AI와 함께하는 모든 기능을\n자유롭게 이용하실 수 있어요! ✨',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 구독 화면 닫기
                // 필요하다면 대시보드로 이동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LifewispColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'AI 기능 시작하기 🚀',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  RabbitEmotion _convertEmojiToRabbitEmotion(String emoji) {
    switch (emoji) {
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
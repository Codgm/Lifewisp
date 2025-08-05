// widgets/premium_gate.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../utils/theme.dart';
import '../screens/subscription_screen.dart';

class PremiumGate extends StatelessWidget {
  final Widget child;
  final String featureName;
  final String? customTitle;
  final String? customDescription;
  final bool showUpgradeButton;
  final String? title;
  final String? description;
  final List<String>? features;

  const PremiumGate({
    Key? key,
    required this.child,
    required this.featureName,
    this.customTitle,
    this.customDescription,
    this.showUpgradeButton = true,
    this.title,
    this.description,
    this.features,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, _) {
        // 프리미엄 사용자는 바로 기능 제공
        if (subscription.canUseFeature(featureName)) {
          return child;
        }

        // 무료 사용자에게는 업그레이드 유도 화면
        return _buildUpgradePrompt(context, subscription);
      },
    );
  }

  Widget _buildUpgradePrompt(BuildContext context, SubscriptionProvider subscription) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark
                ? LifewispColors.darkCardBg.withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            isDark
                ? LifewispColors.darkCardBg.withOpacity(0.7)
                : Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? LifewispColors.darkPrimary.withOpacity(0.3)
              : LifewispColors.accent.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 프리미엄 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  isDark ? LifewispColors.darkSecondary : LifewispColors.accentDark,
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                      .withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text('✨', style: TextStyle(fontSize: 36)),
            ),
          ),

          SizedBox(height: 24),

          // 제목
          Text(
            customTitle ?? _getDefaultTitle(featureName),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12),

          // 설명
          Text(
            customDescription ?? _getDefaultDescription(featureName),
            style: TextStyle(
              fontSize: 16,
              color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 32),

          // 프리미엄 혜택 리스트
          _buildBenefitsList(context, isDark),

          SizedBox(height: 32),

          if (showUpgradeButton) ...[
            // 업그레이드 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: subscription.isLoading ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionScreen(),
                    ),
                  );
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
                child: subscription.isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  '프리미엄 업그레이드 🚀',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12),

            // 나중에 하기 버튼
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
        ],
      ),
    );
  }

  Widget _buildBenefitsList(BuildContext context, bool isDark) {
    final benefits = _getBenefits(featureName);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? LifewispColors.darkPrimary.withOpacity(0.1)
            : LifewispColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? LifewispColors.darkPrimary.withOpacity(0.2)
              : LifewispColors.accent.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '프리미엄으로 누리는 혜택',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
          ),
          SizedBox(height: 16),
          ...benefits.map((benefit) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✓',
                  style: TextStyle(
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
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

  String _getDefaultTitle(String featureName) {
    switch (featureName) {
      case 'ai_chat':
        return 'AI 감정 분석 채팅';
      case 'ai_generation':
        return 'AI 일기 자동 생성';
      case 'advanced_analysis':
        return '고급 감정 분석';
      default:
        return '프리미엄 기능';
    }
  }

  String _getDefaultDescription(String featureName) {
    switch (featureName) {
      case 'ai_chat':
        return 'AI와 대화하며 감정을 깊이 분석하고\n맞춤형 조언을 받아보세요';
      case 'ai_generation':
        return 'AI가 당신의 감정을 바탕으로\n완성도 높은 일기를 자동 생성해드려요';
      case 'advanced_analysis':
        return '감정 패턴 분석, 월별 리포트 등\n고급 인사이트를 제공받으세요';
      default:
        return '더 많은 기능을 이용하려면\n프리미엄으로 업그레이드하세요';
    }
  }

  List<String> _getBenefits(String featureName) {
    switch (featureName) {
      case 'ai_chat':
        return [
          'AI와 실시간 감정 상담',
          '개인별 맞춤 조언 제공',
          '무제한 대화 가능',
          '감정 패턴 학습 및 피드백',
        ];
      case 'ai_generation':
        return [
          'AI 자동 일기 생성',
          '감정 기반 글쓰기 도움',
          '다양한 스타일 선택 가능',
          '개인화된 내용 제안',
        ];
      case 'advanced_analysis':
        return [
          '월별 감정 리포트',
          '감정 패턴 분석',
          '스트레스 지수 추적',
          '개선 방안 제시',
        ];
      default:
        return [
          '모든 프리미엄 기능 이용',
          '광고 없는 경험',
          '우선 고객지원',
          '정기 업데이트 혜택',
        ];
    }
  }
}
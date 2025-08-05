import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../providers/subscription_provider.dart';
import '../screens/emotion_record_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddPressed;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final iconSize = isSmallScreen ? 18.0 : 22.0;
    final fontSize = isSmallScreen ? 9.0 : 11.0;
    final fabSize = isSmallScreen ? 48.0 : 56.0;

    // 테마 모드 감지
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navLabels = ['Home', 'Calendar', 'Analysis', 'Profile'];
    final navIcons = [
      Icons.home_rounded,
      Icons.calendar_today_rounded,
      Icons.insights_rounded,
      Icons.person_rounded,
    ];
    final navOutlineIcons = [
      Icons.home_outlined,
      Icons.calendar_today_outlined,
      Icons.insights_outlined,
      Icons.person_outline_rounded,
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 메인 하단바 - 테마 대응
        Container(
          height: 68,
          decoration: BoxDecoration(
            color: isDark ? LifewispColors.darkCardBg : Colors.white,
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.black).withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 15,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildNavItem(
                      context,
                      icon: navOutlineIcons[0],
                      selectedIcon: navIcons[0],
                      index: 0,
                      label: navLabels[0],
                      iconSize: iconSize,
                      fontSize: fontSize,
                      isDark: isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      icon: navOutlineIcons[1],
                      selectedIcon: navIcons[1],
                      index: 1,
                      label: navLabels[1],
                      iconSize: iconSize,
                      fontSize: fontSize,
                      isDark: isDark,
                    ),
                  ),
                  // 중앙 빈 공간 (플로팅 버튼을 위한)
                  SizedBox(width: fabSize + 16),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      icon: navOutlineIcons[2],
                      selectedIcon: navIcons[2],
                      index: 2,
                      label: navLabels[2],
                      iconSize: iconSize,
                      fontSize: fontSize,
                      isDark: isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      icon: navOutlineIcons[3],
                      selectedIcon: navIcons[3],
                      index: 3,
                      label: navLabels[3],
                      iconSize: iconSize,
                      fontSize: fontSize,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 중앙 스마트 플로팅 버튼 - 구독 상태에 따라 다른 기능
        Positioned(
          top: -fabSize / 2.5,
          left: (screenWidth - fabSize) / 2,
          child: _buildSmartFAB(context, fabSize, iconSize, isDark),
        ),
      ],
    );
  }

  Widget _buildSmartFAB(BuildContext context, double fabSize, double iconSize, bool isDark) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        return GestureDetector(
          onTap: () => _showSmartFABOptions(context, subscription),
          onLongPress: () => _quickEmotionRecord(context), // 길게 누르면 바로 감정 기록
          child: Transform.rotate(
            angle: 0.785398, // 45도 회전 (라디안)
            child: Container(
              width: fabSize,
              height: fabSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [LifewispColors.darkPrimary, LifewispColors.darkSecondary]
                      : [LifewispColors.accent, LifewispColors.accentDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                        .withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -0.785398, // 아이콘은 반대로 회전해서 수평 유지
                    child: Icon(
                      subscription.isPremium
                          ? Icons.auto_awesome // 프리미엄: 마법 아이콘
                          : Icons.add_comment_rounded, // 무료: 기본 추가 아이콘
                      size: iconSize + 8,
                      color: Colors.white,
                    ),
                  ),
                  // 프리미엄 사용자에게 작은 스파크 효과
                  if (subscription.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSmartFABOptions(BuildContext context, SubscriptionProvider subscription) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? LifewispColors.darkCardBg
              : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 핸들바
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),

                // 제목
                Row(
                  children: [
                    Text(
                      subscription.isPremium ? '✨' : '📝',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(width: 12),
                    Text(
                      subscription.isPremium ? 'AI 기능 바로가기' : '감정 기록하기',
                      style: Theme.of(context).brightness == Brightness.dark
                          ? LifewispTextStyles.darkTitle
                          : LifewispTextStyles.title,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // 옵션들
                if (subscription.isPremium) ...[
                  _buildFABOption(
                    context,
                    icon: Icons.edit_note_rounded,
                    title: '감정 기록하기',
                    subtitle: '오늘의 감정을 기록해보세요',
                    color: LifewispColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      _quickEmotionRecord(context);
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFABOption(
                    context,
                    icon: Icons.psychology_rounded,
                    title: 'AI 상담',
                    subtitle: 'AI와 감정에 대해 상담해보세요',
                    color: LifewispColors.accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/ai_chat');
                    },
                  ),
                ] else ...[
                  _buildFABOption(
                    context,
                    icon: Icons.edit_note_rounded,
                    title: '감정 기록하기',
                    subtitle: '오늘의 감정을 기록해보세요',
                    color: LifewispColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      _quickEmotionRecord(context);
                    },
                  ),
                  SizedBox(height: 12),
                  _buildFABOption(
                    context,
                    icon: Icons.star_outline,
                    title: '프리미엄으로 업그레이드',
                    subtitle: 'AI 기능을 모두 사용해보세요',
                    color: LifewispColors.warning,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/subscription');
                    },
                  ),
                ],

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFABOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isDark ? LifewispTextStyles.darkSubtitle : LifewispTextStyles.subtitle)
                        .copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: (isDark ? LifewispTextStyles.darkCaption : LifewispTextStyles.caption)
                        .copyWith(
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  void _quickEmotionRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmotionRecordScreen(),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required IconData selectedIcon,
        required int index,
        required String label,
        required double iconSize,
        required double fontSize,
        required bool isDark,
      }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 컨테이너
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: isDark
                      ? [LifewispColors.darkPrimary, LifewispColors.darkSecondary]
                      : lifewispGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isSelected ? null : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                size: iconSize,
                color: isSelected
                    ? Colors.white
                    : (isDark ? LifewispColors.darkSubText : Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 4),
            // 라벨
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (isDark ? LifewispColors.darkPrimary : lifewispPrimary)
                    : (isDark ? LifewispColors.darkSubText : Colors.grey[500]),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
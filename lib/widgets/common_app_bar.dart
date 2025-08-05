import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? emoji;
  final String? date;
  final VoidCallback? onBack;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showDate;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading; // 추가된 속성
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    super.key,
    required this.title,
    this.emoji,
    this.date,
    this.onBack,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.showBackButton = true,
    this.onBackPressed,
    this.showDate = false,
    this.backgroundColor,
    this.actions,
    this.automaticallyImplyLeading = true, // 기본값 true
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark
          ? LifewispColors.darkCardBg.withOpacity(0.95)
          : Colors.white.withOpacity(0.95),
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      automaticallyImplyLeading: automaticallyImplyLeading && showBackButton, // 수정된 부분
      leadingWidth: showBackButton ? 56 : 0,
      leading: showBackButton ? _buildBackButton(context, isDark) : null,
      title: _buildTitleSection(context, isDark),
      centerTitle: true,
      actions: actions,
      bottom: bottom ?? (showDate && date != null ? PreferredSize(
        preferredSize: const Size.fromHeight(28),
        child: _buildDateSection(context, isDark),
      ) : null),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              HapticFeedback.lightImpact();
              (onBack ?? onBackPressed ?? () => Navigator.pop(context))();
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: isDark
                  ? LifewispColors.darkMainText
                  : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (emoji != null) ...[
          Text(
            emoji!,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: isDark
                ? LifewispColors.darkMainText
                : const Color(0xFF1A1A1A),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context, bool isDark) {
    return Container(
      height: 28,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? LifewispColors.darkPrimary.withOpacity(0.1)
              : const Color(0xFF6B73FF).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📅', style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
            Text(
              date!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? LifewispColors.darkPrimary
                    : const Color(0xFF6B73FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
        kToolbarHeight + (showDate && date != null ? 28 : 0)
    );
  }
}

// 사용 편의를 위한 확장 클래스들
class HomeAppBar extends CommonAppBar {
  const HomeAppBar({
    Key? key,
    List<Widget>? actions,
  }) : super(
    key: key,
    title: 'Lifewisp',
    emoji: '✨',
    showBackButton: false,
    automaticallyImplyLeading: false, // 추가
    actions: actions,
  );
}

class BackAppBar extends CommonAppBar {
  const BackAppBar({
    Key? key,
    required String title,
    String? emoji,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) : super(
    key: key,
    title: title,
    emoji: emoji,
    showBackButton: true,
    onBackPressed: onBackPressed,
    actions: actions,
  );
}

class ProfileAppBar extends CommonAppBar {
  const ProfileAppBar({
    Key? key,
    List<Widget>? actions,
  }) : super(
    key: key,
    title: '프로필',
    emoji: '👤',
    showBackButton: false,
    automaticallyImplyLeading: false, // 추가
    actions: actions,
  );
}
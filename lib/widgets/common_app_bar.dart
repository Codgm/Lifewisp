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
  final bool automaticallyImplyLeading;
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
    this.automaticallyImplyLeading = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 화면 크기에 따른 반응형 값들 계산
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600;

    // 반응형 크기 설정
    final backButtonSize = _getResponsiveSize(
      small: 32.0,
      medium: 36.0,
      large: 40.0,
      screenWidth: screenWidth,
    );

    final titleFontSize = _getResponsiveSize(
      small: 15.0,
      medium: 17.0,
      large: 19.0,
      screenWidth: screenWidth,
    );

    final emojiFontSize = _getResponsiveSize(
      small: 14.0,
      medium: 16.0,
      large: 18.0,
      screenWidth: screenWidth,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: backgroundColor ??
              (isDark
                  ? LifewispColors.darkCardBg.withOpacity(0.95)
                  : Colors.white.withOpacity(0.95)),
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
          automaticallyImplyLeading: automaticallyImplyLeading && showBackButton,
          leadingWidth: showBackButton ? _getLeadingWidth(screenWidth) : 0,
          leading: showBackButton ? _buildBackButton(context, isDark, backButtonSize) : null,
          title: _buildTitleSection(context, isDark, titleFontSize, emojiFontSize, constraints.maxWidth),
          centerTitle: centerTitle,
          actions: _buildResponsiveActions(context, isDark, screenWidth),
          bottom: bottom ?? (showDate && date != null ? PreferredSize(
            preferredSize: Size.fromHeight(_getDateSectionHeight(screenWidth)),
            child: _buildDateSection(context, isDark, screenWidth),
          ) : null),
          toolbarHeight: _getToolbarHeight(screenWidth),
        );
      },
    );
  }

  // 반응형 크기 계산 함수
  double _getResponsiveSize({
    required double small,
    required double medium,
    required double large,
    required double screenWidth,
  }) {
    if (screenWidth < 360) return small;
    if (screenWidth < 600) return medium;
    return large;
  }

  // 반응형 leading width 계산
  double _getLeadingWidth(double screenWidth) {
    return _getResponsiveSize(
      small: 48.0,
      medium: 56.0,
      large: 64.0,
      screenWidth: screenWidth,
    );
  }

  // 반응형 toolbar height 계산
  double _getToolbarHeight(double screenWidth) {
    return _getResponsiveSize(
      small: 48.0,
      medium: 56.0,
      large: 60.0,
      screenWidth: screenWidth,
    );
  }

  // 반응형 date section height 계산
  double _getDateSectionHeight(double screenWidth) {
    return _getResponsiveSize(
      small: 24.0,
      medium: 28.0,
      large: 32.0,
      screenWidth: screenWidth,
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark, double size) {
    final iconSize = size * 0.4; // 버튼 크기에 비례한 아이콘 크기

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(size / 2),
            onTap: () {
              HapticFeedback.lightImpact();
              (onBack ?? onBackPressed ?? () => Navigator.pop(context))();
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: iconSize,
              color: isDark
                  ? LifewispColors.darkMainText
                  : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, bool isDark, double titleFontSize, double emojiFontSize, double availableWidth) {
    // 타이틀이 사용할 수 있는 최대 너비 계산
    double maxTitleWidth = availableWidth;

    // leading과 actions 공간을 제외한 너비 계산
    if (showBackButton) {
      maxTitleWidth -= _getLeadingWidth(MediaQuery.of(context).size.width);
    }
    if (actions != null && actions!.isNotEmpty) {
      maxTitleWidth -= (actions!.length * 48.0) + 16.0; // 액션 버튼들과 여백
    }

    // 여백을 고려한 실제 사용 가능 너비
    maxTitleWidth = maxTitleWidth * 0.8; // 80%만 사용하여 여유 공간 확보

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxTitleWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(
              emoji!,
              style: TextStyle(fontSize: emojiFontSize),
            ),
            SizedBox(width: _getResponsiveSize(
              small: 4.0,
              medium: 6.0,
              large: 8.0,
              screenWidth: MediaQuery.of(context).size.width,
            )),
          ],
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? LifewispColors.darkMainText
                    : const Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget>? _buildResponsiveActions(BuildContext context, bool isDark, double screenWidth) {
    if (actions == null || actions!.isEmpty) return null;

    final isSmallScreen = screenWidth < 360;

    // 작은 화면에서는 액션 수를 제한
    if (isSmallScreen && actions!.length > 2) {
      return [
        ...actions!.take(1), // 첫 번째 액션만 표시
        PopupMenuButton<int>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: isDark ? LifewispColors.darkMainText : const Color(0xFF1A1A1A),
            size: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            for (int i = 1; i < actions!.length; i++)
              PopupMenuItem<int>(
                value: i,
                child: Text('액션 ${i + 1}'), // 실제로는 적절한 텍스트로 교체 필요
              ),
          ],
          onSelected: (index) {
            // 실제로는 각 액션의 onPressed 콜백 실행
          },
        ),
        SizedBox(width: _getResponsiveSize(
          small: 8.0,
          medium: 12.0,
          large: 16.0,
          screenWidth: screenWidth,
        )),
      ];
    }

    // 일반적인 경우 모든 액션 표시
    return [
      ...actions!,
      SizedBox(width: _getResponsiveSize(
        small: 8.0,
        medium: 12.0,
        large: 16.0,
        screenWidth: screenWidth,
      )),
    ];
  }

  Widget _buildDateSection(BuildContext context, bool isDark, double screenWidth) {
    final dateHeight = _getDateSectionHeight(screenWidth);
    final dateFontSize = _getResponsiveSize(
      small: 10.0,
      medium: 11.0,
      large: 12.0,
      screenWidth: screenWidth,
    );
    final emojiSize = _getResponsiveSize(
      small: 8.0,
      medium: 10.0,
      large: 12.0,
      screenWidth: screenWidth,
    );

    return Container(
      height: dateHeight,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveSize(
          small: 12.0,
          medium: 16.0,
          large: 20.0,
          screenWidth: screenWidth,
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _getResponsiveSize(
            small: 6.0,
            medium: 8.0,
            large: 10.0,
            screenWidth: screenWidth,
          ),
          vertical: _getResponsiveSize(
            small: 2.0,
            medium: 4.0,
            large: 6.0,
            screenWidth: screenWidth,
          ),
        ),
        decoration: BoxDecoration(
          color: isDark
              ? LifewispColors.darkPrimary.withOpacity(0.1)
              : const Color(0xFF6B73FF).withOpacity(0.08),
          borderRadius: BorderRadius.circular(_getResponsiveSize(
            small: 8.0,
            medium: 12.0,
            large: 14.0,
            screenWidth: screenWidth,
          )),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📅', style: TextStyle(fontSize: emojiSize)),
            SizedBox(width: _getResponsiveSize(
              small: 2.0,
              medium: 4.0,
              large: 6.0,
              screenWidth: screenWidth,
            )),
            Flexible(
              child: Text(
                date!,
                style: TextStyle(
                  fontSize: dateFontSize,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? LifewispColors.darkPrimary
                      : const Color(0xFF6B73FF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    final screenWidth = WidgetsBinding.instance.window.physicalSize.width /
        WidgetsBinding.instance.window.devicePixelRatio;
    final toolbarHeight = _getToolbarHeight(screenWidth);
    final dateHeight = showDate && date != null ? _getDateSectionHeight(screenWidth) : 0;

    return Size.fromHeight(toolbarHeight + dateHeight);
  }
}

// 사용 편의를 위한 확장 클래스들 (반응형 개선)
class HomeAppBar extends CommonAppBar {
  const HomeAppBar({
    Key? key,
    List<Widget>? actions,
  }) : super(
    key: key,
    title: 'Lifewisp',
    emoji: '✨',
    showBackButton: false,
    automaticallyImplyLeading: false,
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
    automaticallyImplyLeading: false,
    actions: actions,
  );
}
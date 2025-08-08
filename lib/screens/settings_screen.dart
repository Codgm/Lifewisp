import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/subscription_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common_app_bar.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;



  final List<String> availableFonts = ['Jua', 'Noto Sans', 'Do Hyeon', 'Black Han Sans', 'Cute Font'];
  final List<String> weekDays = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CommonAppBar(
        title: '설정',
        showBackButton: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 프로필 헤더
                    _buildProfileHeader(userProvider, isDark),

                    const SizedBox(height: 32),

                    // 알림 설정
                    _buildNotificationSection(userProvider, isDark),

                    const SizedBox(height: 24),

                    // 앱 설정
                    _buildAppSettingsSection(userProvider, isDark),

                    const SizedBox(height: 24),

                    // 계정 설정
                    _buildAccountSection(userProvider, isDark),

                    const SizedBox(height: 24),

                    // 기타 설정
                    _buildOtherSection(isDark),

                    const SizedBox(height: 32),

                    // 로그아웃 버튼
                    _buildLogoutButton(userProvider, isDark),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProvider userProvider, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            LifewispColors.darkCardBg.withOpacity(0.9),
            LifewispColors.darkCardBg.withOpacity(0.7),
          ]
              : [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        border: isDark
            ? Border.all(color: LifewispColors.darkPrimary.withOpacity(0.3))
            : Border.all(color: LifewispColors.accent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showProfileImageDialog(context, userProvider),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDark
                      ? [LifewispColors.darkPrimary, LifewispColors.darkPrimary.withOpacity(0.7)]
                      : [LifewispColors.accent, LifewispColors.accent.withOpacity(0.7)],
                ),
              ),
              child: userProvider.profileImagePath != null && userProvider.profileImagePath!.isNotEmpty
                  ? ClipOval(
                      child: _buildProfileImage(userProvider.profileImagePath!),
                    )
                  : Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (userProvider.userNickname?.isNotEmpty == true) ? userProvider.userNickname! : '사용자',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '오늘도 감정을 기록해보세요 ✨',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showImagePickerDialog(context, userProvider),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.photo_camera,
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showProfileEditDialog(context, userProvider),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(UserProvider userProvider, bool isDark) {
    return _buildSection(
      title: '📢 알림 설정',
      children: [
        _buildSwitchTile(
          title: '감정 기록 알림',
          subtitle: '매일 기록을 잊지 않도록 알려드려요',
          value: userProvider.notificationEnabled,
          onChanged: (value) {
            userProvider.setNotificationEnabled(value);
          },
          isDark: isDark,
        ),
        if (userProvider.notificationEnabled) ...[
          _buildDivider(isDark),
          _buildTimeTile(
            title: '알림 시간',
            subtitle: '${userProvider.reminderTime.hour.toString().padLeft(2, '0')}:${userProvider.reminderTime.minute.toString().padLeft(2, '0')}',
            onTap: () => _showTimePicker(context, userProvider),
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            title: '알림 소리',
            subtitle: '알림음을 재생합니다',
            value: userProvider.soundEnabled,
            onChanged: (value) {
              userProvider.setSoundEnabled(value);
            },
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            title: '진동',
            subtitle: '알림 시 진동을 사용합니다',
            value: userProvider.vibrationEnabled,
            onChanged: (value) {
              userProvider.setVibrationEnabled(value);
            },
            isDark: isDark,
          ),
        ],
      ],
      isDark: isDark,
    );
  }

  Widget _buildAppSettingsSection(UserProvider userProvider, bool isDark) {
    return _buildSection(
      title: '🎨 앱 설정',
      children: [
        _buildTile(
          icon: Icons.palette,
          title: '테마 설정',
          subtitle: '나만의 테마를 선택해요',
          onTap: () => _showThemeDialog(context, userProvider),
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildTile(
          icon: Icons.calendar_today,
          title: '주 시작 요일',
          subtitle: weekDays[userProvider.weekStartDay],
          onTap: () => _showWeekStartDialog(context, userProvider),
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildTile(
          icon: Icons.font_download,
          title: '폰트 설정',
          subtitle: '${userProvider.selectedFont}, ${userProvider.fontSize.toInt()}px',
          onTap: () => _showFontDialog(context, userProvider),
          isDark: isDark,
        ),
      ],
      isDark: isDark,
    );
  }

  Widget _buildAccountSection(UserProvider userProvider, bool isDark) {
    return _buildSection(
      title: '👤 계정 설정',
      children: [
        _buildTile(
          icon: Icons.subscriptions,
          title: '구독 관리',
          subtitle: '프리미엄 구독을 관리해요',
          onTap: () => _showSubscriptionDialog(context, userProvider),
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildTile(
          icon: Icons.lock_reset,
          title: '비밀번호 재설정',
          subtitle: '비밀번호를 변경할 수 있어요',
          onTap: () => _showPasswordResetDialog(context),
          isDark: isDark,
        ),
      ],
      isDark: isDark,
    );
  }

  Widget _buildOtherSection(bool isDark) {
    return _buildSection(
      title: '⚙️ 기타',
      children: [
        _buildTile(
          icon: Icons.help_outline,
          title: '도움말',
          subtitle: '앱 사용법을 확인해요',
          onTap: () => _showHelpDialog(context),
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildTile(
          icon: Icons.info_outline,
          title: '앱 정보',
          subtitle: 'LifeWisp v1.0.0',
          onTap: () => _showAppInfoDialog(context),
          isDark: isDark,
        ),
        _buildDivider(isDark),
        _buildTile(
          icon: Icons.star_outline,
          title: '앱 평가하기',
          subtitle: '별점과 리뷰를 남겨주세요',
          onTap: () => _showRatingDialog(context),
          isDark: isDark,
        ),
      ],
      isDark: isDark,
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                LifewispColors.darkCardBg.withOpacity(0.9),
                LifewispColors.darkCardBg.withOpacity(0.7),
              ]
                  : [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
            border: isDark
                ? Border.all(color: LifewispColors.darkPrimary.withOpacity(0.3))
                : Border.all(color: LifewispColors.accent.withOpacity(0.15)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            activeTrackColor: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.access_time,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
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

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.grey.withOpacity(0.2),
      indent: 20,
      endIndent: 20,
    );
  }

  Widget _buildLogoutButton(UserProvider userProvider, bool isDark) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [LifewispColors.darkRed.withOpacity(0.1), LifewispColors.darkRed.withOpacity(0.05)]
              : [const Color(0xFFE53E3E).withOpacity(0.1), const Color(0xFFE53E3E).withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? LifewispColors.darkRed.withOpacity(0.3) : const Color(0xFFE53E3E).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context, userProvider),
        icon: Icon(
          Icons.logout,
          color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
        ),
        label: Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // 다이얼로그 메서드들
  void _showTimePicker(BuildContext context, UserProvider userProvider) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: userProvider.reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await userProvider.setReminderTime(picked);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '알림 시간이 ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}로 설정되었어요! ⏰',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showThemeDialog(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMode = userProvider.themeMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.palette,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(width: 12),
            Text(
              '테마 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('라이트 모드', Icons.light_mode, currentMode == ThemeMode.light, context, () {
              userProvider.setThemeMode(ThemeMode.light);
            }),
            _buildThemeOption('다크 모드', Icons.dark_mode, currentMode == ThemeMode.dark, context, () {
              userProvider.setThemeMode(ThemeMode.dark);
            }),
            _buildThemeOption('시스템 설정', Icons.settings, currentMode == ThemeMode.system, context, () {
              userProvider.setThemeMode(ThemeMode.system);
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: TextStyle(
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, IconData icon, bool isSelected, BuildContext context, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
            : (isDark ? LifewispColors.darkSubText : LifewispColors.subText),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
              : (isDark ? LifewispColors.darkMainText : LifewispColors.mainText),
        ),
      ),
      trailing: isSelected
          ? Icon(
        Icons.check,
        color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
      )
          : null,
      onTap: () {
        onTap();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$title로 변경되었어요! 🎨',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            ),
            backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.all(16),
          ),
        );
      },
    );
  }

  void _showWeekStartDialog(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(width: 12),
            Text(
              '주 시작 요일',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: weekDays.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isSelected = userProvider.weekStartDay == index;

            return ListTile(
              title: Text(
                day,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                      : (isDark ? LifewispColors.darkMainText : LifewispColors.mainText),
                ),
              ),
              trailing: isSelected
                  ? Icon(
                Icons.check,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              )
                  : null,
              onTap: () async {
                await userProvider.setWeekStartDay(index);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$day부터 시작하도록 설정되었어요! 📅',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(16),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontDialog(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String tempSelectedFont = userProvider.selectedFont;
    double tempFontSize = userProvider.fontSize;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                Icons.font_download,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
              SizedBox(width: 12),
              Text(
                '폰트 설정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 폰트 선택
                Text(
                  '폰트 종류',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: 150,
                  child: ListView.builder(
                    itemCount: availableFonts.length,
                    itemBuilder: (context, index) {
                      final font = availableFonts[index];
                      final isSelected = tempSelectedFont == font;

                      return ListTile(
                        title: Text(
                          font,
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: tempFontSize,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                                : (isDark ? LifewispColors.darkMainText : LifewispColors.mainText),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                          Icons.check,
                          color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                        )
                            : null,
                        onTap: () {
                          setDialogState(() {
                            tempSelectedFont = font;
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 24),

                // 폰트 크기
                Text(
                  '폰트 크기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                ),
                SizedBox(height: 12),

                // 미리보기
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? LifewispColors.darkPrimary.withOpacity(0.3) : LifewispColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '오늘 하루도 감정을 기록해보세요 ✨',
                    style: TextStyle(
                      fontFamily: tempSelectedFont,
                      fontSize: tempFontSize,
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // 폰트 크기 슬라이더
                Row(
                  children: [
                    Text(
                      '작게',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: tempFontSize,
                        min: 12.0,
                        max: 24.0,
                        divisions: 12,
                        activeColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                        inactiveColor: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.3),
                        onChanged: (value) {
                          setDialogState(() {
                            tempFontSize = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      '크게',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${tempFontSize.toInt()}px',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: TextStyle(
                  color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await userProvider.setFontSettings(tempSelectedFont, tempFontSize);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '폰트가 $tempSelectedFont ${tempFontSize.toInt()}px로 변경되었어요! ✨',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(16),
                  ),
                );
              },
              child: Text(
                '적용',
                style: TextStyle(
                  color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileEditDialog(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nicknameController = TextEditingController(text: userProvider.userNickname);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.person_outline,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(width: 12),
            Text(
              '프로필 수정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameController,
              style: TextStyle(
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
              decoration: InputDecoration(
                labelText: '닉네임',
                labelStyle: TextStyle(
                  color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                ),
                filled: true,
                fillColor: isDark
                    ? LifewispColors.darkPrimary.withOpacity(0.1)
                    : LifewispColors.accent.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? LifewispColors.darkPrimary.withOpacity(0.3) : LifewispColors.accent.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? LifewispColors.darkPrimary.withOpacity(0.3) : LifewispColors.accent.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
                      TextButton(
              onPressed: () async {
                await userProvider.setUserNickname(nicknameController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '프로필이 수정되었어요! ✨',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  backgroundColor: isDark ? LifewispColors.darkSuccess : const Color(0xFF38B2AC),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(16),
                ),
              );
            },
            child: Text(
              '저장',
              style: TextStyle(
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordResetDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.lock_reset,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(width: 12),
            Text(
              '비밀번호 재설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Text(
          '등록된 이메일로 비밀번호 재설정 링크를 보내드릴게요! 📧',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '이메일이 전송되었어요! 📧',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  backgroundColor: isDark ? LifewispColors.darkSuccess : const Color(0xFF38B2AC),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(16),
                ),
              );
            },
            child: Text(
              '전송',
              style: TextStyle(
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(width: 12),
            Text(
              '도움말',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📝 감정 기록하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '매일의 감정과 하루 일과를 간단히 기록할 수 있어요',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '📊 통계 보기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '감정 변화를 차트로 확인하고 패턴을 분석해보세요',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '🔔 알림 설정',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '매일 정해진 시간에 기록 알림을 받을 수 있어요',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: TextStyle(
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.favorite,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'LifeWisp',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '버전: 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '당신의 감정을 소중히 기록하고 관리하는 앱입니다. 💜',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '개발자: LifeWisp Team',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: TextStyle(
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                Icons.star_outline,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
              SizedBox(width: 12),
              Text(
                '앱 평가하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LifeWisp는 어떠셨나요?',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedRating = index + 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 16),
              if (selectedRating > 0)
                Text(
                  selectedRating >= 4
                      ? '감사합니다! 🎉'
                      : selectedRating >= 3
                      ? '더욱 발전하겠습니다! 😊'
                      : '소중한 의견 감사합니다 🙏',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: TextStyle(
                  color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: selectedRating > 0 ? () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '평가해주셔서 감사합니다! ⭐',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    backgroundColor: Colors.amber,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(16),
                  ),
                );
              } : null,
              child: Text(
                '제출',
                style: TextStyle(
                  color: selectedRating > 0
                      ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                      : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileImageDialog(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.photo_camera,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(width: 12),
            Text(
              '프로필 사진 변경',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
              title: Text(
                '갤러리에서 선택',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                // TODO: 실제 갤러리 선택 구현
                await userProvider.setProfileImage('assets/emoticons/rabbit-happy.jpg');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '프로필 사진이 변경되었어요! 📸',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(16),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
              title: Text(
                '카메라로 촬영',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                // TODO: 실제 카메라 촬영 구현
                await userProvider.setProfileImage('assets/emoticons/rabbit-excited.jpg');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '프로필 사진이 변경되었어요! 📸',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(16),
                  ),
                );
              },
            ),
            if (userProvider.profileImagePath != null && userProvider.profileImagePath!.isNotEmpty)
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
                ),
                title: Text(
                  '프로필 사진 제거',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await userProvider.setProfileImage('');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '프로필 사진이 제거되었어요! 🗑️',
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      backgroundColor: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.all(16),
                    ),
                  );
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
            ),
            SizedBox(width: 12),
            Text(
              '로그아웃',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Text(
          '정말로 로그아웃하시겠어요? 🥺',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              userProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              '로그아웃',
              style: TextStyle(
                color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.photo_camera,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(width: 12),
            Text(
              '프로필 사진 변경',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
              title: Text(
                '갤러리에서 선택',
                style: TextStyle(
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery(context, userProvider);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
              title: Text(
                '카메라로 촬영',
                style: TextStyle(
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera(context, userProvider);
              },
            ),
            if (userProvider.profileImageUrl != null && userProvider.profileImageUrl!.isNotEmpty)
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
                ),
                title: Text(
                  '현재 사진 삭제',
                  style: TextStyle(
                    color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfileImage(context, userProvider);
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickImageFromGallery(BuildContext context, UserProvider userProvider) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final Uint8List uint8list = bytes;
      final String base64Image = 'data:${image.mimeType};base64,${base64Encode(uint8list)}';

      await userProvider.setProfileImage(base64Image);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '프로필 사진이 변경되었어요! 📸',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  void _pickImageFromCamera(BuildContext context, UserProvider userProvider) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final Uint8List uint8list = bytes;
      final String base64Image = 'data:${image.mimeType};base64,${base64Encode(uint8list)}';

      await userProvider.setProfileImage(base64Image);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '프로필 사진이 변경되었어요! 📸',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  void _removeProfileImage(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    userProvider.setProfileImage('');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '프로필 사진이 제거되었어요! 🗑️',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildProfileImage(String imagePath) {
    try {
      if (imagePath.startsWith('data:')) {
        // Base64 이미지
        final String base64Data = imagePath.split(',')[1];
        return Image.memory(
          base64Decode(base64Data),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            color: Colors.white,
            size: 28,
          ),
        );
      } else {
        // Asset 이미지
        return Image.asset(
          imagePath,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            color: Colors.white,
            size: 28,
          ),
        );
      }
    } catch (e) {
      return Icon(
        Icons.person,
        color: Colors.white,
        size: 28,
      );
    }
  }

  void _showSubscriptionDialog(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.subscriptions,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(width: 12),
            Text(
              '구독 관리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [LifewispColors.darkPink.withOpacity(0.2), LifewispColors.darkPurple.withOpacity(0.2)]
                      : [LifewispColors.pink.withOpacity(0.1), LifewispColors.purple.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        subscriptionProvider.isPremium ? Icons.star : Icons.star_border,
                        color: isDark ? LifewispColors.darkPink : LifewispColors.pink,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        subscriptionProvider.isPremium ? '프리미엄 구독 중' : '무료 플랜',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? LifewispColors.darkPink : LifewispColors.pink,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    subscriptionProvider.isPremium 
                        ? '모든 프리미엄 기능을 이용할 수 있어요! ✨'
                        : '프리미엄으로 업그레이드하여 더 많은 기능을 이용해보세요!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (subscriptionProvider.isPremium) ...[
              ListTile(
                leading: Icon(
                  Icons.cancel,
                  color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
                ),
                title: Text(
                  '구독 취소',
                  style: TextStyle(
                    color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCancelSubscriptionDialog(context, subscriptionProvider);
                },
              ),
            ] else ...[
              ListTile(
                leading: Icon(
                  Icons.upgrade,
                  color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                ),
                title: Text(
                  '프리미엄으로 업그레이드',
                  style: TextStyle(
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/subscription');
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '닫기',
              style: TextStyle(
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionDialog(BuildContext context, SubscriptionProvider subscriptionProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
            ),
            SizedBox(width: 12),
            Text(
              '구독 취소',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Text(
          '정말로 프리미엄 구독을 취소하시겠어요?\n\n구독을 취소하면 프리미엄 기능을 더 이상 이용할 수 없어요.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // 실제 구현에서는 구독 취소 로직
              subscriptionProvider.cancelSubscription();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '구독이 취소되었어요! 😢',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  backgroundColor: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(16),
                ),
              );
            },
            child: Text(
              '구독 취소',
              style: TextStyle(
                color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

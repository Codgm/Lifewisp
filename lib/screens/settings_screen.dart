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



  final List<String> availableFonts = ['Poor Story', 'Jua', 'Noto Sans', 'Do Hyeon', 'Black Han Sans', 'Cute Font'];
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
                  style: LifewispTextStyles.getStaticFont(context,
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
          onChanged: (value) async {
            // 알림 설정 변경 시 권한 체크 및 처리
            if (value) {
              // 알림 활성화 시 권한 확인
              final hasPermission = await userProvider.requestNotificationPermissions();
              if (!hasPermission) {
                // 권한이 없으면 설정 앱으로 유도하는 다이얼로그 표시
                _showPermissionDialog(context, isDark);
                return;
              }
            }

            await userProvider.setNotificationEnabled(value);

            // 설정 완료 후 피드백
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? '알림이 활성화되었어요! 🔔' : '알림이 비활성화되었어요! 🔕',
                    style: LifewispTextStyles.getStaticFont(context,
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                    ),
                  ),
                  backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(16),
                ),
              );
            }
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
            onChanged: (value) async {
              await userProvider.setSoundEnabled(value);
            },
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            title: '진동',
            subtitle: '알림 시 진동을 사용합니다',
            value: userProvider.vibrationEnabled,
            onChanged: (value) async {
              await userProvider.setVibrationEnabled(value);
            },
            isDark: isDark,
          ),
          _buildDivider(isDark),
          // 테스트 알림 버튼 추가
          _buildTestNotificationTile(userProvider, isDark),
        ],
      ],
      isDark: isDark,
    );
  }

  Widget _buildTestNotificationTile(UserProvider userProvider, bool isDark) {
    return InkWell(
      onTap: () async {
        final success = await userProvider.sendTestNotification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? '테스트 알림이 전송되었어요! 🧪' : '테스트 알림 전송에 실패했어요 😥',
                style: LifewispTextStyles.getStaticFont(context,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                ),
              ),
              backgroundColor: success
                  ? (isDark ? LifewispColors.darkSuccess : const Color(0xFF38B2AC))
                  : (isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E)),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.all(16),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? LifewispColors.darkSuccess : const Color(0xFF38B2AC)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_active,
                color: isDark ? LifewispColors.darkSuccess : const Color(0xFF38B2AC),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '테스트 알림',
                    style: LifewispTextStyles.getStaticFont(context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '알림이 제대로 작동하는지 확인해보세요',
                    style: LifewispTextStyles.getStaticFont(context,
                      fontSize: 14,
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.send,
              color: isDark ? LifewispColors.darkSuccess : const Color(0xFF38B2AC),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.notifications_off,
              color: isDark ? LifewispColors.darkRed : const Color(0xFFE53E3E),
            ),
            SizedBox(width: 12),
            Text(
              '알림 권한 필요',
              style: LifewispTextStyles.getStaticFont(context,
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
              '감정 기록 알림을 받기 위해서는 알림 권한이 필요해요.',
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '설정 > 앱 > LifeWisp > 알림에서 권한을 허용해주세요.',
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: LifewispTextStyles.getStaticFont(context,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
    return Consumer<SubscriptionProvider>(
      builder: (context, subscription, child) {
        return _buildSection(
          title: '👤 계정 설정',
          children: [
            // 구독 관리 타일 (상태 표시 개선)
            _buildTileWithTrailing(
              icon: subscription.isPremium ? Icons.workspace_premium : Icons.subscriptions,
              title: '구독 관리',
              subtitle: subscription.isPremium
                  ? '프리미엄 구독 중 • 클라우드 백업 활성'
                  : '무료 버전 • 로컬 저장만 가능',
              trailing: subscription.isPremium
                  ? Icon(Icons.verified, color: Colors.amber, size: 20)
                  : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => _showSubscriptionDialog(context, userProvider),
              isDark: isDark,
            ),
            _buildDivider(isDark),

            // 클라우드 백업 상태 타일 (새로 추가)
            _buildTileWithTrailing(
              icon: subscription.canUseCloudStorage ? Icons.cloud_done : Icons.cloud_off,
              title: '클라우드 백업',
              subtitle: subscription.canUseCloudStorage
                  ? '감정 기록이 안전하게 백업됩니다'
                  : '프리미엄으로 업그레이드하여 클라우드 백업을 이용하세요',
              trailing: subscription.canUseCloudStorage
                  ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                  : TextButton(
                onPressed: () => _showUpgradeDialog(context, subscription),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size(0, 0),
                ),
                child: Text('업그레이드', style: TextStyle(fontSize: 12)),
              ),
              onTap: subscription.canUseCloudStorage
                  ? null
                  : () => _showUpgradeDialog(context, subscription),
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
      },
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
            style: LifewispTextStyles.getStaticFont(context,
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
                    style: LifewispTextStyles.getStaticFont(context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: LifewispTextStyles.getStaticFont(context,
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

  Widget _buildTileWithTrailing({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
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
                    style: LifewispTextStyles.getStaticFont(context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: LifewispTextStyles.getStaticFont(context,
                      fontSize: 14,
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeBenefit(String benefit) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // 업그레이드 다이얼로그 메서드
  void _showUpgradeDialog(BuildContext context, SubscriptionProvider subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cloud_upload, color: Colors.blue),
            SizedBox(width: 8),
            Text('클라우드 백업'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '프리미엄으로 업그레이드하면:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            _buildUpgradeBenefit('자동 클라우드 백업으로 데이터 안전 보장'),
            _buildUpgradeBenefit('여러 기기에서 동기화'),
            _buildUpgradeBenefit('무제한 AI 채팅'),
            _buildUpgradeBenefit('고급 분석 기능'),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '월 ₩9,900',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    '언제든지 취소 가능',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await subscription.upgradeToPremium();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 프리미엄 구독이 활성화되었습니다!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('구독하기'),
          ),
        ],
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
                  style: LifewispTextStyles.getStaticFont(context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: LifewispTextStyles.getStaticFont(context,
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
                    style: LifewispTextStyles.getStaticFont(context,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: LifewispTextStyles.getStaticFont(context,
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
          style: LifewispTextStyles.getStaticFont(context,
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '알림 시간이 ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}로 설정되었어요! ⏰',
              style: LifewispTextStyles.getStaticFont(context,
                  fontWeight: FontWeight.w500,
                  color: Colors.white
              ),
            ),
            backgroundColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.all(16),
          ),
        );
      }
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
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
        style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
              style: LifewispTextStyles.getStaticFont(context,
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
                style: LifewispTextStyles.getStaticFont(context,
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
                      style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
                style: LifewispTextStyles.getStaticFont(context,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎨 실시간 미리보기 섹션 - 더 큰 크기와 다양한 텍스트
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                          LifewispColors.darkPrimary.withOpacity(0.15),
                          LifewispColors.darkPrimary.withOpacity(0.08),
                        ]
                            : [
                          LifewispColors.accent.withOpacity(0.12),
                          LifewispColors.accent.withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? LifewispColors.darkPrimary.withOpacity(0.3)
                            : LifewispColors.accent.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.preview,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '실시간 미리보기',
                              style: LifewispTextStyles.getStaticFont(context,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // 다양한 텍스트 샘플로 미리보기
                        _buildFontPreviewText(
                          'LifeWisp 감정 일기 ✨',
                          fontFamily: tempSelectedFont,
                          fontSize: tempFontSize * 1.2,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Color(0xFF2D3748),
                        ),
                        SizedBox(height: 12),

                        _buildFontPreviewText(
                          '오늘 하루도 감정을 기록해보세요!',
                          fontFamily: tempSelectedFont,
                          fontSize: tempFontSize,
                          fontWeight: FontWeight.w600,
                          color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                        ),
                        SizedBox(height: 10),

                        _buildFontPreviewText(
                          '행복한 하루였어요! 친구들과 즐거운 시간을 보내며 맛있는 음식도 먹었습니다.',
                          fontFamily: tempSelectedFont,
                          fontSize: tempFontSize * 0.9,
                          fontWeight: FontWeight.normal,
                          color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                          height: 1.5,
                        ),
                        SizedBox(height: 8),

                        _buildFontPreviewText(
                          '가나다라마바사 ABCD 1234 !@#',
                          fontFamily: tempSelectedFont,
                          fontSize: tempFontSize * 0.8,
                          fontWeight: FontWeight.normal,
                          color: isDark ? LifewispColors.darkSubText.withOpacity(0.7) : LifewispColors.subText.withOpacity(0.7),
                        ),

                        SizedBox(height: 12),

                        // 감정 표현 미리보기
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildEmotionPreview('😊', '행복해요', tempSelectedFont, tempFontSize * 0.85, isDark),
                            _buildEmotionPreview('😢', '슬퍼요', tempSelectedFont, tempFontSize * 0.85, isDark),
                            _buildEmotionPreview('😡', '화나요', tempSelectedFont, tempFontSize * 0.85, isDark),
                            _buildEmotionPreview('😍', '좋아요', tempSelectedFont, tempFontSize * 0.85, isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28),

                  // 폰트 선택 섹션
                  Row(
                    children: [
                      Icon(
                        Icons.font_download_outlined,
                        color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '폰트 종류',
                        style: LifewispTextStyles.getStaticFont(context,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: availableFonts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final font = entry.value;
                        final isSelected = tempSelectedFont == font;
                        final isFirst = index == 0;
                        final isLast = index == availableFonts.length - 1;

                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? LifewispColors.darkPrimary.withOpacity(0.15) : LifewispColors.accent.withOpacity(0.12))
                                : Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: isFirst ? Radius.circular(16) : Radius.zero,
                              topRight: isFirst ? Radius.circular(16) : Radius.zero,
                              bottomLeft: isLast ? Radius.circular(16) : Radius.zero,
                              bottomRight: isLast ? Radius.circular(16) : Radius.zero,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            title: _buildFontPreviewText(
                              font,
                              fontFamily: font,
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                                  : (isDark ? LifewispColors.darkMainText : LifewispColors.mainText),
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: _buildFontPreviewText(
                                '오늘의 감정을 기록해보세요 ✨ ABC 123',
                                fontFamily: font,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                              ),
                            ),
                            trailing: isSelected
                                ? Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                                : Icon(
                              Icons.radio_button_unchecked,
                              color: isDark ? LifewispColors.darkSubText.withOpacity(0.5) : LifewispColors.subText.withOpacity(0.5),
                              size: 20,
                            ),
                            onTap: () {
                              setDialogState(() {
                                tempSelectedFont = font;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 28),

                  // 폰트 크기 섹션
                  Row(
                    children: [
                      Icon(
                        Icons.format_size,
                        color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '폰트 크기',
                        style: LifewispTextStyles.getStaticFont(context,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // 폰트 크기 슬라이더
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.text_decrease,
                                  color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                                  size: 20,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '작게',
                                  style: LifewispTextStyles.getStaticFont(context,
                                    fontSize: 12,
                                    color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [LifewispColors.darkPrimary, LifewispColors.darkPrimary.withOpacity(0.8)]
                                      : [LifewispColors.accent, LifewispColors.accent.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${tempFontSize.toInt()}px',
                                style: LifewispTextStyles.getStaticFont(context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.text_increase,
                                  color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                                  size: 20,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '크게',
                                  style: LifewispTextStyles.getStaticFont(context,
                                    fontSize: 12,
                                    color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                            inactiveTrackColor: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.3),
                            thumbColor: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                            overlayColor: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.2),
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                            overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
                            trackHeight: 6,
                          ),
                          child: Slider(
                            value: tempFontSize,
                            min: 12.0,
                            max: 24.0,
                            divisions: 12,
                            onChanged: (value) {
                              setDialogState(() {
                                tempFontSize = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            final size = 12.0 + (index * 3);
                            final isActive = (tempFontSize - size).abs() < 1.5;
                            return Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                '${size.toInt()}',
                                style: LifewispTextStyles.getStaticFont(context,
                                  fontSize: 11,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                  color: isActive
                                      ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                                      : (isDark ? LifewispColors.darkSubText : LifewispColors.subText),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: LifewispTextStyles.getStaticFont(context,
                  color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [LifewispColors.darkPrimary, LifewispColors.darkPrimary.withOpacity(0.8)]
                      : [LifewispColors.accent, LifewispColors.accent.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? LifewispColors.darkPrimary : LifewispColors.accent).withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () async {
                  await userProvider.setFontSettings(tempSelectedFont, tempFontSize);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.check_circle, color: Colors.white, size: 18),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '폰트가 $tempSelectedFont ${tempFontSize.toInt()}px로 변경되었어요! 🎨',
                              style: LifewispTextStyles.getStaticFont(context,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: isDark ? LifewispColors.darkSuccess : const Color(0xFF38B2AC),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.all(16),
                      duration: Duration(seconds: 3),
                      elevation: 6,
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '적용하기',
                    style: LifewispTextStyles.getStaticFont(context,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontPreviewText(
      String text, {
        required String fontFamily,
        required double fontSize,
        FontWeight? fontWeight,
        Color? color,
        double? height,
      }) {
    // 선택된 폰트에 따라 GoogleFonts 적용
    TextStyle textStyle;
    switch (fontFamily) {
      case 'Poor Story':
        textStyle = GoogleFonts.poorStory(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? Colors.black,
          height: height,
        );
        break;
      case 'Jua':
        textStyle = GoogleFonts.jua(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? Colors.black,
          height: height,
        );
        break;
      case 'Noto Sans':
        textStyle = GoogleFonts.notoSans(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? Colors.black,
          height: height,
        );
        break;
      case 'Do Hyeon':
        textStyle = GoogleFonts.doHyeon(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? Colors.black,
          height: height,
        );
        break;
      case 'Black Han Sans':
        textStyle = GoogleFonts.blackHanSans(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? Colors.black,
          height: height,
        );
        break;
      case 'Cute Font':
        textStyle = GoogleFonts.cuteFont(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? Colors.black,
          height: height,
        );
        break;
      default:
        textStyle = GoogleFonts.poorStory(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? Colors.black,
          height: height,
        );
    }

    return Text(text, style: textStyle);
  }

  Widget _buildEmotionPreview(String emoji, String label, String fontFamily, double fontSize, bool isDark) {
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: fontSize * 1.4),
        ),
        SizedBox(height: 4),
        _buildFontPreviewText(
          label,
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
        ),
      ],
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
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
              decoration: InputDecoration(
                labelText: '닉네임',
                labelStyle: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
                    style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Text(
          '등록된 이메일로 비밀번호 재설정 링크를 보내드릴게요! 📧',
          style: LifewispTextStyles.getStaticFont(context,
            fontSize: 14,
            color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: LifewispTextStyles.getStaticFont(context,
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
                    style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '매일의 감정과 하루 일과를 간단히 기록할 수 있어요',
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '📊 통계 보기',
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '감정 변화를 차트로 확인하고 패턴을 분석해보세요',
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '🔔 알림 설정',
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '매일 정해진 시간에 기록 알림을 받을 수 있어요',
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '당신의 감정을 소중히 기록하고 관리하는 앱입니다. 💜',
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 14,
                color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '개발자: Codgm',
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
                style: LifewispTextStyles.getStaticFont(context,
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
                style: LifewispTextStyles.getStaticFont(context,
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
                  style: LifewispTextStyles.getStaticFont(context,
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
                style: LifewispTextStyles.getStaticFont(context,
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
                      style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
                style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
                style: LifewispTextStyles.getStaticFont(context,
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
                      style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
                style: LifewispTextStyles.getStaticFont(context,
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
                      style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
                  style: LifewispTextStyles.getStaticFont(context,
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
                        style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Text(
          '정말로 로그아웃하시겠어요? 🥺',
          style: LifewispTextStyles.getStaticFont(context,
            fontSize: 14,
            color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
                style: LifewispTextStyles.getStaticFont(context,
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
                style: LifewispTextStyles.getStaticFont(context,
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
                  style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
            style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
            style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
          style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
              style: LifewispTextStyles.getStaticFont(context,
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
                        style: LifewispTextStyles.getStaticFont(context,
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
                    style: LifewispTextStyles.getStaticFont(context,
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
                  style: LifewispTextStyles.getStaticFont(context,
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
                  style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
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
              style: LifewispTextStyles.getStaticFont(context,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              ),
            ),
          ],
        ),
        content: Text(
          '정말로 프리미엄 구독을 취소하시겠어요?\n\n구독을 취소하면 프리미엄 기능을 더 이상 이용할 수 없어요.',
          style: LifewispTextStyles.getStaticFont(context,
            fontSize: 14,
            color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: LifewispTextStyles.getStaticFont(context,
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
                    style: LifewispTextStyles.getStaticFont(context, fontWeight: FontWeight.w500, color: Colors.white),
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
              style: LifewispTextStyles.getStaticFont(context,
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

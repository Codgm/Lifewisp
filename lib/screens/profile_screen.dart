import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        title: Text('내 프로필 ✨',
            style: GoogleFonts.jua(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748)
            )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF2D3748)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 프로필 헤더
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE6E6FA),
                      Color(0xFFDDA0DD),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 프로필 이미지
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 사용자 정보
                    Text(
                      userProvider.userNickname ?? '익명의 사용자',
                      style: GoogleFonts.jua(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProvider.userEmail ?? 'user@example.com',
                      style: GoogleFonts.jua(
                        fontSize: 14,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 통계 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('일기', '28개', Icons.book),
                        _buildStatItem('연속', '7일', Icons.local_fire_department),
                        _buildStatItem('레벨', 'Lv.3', Icons.star),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 설정 메뉴들
              _buildMenuSection('계정 설정', [
                _buildMenuItem(
                  icon: Icons.lock_reset,
                  title: '비밀번호 재설정',
                  subtitle: '비밀번호를 변경할 수 있어요',
                  onTap: () {
                    _showPasswordResetDialog(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: '프로필 수정',
                  subtitle: '닉네임과 프로필을 변경해요',
                  onTap: () {
                    _showProfileEditDialog(context, userProvider);
                  },
                ),
              ]),

              const SizedBox(height: 24),

              _buildMenuSection('앱 설정', [
                _buildMenuItem(
                  icon: Icons.palette,
                  title: '테마 설정',
                  subtitle: '나만의 테마를 선택해요',
                  onTap: () {
                    _showThemeDialog(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: '알림 설정',
                  subtitle: '감정 기록 알림을 설정해요',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('알림 설정 기능은 곧 업데이트될 예정이에요! 🔔',
                            style: GoogleFonts.jua(fontWeight: FontWeight.w500)
                        ),
                        backgroundColor: const Color(0xFF667EEA),
                      ),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 24),

              _buildMenuSection('기타', [
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: '도움말',
                  subtitle: '앱 사용법을 확인해요',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('도움말 페이지로 이동할게요! 📖',
                            style: GoogleFonts.jua(fontWeight: FontWeight.w500)
                        ),
                        backgroundColor: const Color(0xFF38B2AC),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: '앱 정보',
                  subtitle: 'LifeWisp v1.0.0',
                  onTap: () {
                    _showAppInfoDialog(context);
                  },
                ),
              ]),

              const SizedBox(height: 40),

              // 로그아웃 버튼
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFE53E3E).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context, userProvider);
                  },
                  icon: const Icon(Icons.logout, color: Color(0xFFE53E3E)),
                  label: Text(
                    '로그아웃',
                    style: GoogleFonts.jua(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE53E3E),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667EEA),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.jua(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.jua(
            fontSize: 12,
            color: const Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.jua(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF667EEA),
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
                    style: GoogleFonts.jua(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.jua(
                      fontSize: 13,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF718096),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('비밀번호 재설정',
            style: GoogleFonts.jua(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )
        ),
        content: Text('등록된 이메일로 비밀번호 재설정 링크를 보내드릴게요! 📧',
            style: GoogleFonts.jua(fontSize: 14)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소',
                style: GoogleFonts.jua(
                  color: const Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                )
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('이메일이 전송되었어요! 📧',
                      style: GoogleFonts.jua(fontWeight: FontWeight.w500)
                  ),
                  backgroundColor: const Color(0xFF38B2AC),
                ),
              );
            },
            child: Text('전송',
                style: GoogleFonts.jua(
                  color: const Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                )
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileEditDialog(BuildContext context, UserProvider userProvider) {
    final nicknameController = TextEditingController(text: userProvider.userNickname);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('프로필 수정',
            style: GoogleFonts.jua(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임',
                labelStyle: GoogleFonts.jua(
                  color: const Color(0xFF718096),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF667EEA)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소',
                style: GoogleFonts.jua(
                  color: const Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                )
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: 실제 프로필 업데이트 로직
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('프로필이 수정되었어요! ✨',
                      style: GoogleFonts.jua(fontWeight: FontWeight.w500)
                  ),
                  backgroundColor: const Color(0xFF38B2AC),
                ),
              );
            },
            child: Text('저장',
                style: GoogleFonts.jua(
                  color: const Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                )
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('테마 선택',
            style: GoogleFonts.jua(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('라이트 모드', Icons.light_mode, true, context),
            _buildThemeOption('다크 모드', Icons.dark_mode, false, context),
            _buildThemeOption('시스템 설정', Icons.settings, false, context),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인',
                style: GoogleFonts.jua(
                  color: const Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, IconData icon, bool isSelected, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF667EEA) : const Color(0xFF718096)),
      title: Text(
        title,
        style: GoogleFonts.jua(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? const Color(0xFF667EEA) : const Color(0xFF2D3748),
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF667EEA)) : null,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title로 변경되었어요! 🎨',
                style: GoogleFonts.jua(fontWeight: FontWeight.w500)
            ),
            backgroundColor: const Color(0xFF667EEA),
          ),
        );
      },
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.favorite,
                color: Color(0xFF667EEA),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text('LifeWisp',
                style: GoogleFonts.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                )
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('버전: 1.0.0',
                style: GoogleFonts.jua(fontSize: 14)
            ),
            const SizedBox(height: 8),
            Text('당신의 감정을 소중히 기록하고 관리하는 앱입니다. 💜',
                style: GoogleFonts.jua(fontSize: 14)
            ),
            const SizedBox(height: 8),
            Text('개발자: LifeWisp Team',
                style: GoogleFonts.jua(fontSize: 14)
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인',
                style: GoogleFonts.jua(
                  color: const Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                )
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('로그아웃',
            style: GoogleFonts.jua(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            )
        ),
        content: Text('정말로 로그아웃하시겠어요? 🥺',
            style: GoogleFonts.jua(fontSize: 14)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소',
                style: GoogleFonts.jua(
                  color: const Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                )
            ),
          ),
          TextButton(
            onPressed: () {
              userProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('로그아웃',
                style: GoogleFonts.jua(
                  color: const Color(0xFFE53E3E),
                  fontWeight: FontWeight.w600,
                )
            ),
          ),
        ],
      ),
    );
  }
}
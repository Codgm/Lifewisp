import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../dashboard_screen.dart';
import '../../utils/theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;
  String? error;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LifewispColors.darkPink,
              LifewispColors.darkPurple,
              LifewispColors.darkBlue,
            ],
          )
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B9D),
              Color(0xFF9B59B6),
              Color(0xFF3498DB),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final isTablet = constraints.maxWidth > 768;
              final maxWidth = isTablet ? 500.0 : double.infinity;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Container(
                        width: maxWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 40 : 24,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            // 상단 헤더 영역
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: isWide ? 60 : 40,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    LifewispColors.darkPink,
                                    LifewispColors.darkPurple,
                                    LifewispColors.darkBlue,
                                  ],
                                )
                                    : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFF6B9D),
                                    Color(0xFF9B59B6),
                                    Color(0xFF3498DB),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? LifewispColors.darkPink : Color(0xFFFF6B9D)).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                                border: isDark
                                    ? Border.all(color: LifewispColors.darkCardBorder.withOpacity(0.3))
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  // 배경 패턴
                                  ...List.generate(8, (index) {
                                    final random = index * 0.3;
                                    return Positioned(
                                      left: (index % 4) * (isWide ? 120.0 : 80.0) + random * 20,
                                      top: 20 + (index ~/ 4) * 40.0 + random * 30,
                                      child: Container(
                                        width: 15 + random * 8,
                                        height: 15 + random * 8,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }),

                                  // 메인 콘텐츠
                                  Center(
                                    child: FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // 귀여운 캐릭터
                                            Container(
                                              width: isWide ? 100 : 80,
                                              height: isWide ? 100 : 80,
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? LifewispColors.darkCardBg.withOpacity(0.9)
                                                    : Colors.white,
                                                borderRadius: BorderRadius.circular(isWide ? 50 : 40),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                                                    blurRadius: 25,
                                                    offset: const Offset(0, 12),
                                                  ),
                                                ],
                                                border: isDark
                                                    ? Border.all(color: LifewispColors.darkCardBorder.withOpacity(0.5))
                                                    : null,
                                              ),
                                              child: Center(
                                                child: Text('🌸', style: TextStyle(fontSize: isWide ? 50 : 40)),
                                              ),
                                            ),
                                            SizedBox(height: isWide ? 24 : 20),
                                            ShaderMask(
                                              shaderCallback: (bounds) => LinearGradient(
                                                colors: [Colors.white, Colors.white.withOpacity(0.9)],
                                              ).createShader(bounds),
                                              child: Text(
                                                'Lifewisp',
                                                style: GoogleFonts.jua(
                                                  fontSize: isWide ? 40 : 32,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: isWide ? 12 : 8),
                                            Text(
                                              '당신의 감정 여행을 시작해보세요!',
                                              style: GoogleFonts.jua(
                                                fontSize: isWide ? 18 : 16,
                                                color: Colors.white.withOpacity(0.9),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 30),

                            // 폼 영역
                            Expanded(
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  padding: EdgeInsets.all(isWide ? 32 : 24),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? LifewispColors.darkCardBg.withOpacity(0.95)
                                        : Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                    border: isDark
                                        ? Border.all(color: LifewispColors.darkCardBorder.withOpacity(0.3))
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // 이메일 입력
                                      _buildTextField(
                                        controller: emailController,
                                        label: '이메일',
                                        icon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        isWide: isWide,
                                        isDark: isDark,
                                      ),
                                      SizedBox(height: isWide ? 24 : 20),

                                      // 비밀번호 입력
                                      _buildTextField(
                                        controller: passwordController,
                                        label: '비밀번호',
                                        icon: Icons.lock_outline,
                                        obscureText: true,
                                        isWide: isWide,
                                        isDark: isDark,
                                      ),
                                      SizedBox(height: isWide ? 24 : 20),

                                      // 비밀번호 확인
                                      _buildTextField(
                                        controller: confirmController,
                                        label: '비밀번호 확인',
                                        icon: Icons.lock_outline,
                                        obscureText: true,
                                        isWide: isWide,
                                        isDark: isDark,
                                      ),

                                      if (error != null) ...[
                                        SizedBox(height: isWide ? 20 : 16),
                                        Container(
                                          padding: EdgeInsets.all(isWide ? 16 : 12),
                                          decoration: BoxDecoration(
                                            color: (isDark ? LifewispColors.darkRed : Colors.red).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                                color: (isDark ? LifewispColors.darkRed : Colors.red).withOpacity(0.3)
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons.error_outline,
                                                  color: isDark ? LifewispColors.darkRed : Colors.red,
                                                  size: isWide ? 24 : 20
                                              ),
                                              SizedBox(width: isWide ? 12 : 8),
                                              Expanded(
                                                child: Text(
                                                  error!,
                                                  style: GoogleFonts.jua(
                                                    color: isDark ? LifewispColors.darkRed : Colors.red,
                                                    fontSize: isWide ? 16 : 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      SizedBox(height: isWide ? 40 : 30),

                                      // 회원가입 버튼
                                      Container(
                                        height: isWide ? 64 : 56,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: isDark
                                                ? [LifewispColors.darkPink, LifewispColors.darkPurple]
                                                : [Color(0xFFFF6B9D), Color(0xFF9B59B6)],
                                          ),
                                          borderRadius: BorderRadius.circular(isWide ? 32 : 28),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isDark ? LifewispColors.darkPink : Color(0xFFFF6B9D)).withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : _handleSignUp,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(isWide ? 32 : 28),
                                            ),
                                          ),
                                          child: isLoading
                                              ? SizedBox(
                                            width: isWide ? 28 : 24,
                                            height: isWide ? 28 : 24,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              strokeWidth: 2,
                                            ),
                                          )
                                              : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('✨', style: TextStyle(fontSize: isWide ? 24 : 20)),
                                              SizedBox(width: isWide ? 12 : 8),
                                              Text(
                                                '회원가입하기',
                                                style: GoogleFonts.jua(
                                                  fontSize: isWide ? 20 : 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: isWide ? 24 : 20),

                                      // 로그인 버튼
                                      Container(
                                        height: isWide ? 64 : 56,
                                        decoration: BoxDecoration(
                                          color: isDark ? LifewispColors.darkCardBg : Colors.white,
                                          borderRadius: BorderRadius.circular(isWide ? 32 : 28),
                                          border: Border.all(
                                            color: (isDark ? LifewispColors.darkPink : Color(0xFFFF6B9D)).withOpacity(0.3),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context, '/login');
                                          },
                                          style: TextButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(isWide ? 32 : 28),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('👋', style: TextStyle(fontSize: isWide ? 24 : 20)),
                                              SizedBox(width: isWide ? 12 : 8),
                                              Text(
                                                '이미 계정이 있어요',
                                                style: GoogleFonts.jua(
                                                  fontSize: isWide ? 18 : 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? LifewispColors.darkPink : Color(0xFFFF6B9D),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      Spacer(),

                                      // 소셜 로그인 힌트
                                      Container(
                                        padding: EdgeInsets.all(isWide ? 20 : 16),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? LifewispColors.darkPinkLight.withOpacity(0.2)
                                              : Color(0xFFFFE5F1).withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: (isDark ? LifewispColors.darkPink : Color(0xFFFF6B9D)).withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('🔒', style: TextStyle(fontSize: isWide ? 22 : 18)),
                                            SizedBox(width: isWide ? 12 : 8),
                                            Text(
                                              '안전하고 개인적인 감정 기록',
                                              style: GoogleFonts.jua(
                                                fontSize: isWide ? 16 : 14,
                                                color: isDark ? LifewispColors.darkPurple : Color(0xFF9B59B6),
                                                fontWeight: FontWeight.w600,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    required bool isWide,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isDark
            ? Border.all(color: LifewispColors.darkCardBorder.withOpacity(0.3))
            : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.jua(
          fontSize: isWide ? 18 : 16,
          color: isDark ? LifewispColors.darkMainText : LifewispColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.jua(
            fontSize: isWide ? 16 : 14,
            color: isDark ? LifewispColors.darkSubText : LifewispColors.textSecondary,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(isWide ? 16 : 12),
            padding: EdgeInsets.all(isWide ? 10 : 8),
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                colors: [
                  LifewispColors.darkPinkLight.withOpacity(0.3),
                  LifewispColors.darkBlue.withOpacity(0.3),
                ],
              )
                  : LinearGradient(
                colors: [
                  Color(0xFFFFE5F1),
                  Color(0xFFF0F8FF),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDark ? LifewispColors.darkPink : Color(0xFFFF6B9D),
              size: isWide ? 24 : 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? LifewispColors.darkPink : Color(0xFFFF6B9D),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: isDark ? LifewispColors.darkCardBg : Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isWide ? 20 : 16,
            vertical: isWide ? 20 : 16,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (passwordController.text != confirmController.text) {
      setState(() { error = '비밀번호가 일치하지 않습니다.'; });
      return;
    }

    setState(() { isLoading = true; error = null; });

    // 애니메이션 효과
    await Future.delayed(const Duration(milliseconds: 500));

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.signup(
        emailController.text.trim(),
        passwordController.text.trim()
    );

    setState(() { isLoading = false; });

    if (success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      setState(() { error = '회원가입에 실패했습니다. 다시 시도해주세요.'; });
    }
  }
}
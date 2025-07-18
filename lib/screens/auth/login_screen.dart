import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? error;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late AnimationController _breathingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _breathingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _breathingController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    final isTablet = size.width > 768;
    final isDesktop = size.width > 1024;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE5F1), // 연한 핑크
              Color(0xFFF0F8FF), // 연한 하늘색
              Color(0xFFE8F5E8), // 연한 민트
              Color(0xFFFFF8E1), // 연한 노랑
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: isDesktop
                        ? _buildDesktopLayout(size)
                        : _buildMobileLayout(size, isWide),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    return Row(
      children: [
        // 왼쪽 헤더 영역
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(60),
            child: _buildHeaderSection(size, isDesktop: true),
          ),
        ),
        // 오른쪽 폼 영역
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: _buildFormSection(size, isDesktop: true),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Size size, bool isWide) {
    return Column(
      children: [
        // 상단 헤더 영역
        _buildHeaderSection(size, isWide: isWide),
        // 폼 영역
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isWide ? 40 : 20,
              vertical: 20,
            ),
            padding: EdgeInsets.all(isWide ? 32 : 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: _buildFormSection(size, isWide: isWide),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(Size size, {bool isDesktop = false, bool isWide = false}) {
    final headerHeight = isDesktop ? null : (isWide ? 320.0 : 280.0);

    return Container(
      height: headerHeight,
      decoration: isDesktop ? null : BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF6B9D), // 핑크
            Color(0xFF9B59B6), // 퍼플
            Color(0xFF3498DB), // 블루
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: isDesktop ? null : const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // 떠다니는 배경 요소들
          if (!isDesktop) ...List.generate(12, (index) {
            final random = index * 0.15;
            return AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Positioned(
                  left: (index % 4) * (size.width / 4) + random * 20 + _breathingAnimation.value * 8,
                  top: 30 + (index ~/ 4) * 60.0 + random * 30 + _breathingAnimation.value * 12,
                  child: Container(
                    width: 12 + random * 16,
                    height: 12 + random * 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12 + _breathingAnimation.value * 0.08),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              },
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
                    // 캐릭터
                    AnimatedBuilder(
                      animation: _breathingAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + _breathingAnimation.value * 0.08,
                          child: Container(
                            width: isDesktop ? 120 : (isWide ? 110 : 100),
                            height: isDesktop ? 120 : (isWide ? 110 : 100),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFFB6C1),
                                  Color(0xFFDDA0DD),
                                  Color(0xFF98FB98),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: isDesktop
                                      ? Color(0xFFFFB6C1).withOpacity(0.3)
                                      : Colors.black.withOpacity(0.15),
                                  blurRadius: 25,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '🌸',
                                style: TextStyle(
                                  fontSize: isDesktop ? 55 : (isWide ? 50 : 45),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isDesktop ? 32 : 24),

                    // 타이틀
                    Stack(
                      children: [
                        // 테두리용(검정)
                        Text(
                          'Lifewisp',
                          style: TextStyle(
                            fontSize: isDesktop ? 42 : (isWide ? 38 : 36),
                            fontWeight: FontWeight.w800,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.black.withOpacity(0.3),
                            letterSpacing: 1.2,
                          ),
                        ),
                        // 본문(흰색)
                        Text(
                          'Lifewisp',
                          style: TextStyle(
                            fontSize: isDesktop ? 42 : (isWide ? 38 : 36),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isDesktop ? 16 : 12),

                    // 서브타이틀
                    Text(
                      '다시 만나서 반가워요!',
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : (isWide ? 19 : 18),
                        fontWeight: FontWeight.w600,
                        color: isDesktop
                            ? Color(0xFF666666)
                            : Colors.white.withOpacity(0.95),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 12 : 8),
                    Text(
                      '감정 여행을 이어가볼까요? ✨',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : (isWide ? 15 : 14),
                        fontWeight: FontWeight.w500,
                        color: isDesktop
                            ? Color(0xFF888888)
                            : Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(Size size, {bool isDesktop = false, bool isWide = false}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isDesktop) SizedBox(height: 20),

          // 이메일 입력
          _buildTextField(
            controller: emailController,
            label: '이메일',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isWide: isWide,
            isDesktop: isDesktop,
          ),
          SizedBox(height: isDesktop ? 28 : 24),

          // 비밀번호 입력
          _buildTextField(
            controller: passwordController,
            label: '비밀번호',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            isWide: isWide,
            isDesktop: isDesktop,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9CA3AF),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          // 에러 메시지
          if (error != null) ...[
            SizedBox(height: isDesktop ? 24 : 20),
            Container(
              padding: EdgeInsets.all(isDesktop ? 18 : 16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: isDesktop ? 15 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 비밀번호 찾기
          SizedBox(height: isDesktop ? 20 : 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // 비밀번호 찾기 로직
              },
              child: Text(
                '비밀번호를 잊으셨나요?',
                style: TextStyle(
                  fontSize: isDesktop ? 15 : 14,
                  color: const Color(0xFFFF6B9D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: isDesktop ? 32 : 24),

          // 로그인 버튼
          Container(
            height: isDesktop ? 64 : 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF6B9D),
                  Color(0xFF9B59B6),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(isDesktop ? 32 : 29),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 32 : 29),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                width: isDesktop ? 30 : 26,
                height: isDesktop ? 30 : 26,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Text(
                    '로그인하기',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: isDesktop ? 28 : 24),

          // 회원가입 버튼
          Container(
            height: isDesktop ? 60 : 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isDesktop ? 30 : 28),
              border: Border.all(
                color: const Color(0xFFFF6B9D).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 30 : 28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '새로운 계정 만들기',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF6B9D),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!isDesktop) const Spacer(),
          SizedBox(height: isDesktop ? 40 : 20),

          // 보안 정보
          Container(
            padding: EdgeInsets.all(isDesktop ? 24 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5F1).withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💖', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      '감정을 안전하게 기록해요',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: const Color(0xFFFF6B9D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 12 : 8),
                Text(
                  '모든 데이터는 암호화되어 안전하게 보관됩니다',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    bool isWide = false,
    bool isDesktop = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: isDesktop ? 17 : 16,
          color: const Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: isDesktop ? 15 : 14,
            color: const Color(0xFF9CA3AF),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF6B9D),
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFFF6B9D),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isDesktop ? 20 : 18,
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() { isLoading = true; error = null; });

    // 로딩 애니메이션을 위한 딜레이
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // 실제 로그인 로직
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      setState(() {
        error = '로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.';
        isLoading = false;
      });
    }
  }
}
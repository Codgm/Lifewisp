import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/rabbit_emoticon.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 시작
    _slideController.forward();
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 60 : 24,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),

                      // 메인 캐릭터/일러스트
                      SlideTransition(
                        position: _slideAnimation,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFB6C1),
                                      Color(0xFFDDA0DD),
                                      Color(0xFF98FB98),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFFFB6C1).withOpacity(0.4),
                                      blurRadius: 25,
                                      offset: Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        '🌸',
                                        style: TextStyle(fontSize: 90),
                                      ),
                                    ),
                                    // 반짝이는 효과
                                    Positioned(
                                      top: 30,
                                      right: 40,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 40,
                                      left: 35,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 40),

                      // 메인 타이틀
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B9D),
                                    Color(0xFF9B59B6),
                                    Color(0xFF3498DB),
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Lifewisp',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '당신의 하루를 감정으로 기록하고,\nAI와 함께 회고하는\n라이프 아카이빙 도구',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF444444),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // 감정 아이콘들
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildEmotionIcon('😊', '기쁨'),
                              _buildEmotionIcon('😢', '슬픔'),
                              _buildEmotionIcon('😴', '평온'),
                              _buildEmotionIcon('😍', '사랑'),
                              _buildEmotionIcon('😎', '자신감'),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // 주요 기능 소개
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildFeatureItem(
                                icon: Icons.edit_rounded,
                                title: '감정/일기 기록',
                                subtitle: '매일의 감정을 쉽고 간편하게',
                                color: Color(0xFFFF6B9D),
                              ),
                              _buildFeatureItem(
                                icon: Icons.analytics_rounded,
                                title: '감정 분석/그래프',
                                subtitle: '감정 패턴을 시각적으로 확인',
                                color: Color(0xFF3498DB),
                              ),
                              _buildFeatureItem(
                                icon: Icons.emoji_emotions_rounded,
                                title: '감정 성장 캐릭터',
                                subtitle: '귀여운 캐릭터와 함께 성장',
                                color: Color(0xFFFFB347),
                              ),
                              _buildFeatureItem(
                                icon: Icons.psychology_rounded,
                                title: 'AI 회고/코멘트',
                                subtitle: '개인화된 감정 분석과 조언',
                                color: Color(0xFF9B59B6),
                              ),
                              _buildFeatureItem(
                                icon: Icons.share_rounded,
                                title: '감정 기록 공유/저장',
                                subtitle: '소중한 추억을 안전하게 보관',
                                color: Color(0xFF2ECC71),
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 50),

                      // 시작 버튼
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF6B9D),
                                Color(0xFF9B59B6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF6B9D).withOpacity(0.4),
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              '시작하기 ✨',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmotionIcon(String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: RabbitEmoticon(
              emotion: _mapStringToRabbitEmotion(emoji),
              size: 32,
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  RabbitEmotion _mapStringToRabbitEmotion(String emoji) {
    switch (emoji) {
      case '😊':
        return RabbitEmotion.happy;
      case '😢':
        return RabbitEmotion.sad;
      case '😴':
        return RabbitEmotion.calm;
      case '😍':
        return RabbitEmotion.love;
      case '😎':
        return RabbitEmotion.confidence;
      default:
        return RabbitEmotion.despair;
    }
  }
}
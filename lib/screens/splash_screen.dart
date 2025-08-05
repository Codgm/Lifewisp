import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../widgets/rabbit_emoticon.dart';
import '../utils/theme.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // 애니메이션 설정
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    _scaleController.forward();
    _floatController.repeat(reverse: true);

    // 화면 전환
    Timer(Duration(milliseconds: 2500), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: LifewispGradients.onboardingBgFor('emotion', dark: Theme.of(context).brightness == Brightness.dark).asBoxDecoration,
        child: Stack(
          children: [
            // 배경 파티클 효과
            ...List.generate(20, (index) =>
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 100 + (index * 30.0) +
                          (math.sin(_floatAnimation.value * 2 * math.pi + index) * 20),
                      left: 50 + (index * 15.0) +
                          (math.cos(_floatAnimation.value * 2 * math.pi + index) * 30),
                      child: Opacity(
                        opacity: 0.3,
                        child: Container(
                          width: 8 + (index % 4) * 2,
                          height: 8 + (index % 4) * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: [
                              Color(0xFFFFB6C1), // 연한 핑크
                              Color(0xFFDDA0DD), // 연한 보라
                              Color(0xFF98FB98), // 연한 초록
                              Color(0xFFFFFACD), // 연한 노랑
                            ][index % 4],
                          ),
                        ),
                      ),
                    );
                  },
                )
            ),

            // 메인 콘텐츠
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 메인 로고 및 캐릭터
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, math.sin(_floatAnimation.value * 2 * math.pi) * 10),
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFB6C1),
                                      Color(0xFFDDA0DD),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFFFB6C1).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '🌸',
                                    style: TextStyle(fontSize: 60),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 32),

                  // 앱 이름
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ShaderMask(
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
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // 서브 텍스트
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          '오늘의 감정을 기록하세요',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '당신의 마음은 소중하니까요 💕',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 60),

                  // 감정 아이콘들
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFloatingEmoji('😊', 0),
                            SizedBox(width: 16),
                            _buildFloatingEmoji('😢', 0.2),
                            SizedBox(width: 16),
                            _buildFloatingEmoji('😴', 0.4),
                            SizedBox(width: 16),
                            _buildFloatingEmoji('😍', 0.6),
                            SizedBox(width: 16),
                            _buildFloatingEmoji('😎', 0.8),
                          ],
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 80),

                  // 로딩 인디케이터
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF6B9D),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingEmoji(String emoji, double delay) {
    return Transform.translate(
      offset: Offset(
          0,
          math.sin((_floatAnimation.value + delay) * 2 * math.pi) * 8
      ),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
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
        return RabbitEmotion.happy;
    }
  }
}
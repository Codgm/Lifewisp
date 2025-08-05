import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/rabbit_emoticon.dart';
import '../utils/season_utils.dart';

// 계절별 프로필 위젯 (고정 입자 완전 제거)
class SeasonProfileWidget extends StatefulWidget {
  final Season season;
  final double size;
  final VoidCallback? onEditTap; // onTap을 onEditTap으로 변경
  final String userName;
  final String? profileImageUrl;

  const SeasonProfileWidget({
    Key? key,
    required this.season,
    this.size = 120,
    this.onEditTap, // onTap을 onEditTap으로 변경
    this.userName = '사용자',
    this.profileImageUrl,
  }) : super(key: key);

  @override
  State<SeasonProfileWidget> createState() => _SeasonProfileWidgetState();
}

class _SeasonProfileWidgetState extends State<SeasonProfileWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  late AnimationController _breathController;

  late Animation<double> _floatingAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();

    // 부드러운 플로팅 애니메이션
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // 탭 스케일 애니메이션
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 글로우 애니메이션
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // 쉬머 효과 애니메이션
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // 호흡 효과 애니메이션
    _breathController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // 애니메이션 설정
    _floatingAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _breathAnimation = Tween<double>(
      begin: 0.95,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 시작
    _startAnimations();
  }

  void _startAnimations() {
    _floatingController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _shimmerController.repeat(reverse: true);
    _breathController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatingAnimation,
        _scaleAnimation,
        _breathAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value * _breathAnimation.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 외부 글로우 효과
                  _buildOuterGlow(),
                  // 메인 프로필 배경
                  _buildMainBackground(),
                  // 쉬머 효과
                  _buildShimmerEffect(),
                  // 프로필 이미지 또는 기본 아바타
                  _buildProfileContent(),
                  // 내부 하이라이트
                  _buildInnerHighlight(),
                  // 편집 아이콘 (프로필 원에 더 가깝게 배치)
                  _buildEditIcon(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOuterGlow() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size + 40, // 20에서 40으로 증가
          height: widget.size + 40, // 20에서 40으로 증가
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getSeasonColor().withOpacity(_glowAnimation.value * 0.4), // 0.2에서 0.4로 증가
                blurRadius: 35, // 25에서 35로 증가
                spreadRadius: 8, // 5에서 8로 증가
              ),
              BoxShadow(
                color: _getSeasonColor().withOpacity(_glowAnimation.value * 0.15), // 0.05에서 0.15로 증가
                blurRadius: 70, // 50에서 70으로 증가
                spreadRadius: 12, // 8에서 12로 증가
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainBackground() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 1.2,
          colors: [
            _getSeasonColor().withOpacity(0.8),
            _getSeasonColor().withOpacity(0.6),
            _getSeasonColor().withOpacity(0.9),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: _getSeasonColor(),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // 0.2에서 0.15로 감소
            blurRadius: 10, // 15에서 10으로 감소
            offset: const Offset(0, 3), // 5에서 3으로 감소
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_shimmerAnimation.value),
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.1, 0.2],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContent() {
    return Container(
      width: widget.size - 16,
      height: widget.size - 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.95),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 8,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: ClipOval(
        child: widget.profileImageUrl != null
            ? Image.network(
          widget.profileImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getSeasonColor().withOpacity(0.2),
            _getSeasonColor().withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: RabbitEmoticon(
          emotion: RabbitEmotion.happy,
          size: widget.size * 0.7, // 0.5에서 0.7로 증가하여 원을 더 꽉 채움
        ),
      ),
    );
  }

  Widget _buildInnerHighlight() {
    return Positioned(
      top: widget.size * 0.15,
      left: widget.size * 0.2,
      child: Container(
        width: widget.size * 0.3,
        height: widget.size * 0.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.6),
              Colors.white.withOpacity(0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditIcon() {
    return Positioned(
      top: widget.size * 0.05,
      right: widget.size * 0.05,
      child: GestureDetector(
        onTap: widget.onEditTap,
        child: Container(
          width: widget.size * 0.18,  // 0.15에서 0.18로 약간 크게
          height: widget.size * 0.18, // 0.15에서 0.18로 약간 크게
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.95),
            border: Border.all(
              color: _getSeasonColor().withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.edit,
            color: _getSeasonColor(),
            size: widget.size * 0.08, // 0.07에서 0.08로 약간 크게
          ),
        ),
      ),
    );
  }

  Color _getSeasonColor() {
    switch (widget.season) {
      case Season.spring:
        return const Color(0xFFFF69B4);
      case Season.summer:
        return const Color(0xFF32CD32);
      case Season.autumn:
        return const Color(0xFFFF4500);
      case Season.winter:
        return const Color(0xFF87CEEB);
    }
  }
}

// 떨어지는 애니메이션 오버레이
class FallingAnimationOverlay extends StatefulWidget {
  final Season season;
  final Widget child;

  const FallingAnimationOverlay({
    Key? key,
    required this.season,
    required this.child,
  }) : super(key: key);

  @override
  State<FallingAnimationOverlay> createState() => _FallingAnimationOverlayState();
}

class _FallingAnimationOverlayState extends State<FallingAnimationOverlay>
    with TickerProviderStateMixin {
  final List<ParticleController> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }

  void _initializeParticles() {
    if (!_shouldShowFallingAnimation()) return;

    final particleCount = 30; // 입자 수를 줄여서 더 자연스럽게
    for (int i = 0; i < particleCount; i++) {
      final particle = ParticleController(
        index: i,
        vsync: this,
        season: widget.season,
      );
      _particles.add(particle);

      // 스태거드 애니메이션 시작
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) {
          particle.start();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final particle in _particles) {
      particle.dispose();
    }
    _particles.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_shouldShowFallingAnimation())
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ParticleSystemPainter(
                  particles: _particles,
                  season: widget.season,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _shouldShowFallingAnimation() {
    return widget.season == Season.spring ||
        widget.season == Season.autumn ||
        widget.season == Season.winter;
  }
}

// 파티클 시스템
class ParticleController {
  final int index;
  final Season season;
  late AnimationController _controller;
  late Animation<double> _fallAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _swayAnimation;
  late Animation<double> _scaleAnimation;

  double x = 0;
  double y = 0;
  double rotation = 0;
  double scale = 1.0;
  double opacity = 1.0;

  ParticleController({
    required this.index,
    required TickerProvider vsync,
    required this.season,
  }) {
    _controller = AnimationController(
      duration: Duration(seconds: 10 + (index % 5)), // 더 긴 지속시간으로 자연스럽게
      vsync: vsync,
    );

    _fallAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 6 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _swayAnimation = Tween<double>(begin: -40.0, end: 40.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(_updateParticle);
  }

  void _updateParticle() {
    final progress = _fallAnimation.value;
    final screenHeight = 1000.0; // 더 긴 화면 높이로 설정
    final screenWidth = 400.0;

    // 시작 위치 계산 (화면 상단 밖에서 시작)
    final startX = (index / 15) * screenWidth + math.sin(index.toDouble()) * 60;

    // 현재 위치 계산 (자연스러운 흔들림)
    x = startX + math.sin(progress * math.pi * 2 + index) * _swayAnimation.value;
    y = progress * (screenHeight + 200) - 100; // 화면 상단 밖에서 시작
    rotation = _rotationAnimation.value;
    scale = _scaleAnimation.value * (0.4 + index % 4 * 0.15);

    // 투명도 계산 (자연스러운 페이드)
    if (progress < 0.05) {
      opacity = progress / 0.05;
    } else if (progress > 0.95) {
      opacity = (1.0 - progress) / 0.05;
    } else {
      opacity = 0.8; // 살짝 투명하게
    }
  }

  void start() {
    // 무한 반복하되, 각 사이클 사이에 랜덤한 지연시간 추가
    _controller.repeat();
  }

  void dispose() {
    _controller.dispose();
  }
}

class ParticleSystemPainter extends CustomPainter {
  final List<ParticleController> particles;
  final Season season;

  ParticleSystemPainter({
    required this.particles,
    required this.season,
  }) : super(repaint: Listenable.merge(particles.map((p) => p._controller)));

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // 화면 밖의 입자는 그리지 않음 (성능 최적화)
      if (particle.opacity <= 0 ||
          particle.y < -100 ||
          particle.y > size.height + 100 ||
          particle.x < -150 ||
          particle.x > size.width + 150) {
        continue;
      }

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      canvas.scale(particle.scale);

      _drawParticleForSeason(canvas, particle, season);

      canvas.restore();
    }
  }

  void _drawParticleForSeason(Canvas canvas, ParticleController particle, Season season) {
    switch (season) {
      case Season.spring:
        _drawBlossom(canvas, particle);
        break;
      case Season.autumn:
        _drawAutumnLeaf(canvas, particle);
        break;
      case Season.winter:
        _drawSnowflake(canvas, particle);
        break;
      case Season.summer:
        break; // 여름에는 파티클 없음
    }
  }

  void _drawBlossom(Canvas canvas, ParticleController particle) {
    final paint = Paint()
      ..color = const Color(0xFFFFB6C1).withOpacity(particle.opacity)
      ..style = PaintingStyle.fill;

    final center = Offset.zero;

    // 꽃잎들 - 크기 증가
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * 2 * math.pi;
      final petalPath = Path();
      final petalCenter = Offset(
        center.dx + math.cos(angle) * 6, // 4에서 6으로 증가
        center.dy + math.sin(angle) * 6, // 4에서 6으로 증가
      );

      petalPath.addOval(Rect.fromCenter(
        center: petalCenter,
        width: 8, // 6에서 8로 증가
        height: 10, // 8에서 10으로 증가
      ));
      canvas.drawPath(petalPath, paint);
    }

    // 꽃 중심 - 크기 증가
    final centerPaint = Paint()
      ..color = const Color(0xFFFFF8DC).withOpacity(particle.opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, centerPaint); // 2에서 3으로 증가
  }

  void _drawAutumnLeaf(Canvas canvas, ParticleController particle) {
    final colors = [
      const Color(0xFFFF4500),
      const Color(0xFFFFD700),
      const Color(0xFFDC143C),
      const Color(0xFFFF8C00),
      const Color(0xFFB22222),
    ];

    final paint = Paint()
      ..color = colors[particle.index % colors.length].withOpacity(particle.opacity)
      ..style = PaintingStyle.fill;

    final path = Path();

    // 더 실감나는 단풍잎 모양 - 크기 증가
    path.moveTo(0, -12); // -10에서 -12로 증가
    path.quadraticBezierTo(-5, -8, -7, -5); // 좌표 조정
    path.quadraticBezierTo(-10, -2, -9, 0); // 좌표 조정
    path.quadraticBezierTo(-7, 2, -5, 5); // 좌표 조정
    path.quadraticBezierTo(-3, 7, 0, 12); // 좌표 조정
    path.quadraticBezierTo(3, 7, 5, 5); // 좌표 조정
    path.quadraticBezierTo(7, 2, 9, 0); // 좌표 조정
    path.quadraticBezierTo(10, -2, 7, -5); // 좌표 조정
    path.quadraticBezierTo(5, -8, 0, -12); // 좌표 조정
    path.close();

    canvas.drawPath(path, paint);

    // 잎맥들 - 크기 조정
    final veinPaint = Paint()
      ..color = paint.color.withOpacity(particle.opacity * 0.8)
      ..strokeWidth = 1.2 // 1에서 1.2로 증가
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(0, -12), const Offset(0, 12), veinPaint);
    canvas.drawLine(const Offset(0, -6), const Offset(-6, -2), veinPaint);
    canvas.drawLine(const Offset(0, -6), const Offset(6, -2), veinPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(-7, 0), veinPaint);
    canvas.drawLine(const Offset(0, 0), const Offset(7, 0), veinPaint);
    canvas.drawLine(const Offset(0, 6), const Offset(-5, 2), veinPaint);
    canvas.drawLine(const Offset(0, 6), const Offset(5, 2), veinPaint);

    // 잎자루 - 크기 조정
    final stemPaint = Paint()
      ..color = const Color(0xFF8B4513).withOpacity(particle.opacity)
      ..strokeWidth = 2.5 // 2에서 2.5로 증가
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(0, 12), const Offset(0, 18), stemPaint);
  }

  void _drawSnowflake(Canvas canvas, ParticleController particle) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(particle.opacity)
      ..strokeWidth = 2.0 // 1.5에서 2.0으로 증가
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 메인 축들 (6개) - 크기 증가
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi;
      final endX = math.cos(angle) * 10; // 8에서 10으로 증가
      final endY = math.sin(angle) * 10; // 8에서 10으로 증가

      canvas.drawLine(Offset.zero, Offset(endX, endY), paint);

      // 내부 가지들 - 크기 증가
      final innerBranchLength = 4.0; // 3.0에서 4.0으로 증가
      final innerBranchX = math.cos(angle) * 6; // 5에서 6으로 증가
      final innerBranchY = math.sin(angle) * 6; // 5에서 6으로 증가

      // 좌측 내부 가지
      final leftInnerX = innerBranchX + math.cos(angle + 2.356) * innerBranchLength;
      final leftInnerY = innerBranchY + math.sin(angle + 2.356) * innerBranchLength;
      canvas.drawLine(Offset(innerBranchX, innerBranchY), Offset(leftInnerX, leftInnerY), paint);

      // 우측 내부 가지
      final rightInnerX = innerBranchX + math.cos(angle - 2.356) * innerBranchLength;
      final rightInnerY = innerBranchY + math.sin(angle - 2.356) * innerBranchLength;
      canvas.drawLine(Offset(innerBranchX, innerBranchY), Offset(rightInnerX, rightInnerY), paint);

      // 외부 가지들 - 크기 증가
      final outerBranchLength = 3.0; // 2.0에서 3.0으로 증가
      final outerBranchX = math.cos(angle) * 9; // 7에서 9로 증가
      final outerBranchY = math.sin(angle) * 9; // 7에서 9로 증가

      // 좌측 외부 가지
      final leftOuterX = outerBranchX + math.cos(angle + 2.356) * outerBranchLength;
      final leftOuterY = outerBranchY + math.sin(angle + 2.356) * outerBranchLength;
      canvas.drawLine(Offset(outerBranchX, outerBranchY), Offset(leftOuterX, leftOuterY), paint);

      // 우측 외부 가지
      final rightOuterX = outerBranchX + math.cos(angle - 2.356) * outerBranchLength;
      final rightOuterY = outerBranchY + math.sin(angle - 2.356) * outerBranchLength;
      canvas.drawLine(Offset(outerBranchX, outerBranchY), Offset(rightOuterX, rightOuterY), paint);
    }

    // 중앙 원
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(particle.opacity * 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 1.5, centerPaint);

    // 중간 고리들
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(particle.opacity * 0.6)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset.zero, 3, ringPaint);
    canvas.drawCircle(Offset.zero, 6, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
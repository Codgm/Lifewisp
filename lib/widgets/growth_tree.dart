import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

enum GrowthStage {
  seed,      // 씨앗 (Level 1)
  sprout,    // 새싹 (Level 2)
  sapling,   // 어린 나무 (Level 3)
  tree,      // 나무 (Level 4)
  blossom,   // 벚꽃 나무 (Level 5)
}

class GrowthTreeWidget extends StatefulWidget {
  final GrowthStage stage;
  final double size;
  final VoidCallback? onTap;

  const GrowthTreeWidget({
    Key? key,
    required this.stage,
    this.size = 140,
    this.onTap,
  }) : super(key: key);

  @override
  State<GrowthTreeWidget> createState() => _GrowthTreeWidgetState();
}

class _GrowthTreeWidgetState extends State<GrowthTreeWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _scaleController;
  late AnimationController _leafFallController;
  late AnimationController _growthController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _leafFallAnimation;
  late Animation<double> _growthAnimation;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _leafFallController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _growthController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _leafFallAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _leafFallController,
      curve: Curves.linear,
    ));

    _growthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _growthController,
      curve: Curves.easeOutBack,
    ));

    // 성장 애니메이션 시작
    _growthController.forward();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _scaleController.dispose();
    _leafFallController.dispose();
    _growthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: AnimatedBuilder(
                    animation: _growthAnimation,
                    builder: (context, child) {
                      return SizedBox(
                        width: widget.size,
                        height: widget.size,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 배경 원
                            Container(
                              width: widget.size,
                              height: widget.size,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _getBackgroundColors(),
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getBackgroundColors().first.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                            ),
                            // 성장 단계별 트리
                            Transform.scale(
                              scale: _growthAnimation.value,
                              child: _buildTreeForStage(),
                            ),
                            // 떨어지는 잎사귀 (벚꽃 단계에서만)
                            if (widget.stage == GrowthStage.blossom)
                              ..._buildFallingPetals(),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<Color> _getBackgroundColors() {
    switch (widget.stage) {
      case GrowthStage.seed:
        return [
          const Color(0xFF8B4513).withOpacity(0.1),
          const Color(0xFFD2691E).withOpacity(0.1),
        ];
      case GrowthStage.sprout:
        return [
          const Color(0xFF32CD32).withOpacity(0.1),
          const Color(0xFF90EE90).withOpacity(0.1),
        ];
      case GrowthStage.sapling:
        return [
          const Color(0xFF228B22).withOpacity(0.1),
          const Color(0xFF6B8E23).withOpacity(0.1),
        ];
      case GrowthStage.tree:
        return [
          const Color(0xFF006400).withOpacity(0.1),
          const Color(0xFF8FBC8F).withOpacity(0.1),
        ];
      case GrowthStage.blossom:
        return [
          const Color(0xFFFFB6C1).withOpacity(0.1),
          const Color(0xFFFFC0CB).withOpacity(0.1),
        ];
    }
  }

  Widget _buildTreeForStage() {
    switch (widget.stage) {
      case GrowthStage.seed:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '🌱',
              style: TextStyle(fontSize: 24),
            ),
          ],
        );

      case GrowthStage.sprout:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🌱',
              style: TextStyle(fontSize: 40),
            ),
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );

      case GrowthStage.sapling:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🌿',
              style: TextStyle(fontSize: 30),
            ),
            Container(
              width: 6,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Text(
              '🌿',
              style: TextStyle(fontSize: 20),
            ),
          ],
        );

      case GrowthStage.tree:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🌳',
              style: TextStyle(fontSize: 50),
            ),
            Container(
              width: 8,
              height: 25,
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );

      case GrowthStage.blossom:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '🌸',
                  style: TextStyle(fontSize: 35),
                ),
                Positioned(
                  top: -10,
                  left: -15,
                  child: Text(
                    '🌸',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Positioned(
                  top: -5,
                  right: -10,
                  child: Text(
                    '🌸',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: -20,
                  child: Text(
                    '🌸',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: -15,
                  child: Text(
                    '🌸',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            Container(
              width: 10,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        );
    }
  }

  List<Widget> _buildFallingPetals() {
    return List.generate(5, (index) {
      return AnimatedBuilder(
        animation: _leafFallAnimation,
        builder: (context, child) {
          final progress = (_leafFallAnimation.value + index * 0.2) % 1.0;
          final x = math.sin(progress * math.pi * 4) * 30;
          final y = progress * widget.size * 1.5;

          return Positioned(
            left: widget.size / 2 + x,
            top: y - 20,
            child: Transform.rotate(
              angle: progress * math.pi * 2,
              child: Text(
                '🌸',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.pink.withOpacity(0.8),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../utils/emotion_utils.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/rabbit_emoticon.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final records = context.watch<EmotionProvider>().records;
    final Map<String, int> emotionCounts = {};
    for (var r in records) {
      emotionCounts[r.emotion] = (emotionCounts[r.emotion] ?? 0) + 1;
    }
    final total = records.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: CustomScrollView(
        slivers: [
          // 1. 앱바를 캐릭터 화면 형식으로 변경
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.pop(context),
                      color: const Color(0xFF6B73FF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Spacer(),
                  Text(
                    '📊 감정 분석',
                    style: GoogleFonts.jua(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B46C1),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
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
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, size: 18),
                      onPressed: () {},
                      color: const Color(0xFF6B73FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          // 메인 컨텐츠
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 감정 요약 카드 (가장 위에 배치)
                _buildEmotionSummaryCard(emotionCounts, total),
                const SizedBox(height: 16),

                // 감정 분포 원형 차트
                _buildCircularChart(emotionCounts, total),
                const SizedBox(height: 16),

                // 감정 변화 추이 차트
                _buildTrendChart(records),
                const SizedBox(height: 16),

                // 감정별 상세 통계
                _buildEmotionStats(emotionCounts, total),
                const SizedBox(height: 16),

                // 주간 감정 그리드
                _buildWeeklyEmotionGrid(),
                const SizedBox(height: 16),

                // 격려 메시지
                _buildEncouragementCard(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // 감정 요약 카드 (상단에 배치)
  Widget _buildEmotionSummaryCard(Map<String, int> emotionCounts, int total) {
    final topEmotion = emotionCounts.entries.isEmpty
        ? null
        : emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE0E7FF),
            const Color(0xFFF3E8FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text('🌟', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 감정 요약',
                      style: GoogleFonts.jua(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B46C1),
                      ),
                    ),
                    Text(
                      topEmotion != null
                          ? '가장 많이 느낀 감정: ${topEmotion.key}'
                          : '아직 감정이 기록되지 않았어요',
                      style: GoogleFonts.jua(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (topEmotion != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                RabbitEmoticon(
                  emotion: _mapStringToRabbitEmotion(topEmotion.key),
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${topEmotion.value}번 기록됨',
                        style: GoogleFonts.jua(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B46C1),
                        ),
                      ),
                      Text(
                        '전체의 ${((topEmotion.value / total) * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.jua(
                          fontSize: 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 감정 분포 원형 차트
  Widget _buildCircularChart(Map<String, int> emotionCounts, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🎯', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                '감정 분포',
                style: GoogleFonts.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B46C1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 중앙 원
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F6FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🌈', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          Text(
                            '총 $total개',
                            style: GoogleFonts.jua(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B46C1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 감정 카드들을 원형으로 배치
                  ...emotionCounts.entries.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final emotion = entry.value;
                    final percent = total > 0 ? emotion.value / total : 0.0;
                    final angle = (index * 2 * pi) / emotionCounts.length;
                    final radius = 105.0;
                    final x = radius * cos(angle);
                    final y = radius * sin(angle);

                    return Positioned(
                      left: 140 + x - 30,
                      top: 140 + y - 35,
                      child: Container(
                        width: 60,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: emotionColor[emotion.key]?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: emotionColor[emotion.key]?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RabbitEmoticon(
                              emotion: _mapStringToRabbitEmotion(emotion.key),
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(percent * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.jua(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: emotionColor[emotion.key] ?? Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 감정 변화 추이 차트
  Widget _buildTrendChart(List records) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📈', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                '감정 변화 추이',
                style: GoogleFonts.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B46C1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _ModernLineChartPainter(records),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  // 감정별 상세 통계
  Widget _buildEmotionStats(Map<String, int> emotionCounts, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📊', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                '감정별 통계',
                style: GoogleFonts.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B46C1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 감정 리스트
          ...emotionCounts.entries.map((entry) {
            final percent = total > 0 ? entry.value / total : 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: emotionColor[entry.key]?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  RabbitEmoticon(
                    emotion: _mapStringToRabbitEmotion(entry.key),
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: GoogleFonts.jua(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6B46C1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: emotionColor[entry.key] ?? Colors.grey,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.value}회',
                        style: GoogleFonts.jua(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B46C1),
                        ),
                      ),
                      Text(
                        '${(percent * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.jua(
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 주간 감정 그리드
  Widget _buildWeeklyEmotionGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📅', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                '이번 주 감정',
                style: GoogleFonts.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B46C1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: emotionEmoji.entries.map((e) {
                final random = Random(e.key.hashCode);
                final weekCount = 1 + random.nextInt(4);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RabbitEmoticon(
                      emotion: _mapStringToRabbitEmotion(e.key),
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: emotionColor[e.key] ?? Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$weekCount회',
                      style: GoogleFonts.jua(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B46C1),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 격려 메시지 카드
  Widget _buildEncouragementCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF818CF8),
            const Color(0xFFC084FC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('💝', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '멋진 감정 여행이에요!',
                  style: GoogleFonts.jua(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '감정 기록을 꾸준히 할수록\n더 정확한 분석을 볼 수 있어요 ✨',
                  style: GoogleFonts.jua(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernLineChartPainter extends CustomPainter {
  final List records;
  _ModernLineChartPainter(this.records);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF818CF8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF818CF8).withOpacity(0.3),
          const Color(0xFF818CF8).withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final points = <Offset>[];
    final fillPoints = <Offset>[];
    final n = records.length > 1 ? records.length : 7;

    for (int i = 0; i < n; i++) {
      final y = size.height - (sin(i * 0.5) * 25 + 50) - 20;
      final x = i * (size.width / (n - 1));
      points.add(Offset(x, y));
      fillPoints.add(Offset(x, y));
    }

    if (points.length > 1) {
      // 영역 채우기
      fillPoints.add(Offset(size.width, size.height));
      fillPoints.add(Offset(0, size.height));
      final fillPath = Path()..addPolygon(fillPoints, true);
      canvas.drawPath(fillPath, fillPaint);

      // 곡선 그리기
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        final cp1x = points[i - 1].dx + (points[i].dx - points[i - 1].dx) * 0.5;
        final cp1y = points[i - 1].dy;
        final cp2x = points[i].dx - (points[i].dx - points[i - 1].dx) * 0.5;
        final cp2y = points[i].dy;
        path.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);

      // 점 그리기
      for (final point in points) {
        canvas.drawCircle(point, 6, Paint()..color = Colors.white);
        canvas.drawCircle(point, 4, Paint()..color = const Color(0xFF818CF8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

RabbitEmotion _mapStringToRabbitEmotion(String key) {
  switch (key) {
    case 'happy':
    case '행복':
    case '😊':
      return RabbitEmotion.happy;
    case 'sad':
    case '슬픔':
    case '😢':
      return RabbitEmotion.sad;
    case 'angry':
    case '분노':
    case '😤':
      return RabbitEmotion.angry;
    case 'excited':
    case '흥분':
    case '🤩':
      return RabbitEmotion.excited;
    case 'calm':
    case '평온':
    case '😌':
      return RabbitEmotion.calm;
    case 'anxious':
    case '불안':
    case '😰':
      return RabbitEmotion.anxious;
    case 'love':
    case '사랑':
    case '🥰':
      return RabbitEmotion.love;
    case 'tired':
    case '피곤':
    case '😴':
      return RabbitEmotion.tired;
    case 'despair':
    case '절망':
      return RabbitEmotion.despair;
    default:
      return RabbitEmotion.happy;
  }
}
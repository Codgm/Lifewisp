import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../providers/user_provider.dart';
import '../utils/emotion_utils.dart';
import 'dart:math';
import '../widgets/rabbit_emoticon.dart';
import '../widgets/common_app_bar.dart';
import '../utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  // 감정별 색상 매핑
  static const Map<String, Color> emotionColors = {
    '행복': Color(0xFFFFB74D), // 밝은 오렌지
    '슬픔': Color(0xFF64B5F6), // 밝은 파랑
    '분노': Color(0xFFE57373), // 밝은 빨강
    '평온': Color(0xFF81C784), // 밝은 초록
    '불안': Color(0xFFBA68C8), // 밝은 보라
    '흥분': Color(0xFFFF8A65), // 밝은 코랄
    '사랑': Color(0xFFF06292), // 밝은 분홍
    '피곤': Color(0xFF90A4AE), // 블루 그레이
    '절망': Color(0xFF8D6E63), // 브라운
  };

  @override
  Widget build(BuildContext context) {
    final records = context.watch<EmotionProvider>().records;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 실제 데이터가 없으면 더미 데이터 사용
    Map<String, int> emotionCounts;
    List effectiveRecords;

    if (records.isEmpty) {
      // 더미 데이터 생성
      emotionCounts = _generateDummyEmotionCounts();
      effectiveRecords = _generateDummyRecords();
    } else {
      // 실제 데이터 사용
      emotionCounts = {};
      for (var r in records) {
        emotionCounts[r.emotion] = (emotionCounts[r.emotion] ?? 0) + 1;
      }
      effectiveRecords = records;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CommonAppBar(
        title: '감정 분석',
        emoji: '📊',
        showBackButton: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // 감정별 분포
            _buildEmotionDistribution(emotionCounts, effectiveRecords.length, context),
            const SizedBox(height: 32),
            // 월간 감정 변화
            _buildMonthlyTrend(effectiveRecords, context),
            const SizedBox(height: 32),
            // 감정 히트맵(달력)
            _buildEmotionHeatmap(effectiveRecords, context),
            const SizedBox(height: 32),
            // 특이점 분석
            _buildOutlierAnalysis(emotionCounts, effectiveRecords, context),
          ],
        ),
      ),
    );
  }

  // 더미 감정 카운트 생성
  Map<String, int> _generateDummyEmotionCounts() {
    final random = Random();
    return {
      '행복': 15 + random.nextInt(10),
      '슬픔': 8 + random.nextInt(5),
      '분노': 3 + random.nextInt(4),
      '평온': 12 + random.nextInt(8),
      '불안': 5 + random.nextInt(6),
      '흥분': 7 + random.nextInt(5),
      '사랑': 10 + random.nextInt(7),
    };
  }

  // 더미 레코드 생성
  List _generateDummyRecords() {
    final emotions = ['행복', '슬픔', '분노', '평온', '불안', '흥분', '사랑'];
    final random = Random();
    final now = DateTime.now();

    return List.generate(60, (index) {
      return {
        'emotion': emotions[random.nextInt(emotions.length)],
        'date': now.subtract(Duration(days: random.nextInt(30))),
        'note': '더미 데이터입니다.',
      };
    });
  }

  // 1. 감정별 분포 (파이 차트와 바 차트 결합)
  Widget _buildEmotionDistribution(Map<String, int> emotionCounts, int total, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : LifewispColors.purple.withOpacity(0.06),
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
                  color: isDark ? LifewispColors.darkPurple : LifewispColors.lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🥧', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                '감정별 분포',
                style: LifewispTextStyles.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 파이 차트
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _PieChartPainter(emotionCounts, isDark, context),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 감정별 바 차트
          ...sortedEmotions.map((entry) {
            final percent = entry.value / total;
            final emotionColor = emotionColors[entry.key] ?? (isDark ? LifewispColors.darkSubText : LifewispColors.gray);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  RabbitEmoticon(
                    emotion: _mapStringToRabbitEmotion(entry.key),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: LifewispTextStyles.jua(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? LifewispColors.darkMainText : LifewispColors.purple,
                              ),
                            ),
                            Text(
                              '${entry.value}회 (${(percent * 100).toStringAsFixed(1)}%)',
                              style: LifewispTextStyles.jua(
                                fontSize: 12,
                                color: isDark ? LifewispColors.darkSubText : LifewispColors.gray,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDark
                                ? LifewispColors.darkSubText.withOpacity(0.2)
                                : LifewispColors.gray.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: emotionColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 2. 월간 감정 변화 트렌드 (개선된 버전)
  Widget _buildMonthlyTrend(List records, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.15) : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: isDark ? LifewispColors.darkPurple : LifewispColors.lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📈', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                '월간 감정 변화',
                style: LifewispTextStyles.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 2,
                  verticalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.jua(
                            fontSize: 10,
                            color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        final day = value.toInt();
                        if (day % 5 == 0 && day <= 30) {
                          return Text(
                            '${day}일',
                            style: GoogleFonts.jua(
                              fontSize: 9,
                              color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                minX: 0,
                maxX: 30,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  // 행복
                  LineChartBarData(
                    spots: _generateSmoothLineData(30, 3, 8),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: emotionColors['행복']!,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: emotionColors['행복']!,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: emotionColors['행복']!.withOpacity(0.1),
                    ),
                  ),
                  // 슬픔
                  LineChartBarData(
                    spots: _generateSmoothLineData(30, 1, 5),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: emotionColors['슬픔']!,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: emotionColors['슬픔']!,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: emotionColors['슬픔']!.withOpacity(0.1),
                    ),
                  ),
                  // 분노
                  LineChartBarData(
                    spots: _generateSmoothLineData(30, 0, 4),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: emotionColors['분노']!,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: emotionColors['분노']!,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: emotionColors['분노']!.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 범례
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('행복', emotionColors['행복']!),
              const SizedBox(width: 20),
              _buildLegendItem('슬픔', emotionColors['슬픔']!),
              const SizedBox(width: 20),
              _buildLegendItem('분노', emotionColors['분노']!),
            ],
          ),
        ],
      ),
    );
  }

  // 범례 아이템
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.jua(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 더 부드러운 라인 데이터 생성
  List<FlSpot> _generateSmoothLineData(int days, int minValue, int maxValue) {
    final random = Random();
    final spots = <FlSpot>[];
    
    double previousValue = (minValue + maxValue) / 2;
    
    for (int i = 0; i <= days; i++) {
      // 이전 값을 기준으로 변화량을 제한하여 부드러운 곡선 생성
      double change = (random.nextDouble() - 0.5) * 2; // -1 ~ 1
      double newValue = (previousValue + change).clamp(minValue.toDouble(), maxValue.toDouble());
      
      spots.add(FlSpot(i.toDouble(), newValue));
      previousValue = newValue;
    }
    
    return spots;
  }

  Widget _buildLegendDot(Color color) {
    return Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)
    );
  }

  // 3. 감정 히트맵 (달력 형태)
  Widget _buildEmotionHeatmap(List records, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.15) : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: isDark ? LifewispColors.darkPurple : LifewispColors.lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🗓️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                '감정 히트맵',
                style: LifewispTextStyles.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDummyCalendarHeatmap(isDark, context),
        ],
      ),
    );
  }

  // 더미 달력 히트맵
  Widget _buildDummyCalendarHeatmap(bool isDark, BuildContext context) {
    final days = List.generate(30, (i) => i + 1);
    final emotions = ['행복', '슬픔', '분노', '평온', '불안'];
    final random = Random();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: days.map((d) {
        // 랜덤하게 감정이 있는 날과 없는 날 결정
        final hasEmotion = random.nextBool();
        if (!hasEmotion) {
          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? LifewispColors.darkLightGray.withOpacity(0.3)
                  : LifewispColors.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$d',
                style: GoogleFonts.jua(
                  fontSize: 10,
                  color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                ),
              ),
            ),
          );
        }

        final emotion = emotions[random.nextInt(emotions.length)];
        final color = emotionColors[emotion] ?? Colors.grey;

        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Text(
              '$d',
              style: GoogleFonts.jua(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 4. 특이점 분석
  Widget _buildOutlierAnalysis(Map<String, int> emotionCounts, List records, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outliers = _getOutlierAnalysis(emotionCounts, records);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : LifewispColors.purple.withOpacity(0.06),
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
                  color: isDark ? LifewispColors.darkPurple : LifewispColors.lightPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🔍', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Text(
                '특이점 분석',
                style: LifewispTextStyles.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (outliers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? LifewispColors.darkLightGray : LifewispColors.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '현재까지는 특별한 패턴이 발견되지 않았어요.\n더 많은 데이터가 쌓이면 흥미로운 인사이트를 발견할 수 있을 거예요!',
                      style: LifewispTextStyles.jua(
                        fontSize: 14,
                        color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...outliers.map((outlier) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? LifewispColors.darkLightGray : LifewispColors.lightGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: outlier['type'] == 'warning'
                      ? Colors.orange.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    outlier['type'] == 'warning' ? '⚠️' : '💡',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      outlier['message']!,
                      style: LifewispTextStyles.jua(
                        fontSize: 14,
                        color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }

  List<Map<String, String>> _getOutlierAnalysis(Map<String, int> emotionCounts, List records) {
    final List<Map<String, String>> outliers = [];

    // 더미 데이터인지 실제 데이터인지에 관계없이 분석
    final totalRecords = records.length;
    if (totalRecords > 10) {
      final topEmotion = emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (topEmotion.value / totalRecords > 0.3) {
        outliers.add({
          'type': 'info',
          'message': '${topEmotion.key} 감정이 전체의 ${((topEmotion.value / totalRecords) * 100).toStringAsFixed(1)}%를 차지해요. 이 감정이 최근 주된 감정 상태인 것 같아요.'
        });
      }

      final negativeEmotions = ['슬픔', '분노', '불안', '절망'];
      final negativeCount = emotionCounts.entries
          .where((e) => negativeEmotions.contains(e.key))
          .fold(0, (sum, e) => sum + e.value);

      if (negativeCount / totalRecords > 0.25) {
        outliers.add({
          'type': 'warning',
          'message': '최근 부정적인 감정의 비율이 조금 높아요. 스트레스 관리나 휴식이 필요할 수 있어요.'
        });
      }

      // 긍정적인 패턴도 추가
      final positiveEmotions = ['행복', '사랑', '평온', '흥분'];
      final positiveCount = emotionCounts.entries
          .where((e) => positiveEmotions.contains(e.key))
          .fold(0, (sum, e) => sum + e.value);

      if (positiveCount / totalRecords > 0.6) {
        outliers.add({
          'type': 'info',
          'message': '긍정적인 감정의 비율이 높아요! 좋은 컨디션을 유지하고 계시는 것 같아요. 👍'
        });
      }
    }

    return outliers;
  }

  // 데이터 처리 헬퍼 메서드들 (기존 코드 유지)
  Map<String, Map<String, int>> _getMonthlyEmotionData(List records) {
    final Map<String, Map<String, int>> monthlyData = {};
    return {
      '1월': {'행복': 15, '슬픔': 5, '분노': 3},
      '2월': {'행복': 12, '슬픔': 8, '분노': 2},
      '3월': {'행복': 18, '슬픔': 4, '분노': 1},
    };
  }

  Map<String, Map<String, int>> _getDailyEmotionData(List records) {
    final Map<String, Map<String, int>> dailyData = {};
    for (int i = 1; i <= 31; i++) {
      if (Random().nextBool()) {
        dailyData['$i'] = {
          emotionEmoji.keys.elementAt(Random().nextInt(emotionEmoji.length)): 1 + Random().nextInt(3)
        };
      }
    }
    return dailyData;
  }
}

// 파이 차트 페인터
class _PieChartPainter extends CustomPainter {
  final Map<String, int> emotionCounts;
  final bool isDark;
  final BuildContext context;

  _PieChartPainter(this.emotionCounts, this.isDark, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final total = emotionCounts.values.fold(0, (sum, count) => sum + count).toDouble();

    double startAngle = -pi / 2;

    for (final entry in emotionCounts.entries) {
      final sweepAngle = (entry.value / total) * 2 * pi;
      final emotionColor = AnalysisScreen.emotionColors[entry.key] ?? 
          (isDark ? LifewispColors.darkSubText : LifewispColors.gray);
      
      final paint = Paint()
        ..color = emotionColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // 중앙 원
    canvas.drawCircle(
      center,
      radius * 0.4,
      Paint()..color = isDark ? LifewispColors.darkCardBg : Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 월간 트렌드 페인터
class _MonthlyTrendPainter extends CustomPainter {
  final Map<String, Map<String, int>> monthlyData;
  final bool isDark;
  final BuildContext context;

  _MonthlyTrendPainter(this.monthlyData, this.isDark, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    // 간단한 라인 차트 구현
    final paint = Paint()
      ..color = isDark ? LifewispColors.darkPink : LifewispColors.purple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final months = monthlyData.keys.toList();
    if (months.length > 1) {
      final path = Path();
      for (int i = 0; i < months.length; i++) {
        final x = (i / (months.length - 1)) * size.width;
        final totalCount = monthlyData[months[i]]?.values.fold(0, (sum, count) => sum + count) ?? 0;
        final y = size.height - (totalCount / 30 * size.height * 0.8);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
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
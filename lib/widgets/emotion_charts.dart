import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/emotion_record.dart';
import '../utils/theme.dart';

class EmotionCharts {
  /// 감정 분포 파이 차트
  static Widget buildEmotionDistributionChart(
    Map<String, int> emotionCounts,
    bool isDark,
  ) {
    if (emotionCounts.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? LifewispColors.darkCardBg.withOpacity(0.5) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            '기록된 감정이 없습니다',
            style: isDark ? LifewispTextStyles.darkSubtitle : LifewispTextStyles.subtitle,
          ),
        ),
      );
    }

    final total = emotionCounts.values.fold(0, (sum, count) => sum + count);
    final sections = <PieChartSectionData>[];
    
    final colors = [
      const Color(0xFFFF6B6B), // 빨강
      const Color(0xFF4ECDC4), // 청록
      const Color(0xFF45B7D1), // 파랑
      const Color(0xFF96CEB4), // 초록
      const Color(0xFFFFEAA7), // 노랑
      const Color(0xFFDDA0DD), // 보라
      const Color(0xFFFFB6C1), // 핑크
      const Color(0xFFFFA07A), // 주황
    ];

    int colorIndex = 0;
    emotionCounts.forEach((emotion, count) {
      final percentage = (count / total * 100);
      final emotionNames = {
        'happy': '행복',
        'sad': '슬픔',
        'angry': '분노',
        'anxious': '불안',
        'tired': '피곤',
        'love': '사랑',
        'calm': '차분',
        'excited': '신남',
        'confidence': '자신감',
      };

      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: emotionCounts.entries.map((entry) {
                final emotionNames = {
                  'happy': '행복',
                  'sad': '슬픔',
                  'angry': '분노',
                  'anxious': '불안',
                  'tired': '피곤',
                  'love': '사랑',
                  'calm': '차분',
                  'excited': '신남',
                  'confidence': '자신감',
                };
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[emotionCounts.keys.toList().indexOf(entry.key) % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          emotionNames[entry.key] ?? entry.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 주간 감정 패턴 라인 차트
  static Widget buildWeeklyPatternChart(List<EmotionRecord> records, bool isDark) {
    if (records.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? LifewispColors.darkCardBg.withOpacity(0.5) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            '기록된 감정이 없습니다',
            style: isDark ? LifewispTextStyles.darkSubtitle : LifewispTextStyles.subtitle,
          ),
        ),
      );
    }

    // 최근 7일 데이터 준비
    final now = DateTime.now();
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayRecords = records.where((r) =>
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day).toList();
      
      if (dayRecords.isEmpty) return 0.0;
      
      // 긍정적 감정 비율 계산
      final positiveEmotions = ['happy', 'love', 'calm', 'excited', 'confidence'];
      final positiveCount = dayRecords.where((r) => positiveEmotions.contains(r.emotion)).length;
      return (positiveCount / dayRecords.length * 100);
    });

    final spots = weekData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 20,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const days = ['월', '화', '수', '목', '금', '토', '일'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Text(
                      days[value.toInt()],
                      style: TextStyle(
                        color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
            ),
          ),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
                  isDark ? LifewispColors.darkSecondary : LifewispColors.secondary,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
                    strokeWidth: 2,
                    strokeColor: isDark ? LifewispColors.darkCardBg : Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    (isDark ? LifewispColors.darkPrimary : LifewispColors.primary).withOpacity(0.3),
                    (isDark ? LifewispColors.darkSecondary : LifewispColors.secondary).withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 시간대별 감정 분석 바 차트
  static Widget buildTimeOfDayChart(Map<String, dynamic> timePattern, bool isDark) {
    final dominantEmotions = timePattern['dominantEmotions'] as Map<String, String>;
    final recordCounts = timePattern['recordCounts'] as Map<String, int>;
    
    if (dominantEmotions.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? LifewispColors.darkCardBg.withOpacity(0.5) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            '시간대별 데이터가 없습니다',
            style: isDark ? LifewispTextStyles.darkSubtitle : LifewispTextStyles.subtitle,
          ),
        ),
      );
    }

    final timeSlots = ['새벽 (00-06)', '오전 (06-12)', '오후 (12-18)', '저녁 (18-24)'];
    final bars = timeSlots.map((slot) {
      final count = recordCounts[slot] ?? 0;
      final emotion = dominantEmotions[slot] ?? 'none';
      
      final emotionColors = {
        'happy': const Color(0xFFFF6B6B),
        'sad': const Color(0xFF4ECDC4),
        'angry': const Color(0xFFFFEAA7),
        'anxious': const Color(0xFFDDA0DD),
        'tired': const Color(0xFF96CEB4),
        'love': const Color(0xFFFFB6C1),
        'calm': const Color(0xFF45B7D1),
        'excited': const Color(0xFFFFA07A),
        'confidence': const Color(0xFF9370DB),
        'none': Colors.grey,
      };

      return BarChartGroupData(
        x: timeSlots.indexOf(slot),
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: emotionColors[emotion] ?? Colors.grey,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: recordCounts.values.fold(0, (max, count) => count > max ? count : max).toDouble() + 1,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const labels = ['새벽', '오전', '오후', '저녁'];
                  if (value.toInt() >= 0 && value.toInt() < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[value.toInt()],
                        style: TextStyle(
                          color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
            ),
          ),
          barGroups: bars,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  /// 감정 안정성 게이지 차트
  static Widget buildEmotionStabilityGauge(double stability, bool isDark) {
    final percentage = (stability * 100).toInt();
    
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '감정 안정성',
            style: isDark ? LifewispTextStyles.darkTitle : LifewispTextStyles.title,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: stability,
                    strokeWidth: 12,
                    backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStabilityColor(stability, isDark),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
                      ),
                    ),
                    Text(
                      _getStabilityText(stability),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _getStabilityColor(double stability, bool isDark) {
    if (stability >= 0.7) return isDark ? LifewispColors.darkGreen : LifewispColors.green;
    if (stability >= 0.4) return isDark ? LifewispColors.darkYellow : LifewispColors.yellow;
    return isDark ? LifewispColors.darkRed : LifewispColors.red;
  }

  static String _getStabilityText(double stability) {
    if (stability >= 0.7) return '안정적';
    if (stability >= 0.4) return '보통';
    return '불안정';
  }
} 
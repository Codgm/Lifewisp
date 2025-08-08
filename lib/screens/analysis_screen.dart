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
    'happy': Color(0xFFFFB74D), // 밝은 오렌지
    'sad': Color(0xFF64B5F6), // 밝은 파랑
    'angry': Color(0xFFE57373), // 밝은 빨강
    'calm': Color(0xFF81C784), // 밝은 초록
    'anxious': Color(0xFFBA68C8), // 밝은 보라
    'excited': Color(0xFFFF8A65), // 밝은 코랄
    'love': Color(0xFFF06292), // 밝은 분홍
    'tired': Color(0xFF90A4AE), // 블루 그레이
    'despair': Color(0xFF8D6E63), // 브라운
    'confidence': Color(0xFFFFD54F), // 밝은 노랑
  };

  // 감정명 한글 매핑
  static const Map<String, String> emotionKoreanNames = {
    'happy': '행복',
    'sad': '슬픔',
    'angry': '분노',
    'calm': '평온',
    'anxious': '불안',
    'excited': '흥분',
    'love': '사랑',
    'tired': '피곤',
    'despair': '절망',
    'confidence': '자신감',
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
      print('분석 화면: 실제 데이터 없음, 더미 데이터 사용 (${effectiveRecords.length}개)');
      print('더미 감정 분포: $emotionCounts');
    } else {
      // 실제 데이터 사용
      emotionCounts = {};
      for (var r in records) {
        emotionCounts[r.emotion] = (emotionCounts[r.emotion] ?? 0) + 1;
      }
      effectiveRecords = records;
      print('분석 화면: 실제 데이터 사용 (${effectiveRecords.length}개)');
      print('실제 감정 분포: $emotionCounts');
      
      // 실제 데이터의 감정별 상세 정보 출력
      for (var record in records.take(5)) {
        print('실제 기록: ${record.date} - ${record.emotion}');
      }
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
      'happy': 12 + random.nextInt(8),
      'calm': 10 + random.nextInt(6),
      'love': 8 + random.nextInt(5),
      'excited': 6 + random.nextInt(4),
      'confidence': 5 + random.nextInt(4),
      'sad': 4 + random.nextInt(3),
      'tired': 3 + random.nextInt(3),
      'anxious': 2 + random.nextInt(2),
      'angry': 1 + random.nextInt(2),
      'despair': 1 + random.nextInt(1),
    };
  }

  // 더미 레코드 생성
  List _generateDummyRecords() {
    final emotions = ['happy', 'sad', 'angry', 'calm', 'anxious', 'excited', 'love', 'tired', 'despair', 'confidence'];
    final random = Random();
    final now = DateTime.now();

    // 더 현실적인 감정 분포 (긍정적 감정이 조금 더 많음)
    final emotionWeights = {
      'happy': 0.25,
      'calm': 0.20,
      'love': 0.15,
      'excited': 0.10,
      'confidence': 0.10,
      'sad': 0.08,
      'tired': 0.06,
      'anxious': 0.04,
      'angry': 0.01,
      'despair': 0.01,
    };

    return List.generate(45, (index) {
      // 가중치 기반 감정 선택
      double rand = random.nextDouble();
      String selectedEmotion = 'happy'; // 기본값
      
      double cumulativeWeight = 0.0;
      for (var entry in emotionWeights.entries) {
        cumulativeWeight += entry.value;
        if (rand <= cumulativeWeight) {
          selectedEmotion = entry.key;
          break;
        }
      }

      return {
        'emotion': selectedEmotion,
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
                              emotionKoreanNames[entry.key] ?? entry.key,
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

  // 2. 월간 감정 변화 트렌드 (실제 데이터 연동)
  Widget _buildMonthlyTrend(List records, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyEmotionData = _getDailyEmotionData(records);

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
                lineBarsData: _generateEmotionLineData(dailyEmotionData),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 범례 - 상위 감정들만 표시
          _buildDynamicLegend(dailyEmotionData),
        ],
      ),
    );
  }

  // 실제 데이터에서 일별 감정 데이터 추출
  Map<int, Map<String, int>> _getDailyEmotionData(List records) {
    final Map<int, Map<String, int>> dailyData = {};
    final now = DateTime.now();

    print('일별 감정 데이터 추출 시작: ${records.length}개 기록');

    for (var record in records) {
      DateTime recordDate;
      String emotion;

      if (record is Map) {
        recordDate = record['date'] ?? now;
        emotion = record['emotion'] ?? 'happy';
        print('더미 데이터 처리: ${recordDate} - $emotion');
      } else {
        // EmotionRecord 객체인 경우
        recordDate = record.date;
        emotion = record.emotion;
        print('실제 데이터 처리: ${recordDate} - $emotion');
      }

      final daysDiff = now.difference(recordDate).inDays;
      if (daysDiff >= 0 && daysDiff <= 30) {
        final day = 30 - daysDiff;
        dailyData[day] ??= {};
        dailyData[day]![emotion] = (dailyData[day]![emotion] ?? 0) + 1;
      }
    }

    print('일별 감정 데이터 결과: $dailyData');
    return dailyData;
  }

  // 감정별 라인 데이터 생성
  List<LineChartBarData> _generateEmotionLineData(Map<int, Map<String, int>> dailyData) {
    final allEmotions = <String>{};
    for (var dayData in dailyData.values) {
      allEmotions.addAll(dayData.keys);
    }

    // 상위 3개 감정만 표시
    final emotionTotals = <String, int>{};
    for (var emotion in allEmotions) {
      emotionTotals[emotion] = dailyData.values
          .fold(0, (sum, dayData) => sum + (dayData[emotion] ?? 0));
    }

    final topEmotions = emotionTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final selectedEmotions = topEmotions.take(3).map((e) => e.key).toList();

    return selectedEmotions.map((emotion) {
      final spots = <FlSpot>[];

      for (int day = 0; day <= 30; day++) {
        final count = dailyData[day]?[emotion] ?? 0;
        spots.add(FlSpot(day.toDouble(), count.toDouble()));
      }

      final color = emotionColors[emotion] ?? Colors.grey;

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: color,
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 3,
              color: color,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: color.withOpacity(0.1),
        ),
      );
    }).toList();
  }

  // 동적 범례 생성
  Widget _buildDynamicLegend(Map<int, Map<String, int>> dailyData) {
    final emotionTotals = <String, int>{};
    for (var dayData in dailyData.values) {
      for (var entry in dayData.entries) {
        emotionTotals[entry.key] = (emotionTotals[entry.key] ?? 0) + entry.value;
      }
    }

    final topEmotions = emotionTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final selectedEmotions = topEmotions.take(3).toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      children: selectedEmotions.map((entry) {
        final color = emotionColors[entry.key] ?? Colors.grey;
        return _buildLegendItem(entry.key, color);
      }).toList(),
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
          emotionKoreanNames[label] ?? label,
          style: GoogleFonts.jua(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)
    );
  }

  // 3. 감정 히트맵 (실제 데이터 연동)
  Widget _buildEmotionHeatmap(List records, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyEmotions = _getDailyEmotionsForHeatmap(records);

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
          _buildRealCalendarHeatmap(dailyEmotions, isDark, context),
        ],
      ),
    );
  }

  // 실제 데이터에서 일별 감정 추출 (히트맵용)
  Map<int, String> _getDailyEmotionsForHeatmap(List records) {
    final Map<int, Map<String, int>> dailyEmotionCounts = {};
    final now = DateTime.now();

    print('히트맵 데이터 추출 시작: ${records.length}개 기록');

    for (var record in records) {
      DateTime recordDate;
      String emotion;

      if (record is Map) {
        recordDate = record['date'] ?? now;
        emotion = record['emotion'] ?? 'happy';
      } else {
        recordDate = record.date;
        emotion = record.emotion;
      }

      final daysDiff = now.difference(recordDate).inDays;
      if (daysDiff >= 0 && daysDiff <= 29) {
        final day = daysDiff + 1; // 1부터 30까지
        dailyEmotionCounts[day] ??= {};
        dailyEmotionCounts[day]![emotion] = (dailyEmotionCounts[day]![emotion] ?? 0) + 1;
      }
    }

    // 각 날짜의 주된 감정 결정
    final Map<int, String> dominantEmotions = {};
    for (var entry in dailyEmotionCounts.entries) {
      final day = entry.key;
      final emotionCounts = entry.value;

      if (emotionCounts.isNotEmpty) {
        final dominantEmotion = emotionCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b).key;
        dominantEmotions[day] = dominantEmotion;
      }
    }

    print('히트맵 데이터 결과: $dominantEmotions');
    return dominantEmotions;
  }

  // 실제 데이터 기반 달력 히트맵
  Widget _buildRealCalendarHeatmap(Map<int, String> dailyEmotions, bool isDark, BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(30, (index) {
        final day = index + 1;
        final emotion = dailyEmotions[day];

        if (emotion == null) {
          // 감정 기록이 없는 날
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
                '$day',
                style: GoogleFonts.jua(
                  fontSize: 10,
                  color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                ),
              ),
            ),
          );
        }

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
              '$day',
              style: GoogleFonts.jua(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        );
      }),
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
          'message': '${emotionKoreanNames[topEmotion.key] ?? topEmotion.key} 감정이 전체의 ${((topEmotion.value / totalRecords) * 100).toStringAsFixed(1)}%를 차지해요. 이 감정이 최근 주된 감정 상태인 것 같아요.'
        });
      }

      final negativeEmotions = ['sad', 'angry', 'anxious', 'despair'];
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
      final positiveEmotions = ['happy', 'love', 'calm', 'excited', 'confidence'];
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
    case 'confidence':
      return RabbitEmotion.confidence;
    default:
      return RabbitEmotion.happy;
  }
}

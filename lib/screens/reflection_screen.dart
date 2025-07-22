import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/rabbit_emoticon.dart';
import '../providers/emotion_provider.dart';
import 'package:provider/provider.dart';
import '../models/emotion_record.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({Key? key}) : super(key: key);

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen>
    with SingleTickerProviderStateMixin {
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
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildCustomAppBar(String monthName) {
    return Padding(
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
          const Spacer(),
          Text(
            '$monthName 회고',
            style: GoogleFonts.jua(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4C4C4C),
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
    );
  }

  Widget _buildMonthlyHeader(String monthName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('📝', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$monthName 감정 여행',
                      style: GoogleFonts.jua(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI가 당신의 감정 패턴을 분석했어요',
                      style: GoogleFonts.jua(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '✨ 매월 회고를 통해 감정적 성장을 확인해보세요',
              style: GoogleFonts.jua(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIReflectionCard(String aiComment) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4ECDC4),
                  Color(0xFF44A08D),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('🤖', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI 감정 분석 리포트',
                      style: GoogleFonts.jua(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    aiComment,
                    style: GoogleFonts.jua(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  RabbitEmotion _mapLabelToRabbitEmotion(String label) {
    switch (label) {
      case '행복':
        return RabbitEmotion.happy;
      case '슬픔':
        return RabbitEmotion.sad;
      case '화남':
        return RabbitEmotion.angry;
      case '흥분':
        return RabbitEmotion.excited;
      case '평온':
        return RabbitEmotion.calm;
      case '불안':
        return RabbitEmotion.anxious;
      case '사랑':
        return RabbitEmotion.love;
      case '피곤':
        return RabbitEmotion.tired;
      case '절망':
        return RabbitEmotion.despair;
      default:
        return RabbitEmotion.happy;
    }
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
      case '😭':
        return RabbitEmotion.despair;
      default:
        return RabbitEmotion.happy;
    }
  }

  Widget _buildEmotionSummaryCard(Map<String, int> emotionCounts, int total) {
    final emotionStats = [
      {'emoji': '😊', 'label': '행복', 'key': 'happy', 'color': const Color(0xFFFFB74D)},
      {'emoji': '😢', 'label': '슬픔', 'key': 'sad', 'color': const Color(0xFF64B5F6)},
      {'emoji': '😤', 'label': '분노', 'key': 'angry', 'color': const Color(0xFFE57373)},
      {'emoji': '😰', 'label': '불안', 'key': 'anxious', 'color': const Color(0xFF9575CD)},
      {'emoji': '😴', 'label': '피곤', 'key': 'tired', 'color': const Color(0xFF81C784)},
      {'emoji': '🥰', 'label': '사랑', 'key': 'love', 'color': const Color(0xFFFF8FA3)},
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9A9E),
            Color(0xFFFECFEF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9A9E).withOpacity(0.3),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('📊', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '감정 분포 현황',
                style: GoogleFonts.jua(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: emotionStats.map((stat) {
                final count = emotionCounts[stat['key']] ?? 0;
                final percent = total > 0 ? (count / total * 100).toInt() : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ((stat['color'] as Color?) ?? Colors.grey).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(stat['emoji'] as String, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stat['label'] as String,
                          style: GoogleFonts.jua(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$percent%',
                        style: GoogleFonts.jua(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: stat['color'] as Color,
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

  Widget _buildRecentEmotionChart(List recent7) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 7일 감정 변화',
          style: GoogleFonts.jua(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final record = recent7[index];
                return Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6B73FF).withOpacity(0.1),
                      ),
                      child: Center(
                        child: record != null
                            ? RabbitEmoticon(
                                emotion: _mapStringToRabbitEmotion(record.emotion),
                                size: 30,
                              )
                            : const Text('-', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: GoogleFonts.jua(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A5568),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthInsights() {
    final insights = [
      {
        'icon': '📈',
        'title': '감정 인식 능력 향상',
        'description': '이전 달보다 더 다양한 감정을 인식하고 표현하고 있어요',
        'progress': 0.8,
      },
      {
        'icon': '🎯',
        'title': '감정 조절 연습',
        'description': '부정적인 감정을 건강하게 처리하는 방법을 터득했어요',
        'progress': 0.65,
      },
      {
        'icon': '🌱',
        'title': '자기 이해 증진',
        'description': '감정 패턴을 파악하며 자신을 더 잘 알아가고 있어요',
        'progress': 0.9,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🚀', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '성장 인사이트',
                style: GoogleFonts.jua(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...insights.map((insight) =>
              TweenAnimationBuilder(
                duration: Duration(milliseconds: 800 +
                    (insight['icon'] as String).hashCode % 400),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              insight['icon'] as String,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              insight['title'] as String,
                              style: GoogleFonts.jua(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          insight['description'] as String,
                          style: GoogleFonts.jua(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: value *
                                (insight['progress'] as double),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTips() {
    final tips = [
      '😌 스트레스를 받을 때는 심호흡을 3번 해보세요',
      '🌅 아침에 일어나서 감사한 것 3가지를 떠올려보세요',
      '📚 하루 10분 일기 쓰기로 감정을 정리해보세요',
      '🚶‍♀️ 산책하며 자연과 함께 마음을 편안하게 해보세요',
      '🎵 좋아하는 음악을 들으며 감정을 표현해보세요',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFFE66D),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('💡', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '맞춤형 감정 케어 팁',
                style: GoogleFonts.jua(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: tips.take(3).map((tip) =>
                  TweenAnimationBuilder(
                    duration: Duration(milliseconds: 600 + tip.hashCode % 400),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tip,
                            style: GoogleFonts.jua(
                              fontSize: 13,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  )
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMonthGoals() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🎯', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '다음 달 목표',
                style: GoogleFonts.jua(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌟 감정 기록 습관화하기',
                  style: GoogleFonts.jua(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '매일 꾸준히 감정을 기록하여 자신을 더 잘 이해해보세요. 작은 변화도 소중한 성장입니다.',
                  style: GoogleFonts.jua(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '목표 설정하기',
                            style: GoogleFonts.jua(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('💪', style: TextStyle(fontSize: 20)),
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

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<EmotionProvider>(context).records;
    final month = DateTime.now().month;
    final monthNames = ['', '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'];
    // 이번 달 기록만 추출
    final now = DateTime.now();
    final monthRecords = records.where((r) => r.date.year == now.year && r.date.month == now.month).toList();
    // 감정별 카운트
    final Map<String, int> emotionCounts = {};
    for (final r in monthRecords) {
      emotionCounts[r.emotion] = (emotionCounts[r.emotion] ?? 0) + 1;
    }
    // 최근 7일 감정 변화
    final recent7 = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return records.firstWhere(
        (r) => r.date.year == day.year && r.date.month == day.month && r.date.day == day.day,
        orElse: () => EmotionRecord(date: DateTime(2000), emotion: '', diary: ''),
      );
    });
    // 가장 많이 기록된 감정
    String? topEmotion;
    int maxCount = 0;
    emotionCounts.forEach((k, v) {
      if (v > maxCount) {
        topEmotion = k;
        maxCount = v;
      }
    });
    // AI 회고 코멘트 예시(실제 AI 연동 전까지)
    String aiComment = '';
    if (topEmotion != null) {
      switch (topEmotion) {
        case 'happy':
          aiComment = '이번 달은 긍정적인 감정이 많았어요! 행복한 순간을 잘 기록하셨네요.';
          break;
        case 'sad':
          aiComment = '이번 달은 슬픔이 많았어요. 힘든 순간도 잘 기록해주셨어요.';
          break;
        case 'angry':
          aiComment = '분노의 감정이 두드러졌어요. 감정을 솔직하게 표현한 점이 멋져요!';
          break;
        case 'love':
          aiComment = '사랑이 가득한 한 달이었네요! 따뜻한 기록이 많아요.';
          break;
        default:
          aiComment = '다양한 감정이 골고루 나타났어요. 꾸준한 기록이 성장의 밑거름입니다!';
      }
    } else {
      aiComment = '아직 이번 달 감정 기록이 없어요. 오늘부터 감정을 기록해보세요!';
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
              final isWide = constraints.maxWidth > 600;
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 80 : 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCustomAppBar(monthNames[month]),
                      const SizedBox(height: 20),
                      _buildMonthlyHeader(monthNames[month]),
                      const SizedBox(height: 20),
                      _buildAIReflectionCard(aiComment),
                      const SizedBox(height: 20),
                      _buildEmotionSummaryCard(emotionCounts, monthRecords.length),
                      const SizedBox(height: 20),
                      _buildRecentEmotionChart(recent7),
                      const SizedBox(height: 20),
                      _buildGrowthInsights(),
                      const SizedBox(height: 20),
                      _buildPersonalizedTips(),
                      const SizedBox(height: 20),
                      _buildNextMonthGoals(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
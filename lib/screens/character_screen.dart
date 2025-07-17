import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/growth_tree.dart';
import '../widgets/rabbit_emoticon.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({Key? key}) : super(key: key);

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  // 현재 레벨과 감정 상태
  int currentLevel = 3;
  RabbitEmotion currentEmotion = RabbitEmotion.happy;

  GrowthStage get currentGrowthStage {
    switch (currentLevel) {
      case 1:
        return GrowthStage.seed;
      case 2:
        return GrowthStage.sprout;
      case 3:
        return GrowthStage.sapling;
      case 4:
        return GrowthStage.tree;
      case 5:
      default:
        return GrowthStage.blossom;
    }
  }

  String get stageDescription {
    switch (currentGrowthStage) {
      case GrowthStage.seed:
        return '새로운 시작, 씨앗이 뿌려졌습니다';
      case GrowthStage.sprout:
        return '감정의 새싹이 돋아나고 있어요';
      case GrowthStage.sapling:
        return '꾸준히 성장하는 어린 나무가 되었어요';
      case GrowthStage.tree:
        return '든든한 나무로 자랐습니다';
      case GrowthStage.blossom:
        return '아름다운 벚꽃이 만개했어요!';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final characterName = '감정을 마주하는 토끼';
    final description = '감정을 솔직하게 바라보고, 성장하는 당신을 닮은 캐릭터입니다.';
    final growthMsg = '이번 달 당신은 감정을 회피하지 않았어요!';
    final emotionData = ['😊', '😢', '😤', '😌', '🥰', '😴', '🤔'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8F4FF),
              const Color(0xFFE8F5FF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 80 : 20,
                      vertical: 12
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 커스텀 앱바
                      _buildCustomAppBar(),

                      const SizedBox(height: 20),

                      // 성장 트리 섹션
                      _buildGrowthTreeSection(),

                      const SizedBox(height: 24),

                      // 설명 카드
                      _buildDescriptionCard(description, growthMsg),

                      const SizedBox(height: 24),

                      // 감정 통계 섹션
                      _buildEmotionStatsSection(),

                      const SizedBox(height: 20),

                      // 최근 감정 변화 섹션
                      _buildEmotionChartSection(emotionData),

                      const SizedBox(height: 24),

                      // 성장 배지 섹션
                      _buildGrowthBadgesSection(),

                      const SizedBox(height: 20),
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

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
            '나의 성장',
            style: GoogleFonts.jua(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
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

  Widget _buildGrowthTreeSection() {
    return Column(
      children: [
        // 성장 트리 위젯
        GrowthTreeWidget(
          stage: currentGrowthStage,
          size: 120,
          onTap: () {
            // 레벨업 시뮬레이션 (테스트용)
            setState(() {
              if (currentLevel < 5) {
                currentLevel++;
              } else {
                currentLevel = 1;
              }
            });
          },
        ),

        const SizedBox(height: 12),

        // 성장 단계 설명
        Text(
          stageDescription,
          style: GoogleFonts.jua(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A5568),
          ),
          textAlign: TextAlign.center,
        ),

        // 레벨 배지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6B73FF),
                const Color(0xFF9F7AEA),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B73FF).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'Level $currentLevel ✨',
            style: GoogleFonts.jua(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(String description, String growthMsg) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              description,
              style: GoogleFonts.jua(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4A5568),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B73FF).withOpacity(0.1),
                    const Color(0xFF9F7AEA).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: const Color(0xFF6B73FF),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '성장 메시지',
                        style: GoogleFonts.jua(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B73FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    growthMsg,
                    style: GoogleFonts.jua(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2D3748),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이번 주 감정 통계',
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
              children: [
                _buildStatItem('😊', '행복', '42%', const Color(0xFFFFB800)),
                _buildStatItem('😌', '평온', '28%', const Color(0xFF6B73FF)),
                _buildStatItem('😢', '슬픔', '18%', const Color(0xFF7C3AED)),
                _buildStatItem('😤', '화남', '12%', const Color(0xFFEF4444)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String emoji, String label, String percentage, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Center(
            child: RabbitEmoticon(
              emotion: _mapStringToRabbitEmotion(emoji),
              size: 40, // 기존 24 → 40
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.jua(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          percentage,
          style: GoogleFonts.jua(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionChartSection(List<String> emotionData) {
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final days = ['월', '화', '수', '목', '금', '토', '일'];
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
                            child: RabbitEmoticon(
                              emotion: _mapStringToRabbitEmotion(emotionData[index]),
                              size: 30, // 기존 18 → 30
                            ),
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
                const SizedBox(height: 16),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6B73FF).withOpacity(0.3),
                        const Color(0xFF6B73FF),
                        const Color(0xFF9F7AEA),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildGrowthBadgesSection() {
    final badges = [
      {'emoji': '🎯', 'title': '꾸준한 기록', 'desc': '7일 연속 기록'},
      {'emoji': '🌟', 'title': '감정 탐험가', 'desc': '다양한 감정 경험'},
      {'emoji': '💪', 'title': '성장하는 마음', 'desc': '긍정적 변화'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성장 배지',
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
            child: Column(
              children: badges.map((badge) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: RabbitEmoticon(
                            emotion: _mapStringToRabbitEmotion(badge['emoji']!),
                            size: 40, // 기존 22 → 40
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              badge['title']!,
                              style: GoogleFonts.jua(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge['desc']!,
                              style: GoogleFonts.jua(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF4A5568),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: const Color(0xFF10B981),
                        size: 20,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  RabbitEmotion _mapStringToRabbitEmotion(String emoji) {
    switch (emoji) {
      case '😊':
        return RabbitEmotion.happy;
      case '😢':
        return RabbitEmotion.sad;
      case '😤':
        return RabbitEmotion.angry;
      case '😌':
        return RabbitEmotion.calm;
      case '🥰':
        return RabbitEmotion.love;
      case '😴':
        return RabbitEmotion.tired;
      case '🤔':
        return RabbitEmotion.anxious;
      default:
        return RabbitEmotion.happy;
    }
  }
}
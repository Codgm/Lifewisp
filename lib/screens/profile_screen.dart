import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/emotion_record.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
// import '../providers/auth_provider.dart';
import '../widgets/season_animation.dart';
import '../utils/season_utils.dart';
import '../widgets/rabbit_emoticon.dart';
import '../providers/emotion_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/common_app_bar.dart';
import '../utils/growth_badge_system.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 현재 레벨과 감정 상태
  RabbitEmotion currentEmotion = RabbitEmotion.happy;


  String? _profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final emotionProvider = Provider.of<EmotionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final records = emotionProvider.records ?? []; // null 체크 추가
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 실제 시간에 따라 계절 결정
    final currentSeason = SeasonUtils.getCurrentSeason();
    
    // 레벨은 감정 기록 수에 따라 결정
    int recordCount = records.length;
    int currentLevel = 1; // 기본값을 1로 변경
    if (recordCount >= 30) {
      currentLevel = 5;
    } else if (recordCount >= 20) {
      currentLevel = 4;
    } else if (recordCount >= 10) {
      currentLevel = 3;
    } else if (recordCount >= 5) {
      currentLevel = 2;
    }

    // 최근 7일 감정 변화 - null 안전성 개선
    final now = DateTime.now();
    final recent7 = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      try {
        return records.firstWhere(
              (r) => r.date.year == day.year && r.date.month == day.month && r.date.day == day.day,
          orElse: () => EmotionRecord(date: DateTime(2000), emotion: '', diary: ''),
        );
      } catch (e) {
        return EmotionRecord(date: DateTime(2000), emotion: '', diary: '');
      }
    });

    // 감정별 카운트(전체) - null 안전성 개선
    final Map<String, int> emotionCounts = {};
    for (final r in records) {
      if (r.emotion.isNotEmpty) {
        emotionCounts[r.emotion] = (emotionCounts[r.emotion] ?? 0) + 1;
      }
    }

    // 더미 데이터
    final description = '감정을 솔직하게 바라보고, 성장하는 당신을 닮은 캐릭터입니다.';
    final growthMsg = SeasonUtils.getGrowthMessageForSeason(currentSeason);

    return Scaffold(
      appBar: CommonAppBar(
        title: '프로필',
        emoji: '🐰',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: FallingAnimationOverlay(
        season: currentSeason,
        child: Container(
          decoration: BoxDecoration(
            gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
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
                        const SizedBox(height: 20),

                        // 수정된 프로필 섹션 - SeasonProfileWidget 대신 직접 구현
                        _buildProfileSection(currentSeason, userProvider),

                        const SizedBox(height: 12),

                        // 계절 설명
                        Text(
                          SeasonUtils.getSeasonDescription(currentSeason),
                          style: LifewispTextStyles.getStaticFont(
                            context,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: LifewispColorsExt.subTextFor(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // 레벨 표시 - 그림자 완전 제거
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [LifewispColors.darkPink, LifewispColors.darkPurple]
                                    : [LifewispColors.pink, LifewispColors.purple],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Level $currentLevel ✨',
                              style: LifewispTextStyles.getStaticFont(
                                context,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDescriptionCard(description, growthMsg),
                        const SizedBox(height: 24),
                        // 감정 통계 섹션
                        _buildEmotionStatsSection(emotionCounts, records.length),
                        const SizedBox(height: 20),
                        // 최근 감정 변화 섹션
                        _buildEmotionChartSection(recent7),
                        const SizedBox(height: 24),
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
      ),
    );
  }

  // 새로운 프로필 섹션 - 닉네임 표시 포함
  Widget _buildProfileSection(Season currentSeason, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 프로필 이미지/캐릭터
        Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _getSeasonColors(currentSeason, isDark),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: _profileImageUrl != null
                  ? ClipOval(
                child: Image.network(
                  _profileImageUrl!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
                  : RabbitEmoticon(
                emotion: RabbitEmotion.happy,
                size: 100,
              ),
            ),
          ),

        const SizedBox(height: 16),
        // 닉네임 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userProvider.userNickname ?? '감정 탐험가',
              style: LifewispTextStyles.getStaticFont(
                context,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: LifewispColorsExt.mainTextFor(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 계절별 색상 반환
  List<Color> _getSeasonColors(Season season, bool isDark) {
    return SeasonUtils.getSeasonColors(season, isDark);
  }






  Widget _buildDescriptionCard(String description, String growthMsg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: LifewispColorsExt.cardBgFor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
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
              style: LifewispTextStyles.getStaticFont(
                context,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: LifewispColorsExt.subTextFor(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                    LifewispColors.darkPink.withOpacity(0.2),
                    LifewispColors.darkPurple.withOpacity(0.2),
                  ]
                      : [
                    LifewispColors.pink.withOpacity(0.1),
                    LifewispColors.purple.withOpacity(0.1),
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
                        color: isDark ? LifewispColors.darkPink : LifewispColors.pink,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '성장 메시지',
                        style: LifewispTextStyles.getStaticFont(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? LifewispColors.darkPink : LifewispColors.pink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    growthMsg,
                    style: LifewispTextStyles.getStaticFont(
                      context,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: LifewispColorsExt.mainTextFor(context),
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

  Widget _buildEmotionStatsSection(Map<String, int> emotionCounts, int total) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final emotionStats = [
      {
        'emoji': '😊',
        'label': '행복',
        'key': 'happy',
        'color': isDark ? LifewispColors.darkYellow : LifewispColors.darkYellow.withOpacity(0.8)
      },
      {
        'emoji': '😢',
        'label': '슬픔',
        'key': 'sad',
        'color': isDark ? LifewispColors.darkBlue : LifewispColors.darkBlue.withOpacity(0.8)
      },
      {
        'emoji': '😤',
        'label': '분노',
        'key': 'angry',
        'color': isDark ? LifewispColors.darkRed : LifewispColors.red
      },
      {
        'emoji': '😰',
        'label': '불안',
        'key': 'anxious',
        'color': isDark ? LifewispColors.darkOrange : LifewispColors.orange
      },
      {
        'emoji': '😴',
        'label': '피곤',
        'key': 'tired',
        'color': isDark ? LifewispColors.darkLightGray : LifewispColors.gray
      },
      {
        'emoji': '🥰',
        'label': '사랑',
        'key': 'love',
        'color': isDark ? LifewispColors.darkPink : LifewispColors.pink
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이번 주 감정 통계',
          style: LifewispTextStyles.getStaticFont(
            context,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: LifewispColorsExt.mainTextFor(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: LifewispColorsExt.cardBgFor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: emotionStats.map((stat) {
                final count = emotionCounts[stat['key']] ?? 0;
                final percent = total > 0 ? (count / total * 100).toInt() : 0;
                return _buildStatItem(
                    stat['emoji'] as String,
                    stat['label'] as String,
                    '$percent%',
                    stat['color'] as Color
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String emoji, String label, String percentage, Color color) {
    return Column(
      children: [
        RabbitEmoticon(
          emotion: _mapStringToRabbitEmotion(emoji),
          size: 40,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: LifewispTextStyles.getStaticFont(
            context,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: LifewispColorsExt.subTextFor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          percentage,
          style: LifewispTextStyles.getStaticFont(
            context,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionChartSection(List<EmotionRecord> recent7) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 7일 감정 변화',
          style: LifewispTextStyles.getStaticFont(
            context,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: LifewispColorsExt.mainTextFor(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: LifewispColorsExt.cardBgFor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.04),
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
                final hasValidRecord = record.date.year != 2000 && record.emotion.isNotEmpty;

                return Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      // decoration 완전 제거
                      child: Center(
                        child: hasValidRecord
                            ? RabbitEmoticon(
                          emotion: _mapStringToRabbitEmotion(record.emotion),
                          size: 30,
                          )
                            : Text(
                            '-',
                            style: LifewispTextStyles.getStaticFont(
                                context,
                                fontSize: 18,
                                color: LifewispColorsExt.subTextFor(context)
                            )
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: LifewispTextStyles.getStaticFont(
                        context,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: LifewispColorsExt.subTextFor(context),
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

  Widget _buildGrowthBadgesSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emotionProvider = Provider.of<EmotionProvider>(context);
    final records = emotionProvider.records ?? [];
    final badges = GrowthBadgeSystem.getBadges(records);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성장 배지',
          style: LifewispTextStyles.getStaticFont(
            context,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: LifewispColorsExt.mainTextFor(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 280, // 3개 배지 + 여백에 맞는 높이 설정
          decoration: BoxDecoration(
            color: LifewispColorsExt.cardBgFor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Text(
                        badge.emoji,
                        style: TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              badge.title,
                              style: LifewispTextStyles.getStaticFont(
                                context,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: LifewispColorsExt.mainTextFor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge.description,
                              style: LifewispTextStyles.getStaticFont(
                                context,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: LifewispColorsExt.subTextFor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 달성 상태에 따른 아이콘
                      badge.isAchieved
                          ? Icon(
                        Icons.check_circle,
                        color: isDark ? LifewispColors.darkGreen : LifewispColors.green,
                        size: 20,
                      )
                          : Icon(
                        Icons.radio_button_unchecked,
                        color: isDark
                            ? LifewispColors.darkSubText.withOpacity(0.5)
                            : LifewispColors.subText.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  RabbitEmotion _mapStringToRabbitEmotion(String emoji) {
    switch (emoji) {
      case '😊':
      case 'happy':
        return RabbitEmotion.happy;
      case '😢':
      case 'sad':
        return RabbitEmotion.sad;
      case '😤':
      case 'angry':
        return RabbitEmotion.angry;
      case '😌':
      case 'calm':
        return RabbitEmotion.calm;
      case '🥰':
      case 'love':
        return RabbitEmotion.love;
      case '😴':
      case 'tired':
        return RabbitEmotion.tired;
      case '🤔':
      case '😰':
      case 'anxious':
        return RabbitEmotion.anxious;
      default:
        return RabbitEmotion.happy;
    }
  }
}

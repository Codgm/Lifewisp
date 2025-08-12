import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/emotion_record.dart';
import '../utils/theme.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/rabbit_emoticon.dart';

class ShareScreen extends StatefulWidget {
  final EmotionRecord? record; // 전달받은 감정 기록
  const ShareScreen({Key? key, this.record}) : super(key: key);

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> with TickerProviderStateMixin {
  int selectedTheme = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getThemes(bool isDark) {
    return [
      {
        'name': '모던 퍼플',
        'gradient': isDark
            ? [const Color(0xFF4A1A4A), const Color(0xFF6B2C6B), const Color(0xFF8E4EC6)]
            : [const Color(0xFFE6E6FA), const Color(0xFFDDA0DD), const Color(0xFFBA55D3)],
        'accent': isDark ? const Color(0xFF9D4EDD) : const Color(0xFF8A2BE2),
        'particles': const Color(0xFFFFFFFF),
      },
      {
        'name': '소프트 핑크',
        'gradient': isDark
            ? [const Color(0xFF4A1A2E), const Color(0xFF6B2C42), const Color(0xFF8E4EC6)]
            : [const Color(0xFFFFC0CB), const Color(0xFFFFB6C1), const Color(0xFFFF69B4)],
        'accent': isDark ? const Color(0xFFFF6B9D) : const Color(0xFFFF69B4),
        'particles': const Color(0xFFFFFFFF),
      },
      {
        'name': '민트 그린',
        'gradient': isDark
            ? [const Color(0xFF1A4A4A), const Color(0xFF2C6B6B), const Color(0xFF4EC68E)]
            : [const Color(0xFFE0FFE0), const Color(0xFF98FB98), const Color(0xFF20B2AA)],
        'accent': isDark ? const Color(0xFF4ECDC4) : const Color(0xFF20B2AA),
        'particles': const Color(0xFFFFFFFF),
      },
      {
        'name': '선셋 오렌지',
        'gradient': isDark
            ? [const Color(0xFF4A2A1A), const Color(0xFF6B422C), const Color(0xFFC68E4E)]
            : [const Color(0xFFFFE4B5), const Color(0xFFFFDAB9), const Color(0xFFFF6347)],
        'accent': isDark ? const Color(0xFFFF8C42) : const Color(0xFFFF6347),
        'particles': const Color(0xFFFFFFFF),
      },
    ];
  }

  // 감정에 따른 RabbitEmotion 매핑
  RabbitEmotion _getEmotionType(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return RabbitEmotion.happy;
      case 'sad':
        return RabbitEmotion.sad;
      case 'angry':
        return RabbitEmotion.angry;
      case 'excited':
        return RabbitEmotion.excited;
      case 'calm':
        return RabbitEmotion.calm;
      case 'anxious':
        return RabbitEmotion.anxious;
      case 'love':
        return RabbitEmotion.love;
      case 'tired':
        return RabbitEmotion.tired;
      case 'despair':
        return RabbitEmotion.despair;
      case 'confidence':
        return RabbitEmotion.confidence;
      default:
        return RabbitEmotion.happy;
    }
  }

  // 감정에서 키워드 생성
  List<String> _generateKeywordsFromEmotion(String emotion, List<String>? categories) {
    List<String> emotionKeywords = {
      'happy': ['#행복', '#기쁨', '#즐거움'],
      'sad': ['#슬픔', '#우울', '#눈물'],
      'angry': ['#분노', '#화남', '#스트레스'],
      'excited': ['#흥분', '#설렘', '#기대'],
      'calm': ['#평온', '#안정', '#휴식'],
      'anxious': ['#불안', '#걱정', '#긴장'],
      'love': ['#사랑', '#애정', '#따뜻함'],
      'tired': ['#피곤', '#휴식필요', '#지침'],
      'despair': ['#절망', '#힘듦', '#위로'],
      'confidence': ['#자신감', '#당당', '#성취'],
    }[emotion.toLowerCase()] ?? ['#감정일기', '#성장'];

    // 카테고리가 있으면 해시태그로 추가
    if (categories != null && categories.isNotEmpty) {
      emotionKeywords.addAll(categories.take(2).map((cat) => '#$cat'));
    }

    return emotionKeywords.take(3).toList();
  }

  // 감정에서 메시지 생성
  String _generateMessageFromRecord(EmotionRecord record) {
    Map<String, List<String>> emotionMessages = {
      'happy': [
        '오늘은 특별히 행복한 하루였어요 ✨',
        '웃음이 끊이지 않는 하루',
        '행복한 순간들을 간직해요',
      ],
      'sad': [
        '슬픈 감정도 소중한 나의 일부',
        '눈물 뒤에는 성장이 있어요',
        '괜찮아요, 내일은 더 나아질 거예요',
      ],
      'angry': [
        '분노도 나를 표현하는 방법',
        '감정을 인정하고 받아들여요',
        '화가 나는 것도 괜찮아요',
      ],
      'excited': [
        '설레는 마음이 가득한 하루',
        '새로운 시작에 대한 기대감',
        '흥미진진한 하루를 보냈어요',
      ],
      'calm': [
        '고요한 마음이 주는 평화',
        '내 마음속 고요함을 찾았어요',
        '평온함 속에서 나를 돌아봐요',
      ],
      'anxious': [
        '불안한 마음도 이해해요',
        '걱정이 많았던 하루였지만',
        '불안함도 나의 소중한 감정',
      ],
      'love': [
        '사랑으로 가득한 마음',
        '따뜻한 사랑을 느꼈어요',
        '사랑하고 사랑받는 하루',
      ],
      'tired': [
        '피곤하지만 나를 아껴요',
        '휴식이 필요한 시간이에요',
        '충분한 쉼을 가져요',
      ],
    };

    List<String> messages = emotionMessages[record.emotion.toLowerCase()] ??
        ['내 감정을 소중히 여겨요', '오늘도 나를 이해해요'];

    return messages.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themes = getThemes(isDark);

    // 실제 데이터 또는 더미 데이터 사용
    final EmotionRecord displayRecord = widget.record ?? EmotionRecord(
      date: DateTime.now(),
      emotion: 'happy',
      diary: '내 감정을 인정하는 건\n나를 존중하는 일이다.',
      categories: ['자존감', '성장'],
    );

    final selectedThemeData = themes[selectedTheme];
    final keywords = _generateKeywordsFromEmotion(displayRecord.emotion, displayRecord.categories);
    final summary = _generateMessageFromRecord(displayRecord);

    return Scaffold(
      backgroundColor: isDark
          ? LifewispColors.darkBlack
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: '공유',
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: Theme.of(context).brightness == Brightness.dark),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 실제 데이터 표시 알림
                if (widget.record != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isDark
                          ? LifewispColors.darkPrimary
                          : LifewispColors.primary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isDark
                            ? LifewispColors.darkPrimary
                            : LifewispColors.primary).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: isDark
                              ? LifewispColors.darkPrimary
                              : LifewispColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${displayRecord.date.month}월 ${displayRecord.date.day}일의 감정 기록을 공유카드로 만들었어요!',
                            style: LifewispTextStyles.getStaticFont(
                              context,
                              fontSize: 13,
                              color: isDark
                                  ? LifewispColors.darkPrimary
                                  : LifewispColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 인스타그램 스타일 미리보기 카드
                Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            width: 320,
                            height: 400,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: selectedThemeData['gradient'],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: selectedThemeData['accent'].withOpacity(0.4),
                                  blurRadius: 40,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 20),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // 배경 패턴 (인스타그램 스타일)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: PatternPainter(
                                      color: selectedThemeData['particles'].withOpacity(0.1),
                                    ),
                                  ),
                                ),

                                // 글래스모피즘 오버레이
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.05),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // 메인 콘텐츠
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // 상단 브랜딩
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(5),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.favorite,
                                              color: selectedThemeData['accent'],
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'LifeWisp',
                                            style: GoogleFonts.jua(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 3,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // RabbitEmoticon 사용 - 개선된 버전
                                      Container(
                                        width: 100,
                                        height: 100,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.95),
                                          borderRadius: BorderRadius.circular(50),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                            BoxShadow(
                                              color: selectedThemeData['accent'].withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        child: RabbitEmoticon(
                                          emotion: _getEmotionType(displayRecord.emotion),
                                          size: 64,
                                        ),
                                      ),

                                      // 감정 요약
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          summary,
                                          style: LifewispTextStyles.getStaticFont(
                                            context,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            height: 1.3,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      // 키워드 태그
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        alignment: WrapAlignment.center,
                                        children: keywords.map((keyword) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.3),
                                                Colors.white.withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.4),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            keyword,
                                            style: LifewispTextStyles.getStaticFont(
                                              context,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )).toList(),
                                      ),

                                      // 날짜 표시
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '${displayRecord.date.year}.${displayRecord.date.month.toString().padLeft(2, '0')}.${displayRecord.date.day.toString().padLeft(2, '0')}',
                                          style: LifewispTextStyles.getStaticFont(
                                            context,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // 테마 선택 섹션
                Text(
                  '테마 선택',
                  style: LifewispTextStyles.getStaticFont(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? LifewispColors.darkMainText
                        : LifewispColors.mainText,
                  ),
                ),
                const SizedBox(height: 16),

                // 테마 선택 그리드 (더 세련되게)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: themes.length,
                  itemBuilder: (context, index) {
                    final theme = themes[index];
                    final isSelected = selectedTheme == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTheme = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: theme['gradient'],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? theme['accent']
                                : Colors.white.withOpacity(0.2),
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme['accent'].withOpacity(isSelected ? 0.4 : 0.2),
                              blurRadius: isSelected ? 20 : 8,
                              offset: const Offset(0, 4),
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // 글래스모피즘 효과
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Center(
                              child: Text(
                                theme['name'],
                                style: LifewispTextStyles.getStaticFont(
                                  context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            // 선택된 경우 체크 아이콘
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: theme['accent'],
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // 액션 버튼들 (더 매력적으로)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              selectedThemeData['accent'],
                              selectedThemeData['accent'].withOpacity(0.8)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: selectedThemeData['accent'].withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.download_done, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text('갤러리에 저장됐어요! 📸',
                                        style: LifewispTextStyles.getStaticFont(
                                          context,
                                          fontWeight: FontWeight.w500,
                                        )
                                    ),
                                  ],
                                ),
                                backgroundColor: isDark
                                    ? LifewispColors.darkSuccess
                                    : const Color(0xFF38B2AC),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.save_alt, color: Colors.white),
                          label: Text(
                            '저장',
                            style: LifewispTextStyles.getStaticFont(
                              context,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark
                              ? LifewispColors.darkCardBg
                              : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: selectedThemeData['accent'].withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? LifewispColors.darkCardShadow
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showShareOptions(context);
                          },
                          icon: Icon(Icons.share, color: selectedThemeData['accent']),
                          label: Text(
                            '공유',
                            style: LifewispTextStyles.getStaticFont(
                              context,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: selectedThemeData['accent'],
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? LifewispColors.darkCardBg
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? LifewispColors.darkSubText
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '공유하기',
              style: GoogleFonts.jua(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? LifewispColors.darkMainText
                    : LifewispColors.mainText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.message,
                  label: '카카오톡',
                  color: const Color(0xFFFFE812),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('카카오톡으로 공유했어요! 💛',
                            style: GoogleFonts.jua(fontWeight: FontWeight.w500)
                        ),
                        backgroundColor: const Color(0xFFFFE812),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.camera_alt,
                  label: '인스타그램',
                  color: const Color(0xFFE4405F),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('인스타그램으로 공유했어요! 💜',
                            style: GoogleFonts.jua(fontWeight: FontWeight.w500)
                        ),
                        backgroundColor: const Color(0xFFE4405F),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.copy,
                  label: '링크 복사',
                  color: const Color(0xFF667EEA),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('링크가 복사되었어요! 🔗',
                            style: GoogleFonts.jua(fontWeight: FontWeight.w500)
                        ),
                        backgroundColor: const Color(0xFF667EEA),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.jua(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? LifewispColors.darkMainText
                  : LifewispColors.mainText,
            ),
          ),
        ],
      ),
    );
  }
}

// 배경 패턴을 그리는 커스텀 페인터
class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 작은 원형 패턴들
    for (int i = 0; i < 20; i++) {
      final x = (i * 47.3) % size.width;
      final y = (i * 31.7) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }

    // 더 작은 점들
    paint.color = color.withOpacity(0.3);
    for (int i = 0; i < 40; i++) {
      final x = (i * 23.1) % size.width;
      final y = (i * 41.9) % size.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

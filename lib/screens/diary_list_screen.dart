import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../utils/emotion_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/rabbit_emoticon.dart';
import '../widgets/common_app_bar.dart';
import '../utils/theme.dart';
import '../models/emotion_record.dart';

import 'diary_detail_screen.dart' hide RabbitEmotion, RabbitEmoticon;

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({Key? key}) : super(key: key);

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> with TickerProviderStateMixin {
  String? filterEmotion;
  String searchText = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 더미 데이터 - 감정 기록이 없을 경우 표시될 샘플 데이터
  List<EmotionRecord> get _dummyRecords => [
    EmotionRecord(
      date: DateTime.now().subtract(Duration(days: 1)),
      emotion: 'happy',
      diary: '오늘은 친구들과 즐거운 시간을 보냈어요! 맛있는 음식도 먹고 웃음도 많이 나누었답니다. 이런 순간들이 정말 소중해요.',
      categories: ['친구만남', '맛있는음식', '소통'],
    ),
    EmotionRecord(
      date: DateTime.now().subtract(Duration(days: 2)),
      emotion: 'calm',
      diary: '공원을 산책하며 평온한 하루를 보냈습니다. 나무들 사이로 들어오는 햇살이 참 아름다웠어요.',
      categories: ['휴식', '자연'],
    ),
    EmotionRecord(
      date: DateTime.now().subtract(Duration(days: 3)),
      emotion: 'excited',
      diary: '새로운 프로젝트를 시작하게 되어서 정말 설레요! 앞으로 어떤 일들이 펼쳐질지 기대됩니다.',
      categories: ['새로운도전', '목표달성'],
    ),
    EmotionRecord(
      date: DateTime.now().subtract(Duration(days: 4)),
      emotion: 'love',
      diary: '가족들과 함께하는 저녁 시간이 너무 따뜻해요. 사랑하는 사람들과 함께 있을 때가 가장 행복한 것 같아요.',
      categories: ['가족시간', '사랑'],
    ),
    EmotionRecord(
      date: DateTime.now().subtract(Duration(days: 5)),
      emotion: 'tired',
      diary: '오늘은 조금 피곤했지만, 그래도 하루를 무사히 마칠 수 있어서 다행이에요. 내일은 더 활기찬 하루가 되길!',
      categories: ['업무', '휴식필요'],
    ),
  ];

  // 감정 데이터 - 캘린더 스타일과 동일
  Map<String, dynamic> _getEmotionData(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return {
      'happy': {
        'emoji': '😊',
        'color': isDark ? Color(0xFFFEF3C7) : Color(0xFFFFD93D),
        'name': '행복'
      },
      'sad': {
        'emoji': '😢',
        'color': isDark ? Color(0xFF93C5FD) : Color(0xFF6AB7FF),
        'name': '슬픔'
      },
      'angry': {
        'emoji': '😠',
        'color': isDark ? Color(0xFFFCA5A5) : Color(0xFFFF6B6B),
        'name': '분노'
      },
      'excited': {
        'emoji': '🤩',
        'color': isDark ? Color(0xFFFBBF24) : Color(0xFFFF9F43),
        'name': '흥분'
      },
      'calm': {
        'emoji': '😌',
        'color': isDark ? Color(0xFF34D399) : Color(0xFF4ECDC4),
        'name': '평온'
      },
      'anxious': {
        'emoji': '😰',
        'color': isDark ? Color(0xFFA78BFA) : Color(0xFFAD7BFF),
        'name': '불안'
      },
      'love': {
        'emoji': '🥰',
        'color': isDark ? Color(0xFFF472B6) : Color(0xFFFF8FA3),
        'name': '사랑'
      },
      'tired': {
        'emoji': '😪',
        'color': isDark ? Color(0xFF9CA3AF) : Color(0xFF95A5A6),
        'name': '피곤'
      },
    };
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final records = context
        .watch<EmotionProvider>()
        .records;
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    // 실제 데이터가 없으면 더미 데이터 사용
    final displayRecords = records.isEmpty ? _dummyRecords : records;

    final filtered = displayRecords.where((r) {
      final matchEmotion = filterEmotion == null || r.emotion == filterEmotion;
      final matchText = searchText.isEmpty || r.diary.contains(searchText);
      return matchEmotion && matchText;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CommonAppBar(title: '일기 리스트', showBackButton: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // 상단 통계 카드
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (isDark ? LifewispColors.darkCardBg : LifewispColors
                        .diaryCardBg).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : LifewispColors
                            .cardShadow).withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? LinearGradient(colors: [
                                  LifewispColors.darkPrimary,
                                  LifewispColors.darkPurple
                                ])
                                    : LifewispGradients.statCard,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.favorite, color: Colors.white,
                                  size: 20),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${displayRecords.length}',
                              style: LifewispTextStyles.getStaticFont(
                                context,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? LifewispColors.darkMainText
                                    : LifewispColors.statCardText,
                              ),
                            ),
                            Text(
                              '총 기록',
                              style: LifewispTextStyles.getStaticFont(
                                context,
                                fontSize: 12,
                                color: isDark
                                    ? LifewispColors.darkSubText
                                    : LifewispColors.statCardSubText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark ? LifewispColors.darkLightGray : Colors
                            .grey[200],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                    LifewispColors.darkPurple,
                                    LifewispColors.darkPurpleDark
                                  ]
                                      : [Color(0xFF9B59B6), Color(0xFFDDA0DD)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.timeline, color: Colors.white,
                                  size: 20),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '7일',
                              style: LifewispTextStyles.getStaticFont(
                                context,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? LifewispColors.darkMainText
                                    : Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              '연속 기록',
                              style: LifewispTextStyles.getStaticFont(
                                context,
                                fontSize: 12,
                                color: isDark
                                    ? LifewispColors.darkSubText
                                    : Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 검색창
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? LifewispColors.darkCardBg : LifewispColors
                        .diaryCardBg).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : LifewispColors
                            .cardShadow).withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '감정 기록 검색하기...',
                      hintStyle: LifewispTextStyles.getStaticFont(
                        context,
                        color: isDark ? LifewispColors.darkSubText : Color(
                            0xFF9CA3AF),
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark ? LifewispColors.darkPrimary : Color(
                            0xFF9B59B6),
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    style: LifewispTextStyles.getStaticFont(
                      context,
                      color: isDark
                          ? LifewispColors.darkMainText
                          : LifewispColors.darkGray,
                      fontSize: 16,
                    ),
                    onChanged: (v) => setState(() => searchText = v),
                  ),
                ),

                // 캘린더 스타일 감정 필터 칩들
                Container(
                  height: 56,
                  margin: EdgeInsets.symmetric(vertical: 12),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // 전체 보기 칩
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            '전체',
                            style: LifewispTextStyles.getStaticFont(
                              context,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: filterEmotion == null
                                  ? LifewispColors.white
                                  : (isDark
                                  ? LifewispColors.darkMainText
                                  : LifewispColors.primary),
                            ),
                          ),
                          selected: filterEmotion == null,
                          selectedColor: isDark
                              ? LifewispColors.darkPrimary
                              : LifewispColors.primary,
                          backgroundColor: (isDark
                              ? LifewispColors.darkCardBg
                              : Colors.white).withOpacity(0.9),
                          onSelected: (_) =>
                              setState(() => filterEmotion = null),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          pressElevation: 0,
                        ),
                      ),
                      // 감정별 필터 칩들
                      ..._getEmotionData(context).entries.map((entry) {
                        final emotion = entry.key;
                        final data = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              data['name'],
                              style: LifewispTextStyles.getStaticFont(
                                context,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: filterEmotion == emotion
                                    ? LifewispColors.white
                                    : data['color'],
                              ),
                            ),
                            selected: filterEmotion == emotion,
                            selectedColor: data['color'],
                            backgroundColor: (isDark
                                ? LifewispColors.darkCardBg
                                : Colors.white).withOpacity(0.9),
                            onSelected: (_) =>
                                setState(() => filterEmotion = emotion),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                            pressElevation: 0,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                // 더미 데이터 표시 알림 (실제 데이터가 없을 경우에만)
                if (records.isEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isDark
                          ? LifewispColors.darkPurple
                          : LifewispColors.purple).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isDark
                            ? LifewispColors.darkPurple
                            : LifewispColors.purple).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDark
                              ? LifewispColors.darkPurple
                              : LifewispColors.purple,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '아직 기록된 감정이 없어서 샘플 데이터를 보여드려요!',
                            style: LifewispTextStyles.getStaticFont(
                              context,
                              fontSize: 13,
                              color: isDark
                                  ? LifewispColors.darkPurple
                                  : LifewispColors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 기록 리스트
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : Container(
                    margin: EdgeInsets.only(top: 8),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _buildDiaryCard(filtered[index], index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDiaryCard(EmotionRecord diary, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emotionData = _getEmotionData(context);
    final emotionInfo = emotionData[diary.emotion];
    final color = emotionInfo?['color'] ?? (isDark ? LifewispColors.darkPrimary : LifewispColors.primary);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DiaryDetailScreen(record: diary),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 400),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (isDark ? LifewispColors.darkCardBg : LifewispColors.diaryCardBg).withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : LifewispColors.cardShadow).withOpacity(isDark ? 0.2 : 0.1),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // 감정 아바타 - 크기와 패딩 최적화
              Container(
                width: 70,  // 크기 증가
                height: 70, // 크기 증가
                padding: EdgeInsets.all(8), // 내부 패딩 추가
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: RabbitEmoticon(
                  emotion: _mapStringToRabbitEmotion(diary.emotion),
                  size: 40, // RabbitEmoticon 크기 조정
                ),
              ),
              SizedBox(width: 16),

              // 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diary.diary.length > 30
                          ? '${diary.diary.substring(0, 30)}...'
                          : diary.diary,
                      style: LifewispTextStyles.getStaticFont(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? LifewispColors.darkMainText : LifewispColors.darkGray,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 8),

                    // 카테고리 태그들 표시
                    if (diary.categories != null && diary.categories!.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: diary.categories!.take(2).map((category) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            category,
                            style: LifewispTextStyles.getStaticFont(
                              context,
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )).toList(),
                      ),
                      SizedBox(height: 8),
                    ],

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isDark ? LifewispColors.darkSubText : Color(0xFF9CA3AF),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${diary.date.month}월 ${diary.date.day}일',
                          style: LifewispTextStyles.getStaticFont(
                            context,
                            fontSize: 13,
                            color: isDark ? LifewispColors.darkSubText : Color(0xFF9CA3AF),
                          ),
                        ),

                        // 이미지가 있으면 표시
                        if (diary.imagePaths != null && diary.imagePaths!.isNotEmpty) ...[
                          SizedBox(width: 8),
                          Icon(
                            Icons.photo_camera_rounded,
                            size: 14,
                            color: color,
                          ),
                          Text(
                            ' ${diary.imagePaths!.length}',
                            style: LifewispTextStyles.getStaticFont(
                              context,
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // 화살표
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [LifewispColors.darkPurple.withOpacity(0.3), LifewispColors.darkPurpleDark.withOpacity(0.3)]
                    : [LifewispColors.pinkLight.withOpacity(0.3), LifewispColors.purpleDark.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Text('🌸', style: TextStyle(fontSize: 60)),
            ),
          ),
          SizedBox(height: 24),
          Text(
            '아직 기록된 감정이 없어요',
            style: LifewispTextStyles.getStaticFont(
              context,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? LifewispColors.darkMainText : LifewispColors.darkGray,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '첫 번째 감정을 기록해보세요!',
            style: LifewispTextStyles.getStaticFont(
              context,
              fontSize: 14,
              color: isDark ? LifewispColors.darkSubText : Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
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

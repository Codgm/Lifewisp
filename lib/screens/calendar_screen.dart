import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/emotion_provider.dart';
import '../widgets/rabbit_emoticon.dart';
import 'package:provider/provider.dart';
import '../models/emotion_record.dart';
import '../widgets/common_app_bar.dart';
import '../utils/theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with TickerProviderStateMixin {
  String? filterEmotion;
  DateTime selectedDate = DateTime.now();
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // 감정 데이터 - 테마 인식 색상으로 업데이트
  Map<String, dynamic> _getEmotionData(BuildContext context) {
    return {
      'happy': {'emoji': '😊', 'color': Color(0xFF4CAF50), 'name': '행복'}, // 초록색
      'sad': {'emoji': '😢', 'color': Color(0xFF2196F3), 'name': '슬픔'},   // 파란색
      'angry': {'emoji': '😠', 'color': Color(0xFF628BB3), 'name': '분노'}, // 진한 회색
      'excited': {'emoji': '🤩', 'color': Color(0xFFFFC107), 'name': '흥분'}, // 노란색
      'calm': {'emoji': '😌', 'color': Color(0xFF8BC34A), 'name': '평온'},   // 연한 초록
      'anxious': {'emoji': '😰', 'color': Color(0xFF9C27B0), 'name': '불안'}, // 보라색
      'love': {'emoji': '🥰', 'color': Color(0xFFE91E63), 'name': '사랑'},   // 핑크색
      'tired': {'emoji': '😪', 'color': Color(0xFF607D8B), 'name': '피곤'},  // 회색 블루
    };
  }

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // 화면 크기별 브레이크포인트 정의
  double _getResponsivePadding(double screenWidth) {
    if (screenWidth > 1200) return 100; // 큰 데스크톱
    if (screenWidth > 900) return 80;   // 작은 데스크톱
    if (screenWidth > 600) return 40;   // 태블릿
    return 16;                          // 모바일
  }

  double _getResponsiveFontSize(double screenWidth, double baseFontSize) {
    if (screenWidth > 1200) return baseFontSize * 1.2;
    if (screenWidth > 900) return baseFontSize * 1.1;
    if (screenWidth > 600) return baseFontSize * 1.05;
    return baseFontSize;
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

  @override
  Widget build(BuildContext context) {
    final records = Provider.of<EmotionProvider>(context).records;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isLargeScreen = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isMobile = screenWidth <= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CommonAppBar(title: '감정 캘린더', centerTitle: true, showBackButton: false),
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final responsivePadding = _getResponsivePadding(availableWidth);

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: responsivePadding,
                    right: responsivePadding,
                    top: 0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: (isLargeScreen)
                      ? _buildTwoColumnLayout(availableWidth)
                      : _buildSingleColumnLayout(availableWidth),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTwoColumnLayout(double screenWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽 컬럼 - 캘린더
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const SizedBox(height: 20), // 상단 패딩 추가
              _buildCalendarContainer(screenWidth),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout(double screenWidth) {
    return Column(
      children: [
        const SizedBox(height: 20), // 상단 패딩 추가
        _buildCalendarContainer(screenWidth),
        const SizedBox(height: 20),
        _buildEmotionInsights(screenWidth),
      ],
    );
  }

  Widget _buildCalendarContainer(double screenWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(screenWidth > 600 ? 24 : 20),
        decoration: BoxDecoration(
          color: (isDark ? LifewispColors.darkCardBg : Colors.white).withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.black).withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 달력 헤더
            _buildCalendarHeader(screenWidth),
            SizedBox(height: screenWidth > 600 ? 20 : 16),
            // 요일 헤더
            _buildWeekdayHeader(screenWidth),
            SizedBox(height: screenWidth > 600 ? 12 : 8),
            // 달력 그리드
            _buildCalendarGrid(screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(double screenWidth) {
    final headerFontSize = _getResponsiveFontSize(screenWidth, 18.0);
    final iconSize = screenWidth > 600 ? 28.0 : 24.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, size: iconSize),
          onPressed: () {
            setState(() {
              selectedDate = DateTime(
                selectedDate.year,
                selectedDate.month - 1,
              );
            });
          },
          color: isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
        ),
        Text(
          '${selectedDate.year}년 ${selectedDate.month}월',
          style: GoogleFonts.notoSans(
            fontSize: headerFontSize,
            fontWeight: FontWeight.w600,
            color: isDark ? LifewispColors.darkMainText : LifewispColors.darkGray,
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, size: iconSize),
          onPressed: () {
            setState(() {
              selectedDate = DateTime(
                selectedDate.year,
                selectedDate.month + 1,
              );
            });
          },
          color: isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(double screenWidth) {
    final weekdayFontSize = _getResponsiveFontSize(screenWidth, 14.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      child: Row(
        children: ['일', '월', '화', '수', '목', '금', '토']
            .map((day) => Expanded(
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: Text(
              day,
              style: GoogleFonts.notoSans(
                fontSize: weekdayFontSize,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkSubText : Colors.grey[600],
              ),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(double screenWidth) {
    final records = Provider.of<EmotionProvider>(context).records;
    final emotionData = _getEmotionData(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 데모 데이터 추가 (실제 데이터가 없을 때)
    final demoRecords = [
      EmotionRecord(date: DateTime(selectedDate.year, selectedDate.month, 5), emotion: 'happy', diary: '행복한 하루'),
      EmotionRecord(date: DateTime(selectedDate.year, selectedDate.month, 12), emotion: 'excited', diary: '신나는 하루'),
      EmotionRecord(date: DateTime(selectedDate.year, selectedDate.month, 18), emotion: 'calm', diary: '평온한 하루'),
      EmotionRecord(date: DateTime(selectedDate.year, selectedDate.month, 25), emotion: 'love', diary: '사랑스러운 하루'),
    ];

    final allRecords = records.isEmpty ? demoRecords : records;

    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final weekDay = firstDay.weekday % 7;
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    return Container(
      width: double.infinity,
      child: Column(
        children: List.generate(6, (weekIndex) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final index = weekIndex * 7 + dayIndex;
                final dayNum = index - weekDay + 1;

                if (dayNum < 1 || dayNum > daysInMonth) {
                  return Expanded(
                    child: Container(
                      height: screenWidth > 600 ? 65 : 55,
                      child: const SizedBox(),
                    ),
                  );
                }

                // 실제 기록 데이터에서 해당 날짜의 감정 찾기
                final record = allRecords.firstWhere(
                      (r) => r.date.year == selectedDate.year &&
                      r.date.month == selectedDate.month &&
                      r.date.day == dayNum,
                  orElse: () => EmotionRecord(date: DateTime(2000), emotion: '', diary: ''),
                );
                final emotion = record.emotion;
                final emotionInfo = emotion.isNotEmpty ? emotionData[emotion] : null;

                final isToday = dayNum == DateTime.now().day &&
                    selectedDate.month == DateTime.now().month &&
                    selectedDate.year == DateTime.now().year;

                final circleSize = screenWidth > 600 ? 43.0 : 35.0;

                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: GestureDetector(
                      onTap: () {
                        print('날짜 $dayNum 클릭됨, 감정: $emotion');
                      },
                      child: Container(
                        height: screenWidth > 600 ? 65 : 55,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 감정 동그라미
                            Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: emotionInfo != null
                                    ? emotionInfo['color'].withOpacity(0.15)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isToday
                                      ? (isDark ? LifewispColors.darkPrimary : LifewispColors.primary)
                                      : emotionInfo != null
                                      ? emotionInfo['color']
                                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                                  width: isToday ? 2.5 : (emotionInfo != null ? 2 : 1),
                                ),
                                boxShadow: emotionInfo != null ? [
                                  BoxShadow(
                                    color: emotionInfo['color'].withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : isToday ? [
                                  BoxShadow(
                                    color: (isDark ? LifewispColors.darkPrimary : LifewispColors.primary).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : [],
                              ),
                              child: emotionInfo != null
                                  ? ClipOval(
                                child: RabbitEmoticon(
                                  emotion: _mapStringToRabbitEmotion(emotion),
                                  size: circleSize - 4, // 테두리 고려하여 약간 작게
                                  backgroundColor: Colors.transparent,
                                  borderColor: Colors.transparent,
                                  borderWidth: 0,
                                ),
                              )
                                  : isToday
                                  ? Center(
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? LifewispColors.darkPrimary : LifewispColors.primary,
                                  ),
                                ),
                              )
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            // 날짜 숫자
                            Text(
                              '$dayNum',
                              style: GoogleFonts.notoSans(
                                fontSize: screenWidth > 600 ? 12 : 11,
                                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                color: isToday
                                    ? (isDark ? LifewispColors.darkPrimary : LifewispColors.primary)
                                    : emotionInfo != null
                                    ? emotionInfo['color']
                                    : (isDark ? LifewispColors.darkSubText : Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmotionInsights(double screenWidth) {
    final titleFontSize = _getResponsiveFontSize(screenWidth, 16.0);
    final contentFontSize = _getResponsiveFontSize(screenWidth, 14.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(screenWidth > 600 ? 24 : 20),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            colors: [LifewispColors.darkPurple, LifewispColors.darkPurpleDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [LifewispColors.purple, LifewispColors.purpleDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isDark ? LifewispColors.darkPurple : LifewispColors.purple).withOpacity(0.3),
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
                Text(
                  '✨',
                  style: TextStyle(fontSize: titleFontSize + 4),
                ),
                const SizedBox(width: 8),
                Text(
                  '이번 달 감정 인사이트',
                  style: GoogleFonts.notoSans(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: LifewispColors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth > 600 ? 16 : 12),
            Text(
              '이번 달에는 긍정적인 감정이 많이 나타났어요! 😊\n특히 주말에 행복한 순간들이 많았답니다.',
              style: GoogleFonts.notoSans(
                fontSize: contentFontSize,
                color: LifewispColors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
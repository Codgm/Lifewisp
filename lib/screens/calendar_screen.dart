import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/emotion_provider.dart';
import '../utils/emotion_utils.dart';
import 'dart:math';
import '../widgets/rabbit_emoticon.dart';

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

  // 감정 데이터 (실제로는 provider에서 가져올 데이터)
  final Map<String, dynamic> emotionData = {
    'happy': {'emoji': '😊', 'color': Color(0xFFFFD93D), 'name': '행복'},
    'sad': {'emoji': '😢', 'color': Color(0xFF6AB7FF), 'name': '슬픔'},
    'angry': {'emoji': '😠', 'color': Color(0xFFFF6B6B), 'name': '분노'},
    'excited': {'emoji': '🤩', 'color': Color(0xFFFF9F43), 'name': '흥분'},
    'calm': {'emoji': '😌', 'color': Color(0xFF4ECDC4), 'name': '평온'},
    'anxious': {'emoji': '😰', 'color': Color(0xFFAD7BFF), 'name': '불안'},
    'love': {'emoji': '🥰', 'color': Color(0xFFFF8FA3), 'name': '사랑'},
    'tired': {'emoji': '😪', 'color': Color(0xFF95A5A6), 'name': '피곤'},
  };

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

  int _getGridColumns(double screenWidth) {
    if (screenWidth > 1200) return 2; // 큰 화면에서는 2열 레이아웃
    return 1; // 기본적으로 1열
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isLargeScreen = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F4FD),
              Color(0xFFF0F8FF),
              Color(0xFFFFF0F5),
            ],
          ),
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
                    top: 8,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 커스텀 앱바 - 반응형 크기 조정
                      _buildResponsiveAppBar(availableWidth),

                      // 메인 컨텐츠 영역
                      if (isLargeScreen)
                        _buildTwoColumnLayout(availableWidth)
                      else
                        _buildSingleColumnLayout(availableWidth),
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

  Widget _buildResponsiveAppBar(double screenWidth) {
    final iconSize = screenWidth > 600 ? 20.0 : 18.0;
    final titleFontSize = _getResponsiveFontSize(screenWidth, 16.0);
    final containerSize = screenWidth > 600 ? 44.0 : 40.0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth > 600 ? 24 : 20,
          vertical: screenWidth > 600 ? 20 : 16
      ),
      child: Row(
        children: [
          // 뒤로가기 버튼
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(containerSize / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, size: iconSize),
              onPressed: () => Navigator.pop(context),
              color: const Color(0xFF6B73FF),
            ),
          ),
          const Spacer(),
          // 제목
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 24 : 20,
                vertical: screenWidth > 600 ? 12 : 8
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '📅',
                  style: TextStyle(fontSize: titleFontSize),
                ),
                const SizedBox(width: 8),
                Text(
                  '감정 캘린더',
                  style: GoogleFonts.notoSans(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 통계 버튼
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(containerSize / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.analytics_rounded, size: iconSize),
              onPressed: () {},
              color: const Color(0xFF6B73FF),
            ),
          ),
        ],
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
              _buildEmotionFilters(screenWidth),
              _buildCalendarContainer(screenWidth),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // 오른쪽 컬럼 - 통계 및 인사이트
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildEmotionStatistics(screenWidth),
              const SizedBox(height: 20),
              _buildEmotionInsights(screenWidth),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout(double screenWidth) {
    return Column(
      children: [
        _buildEmotionFilters(screenWidth),
        _buildCalendarContainer(screenWidth),
        const SizedBox(height: 20),
        _buildEmotionStatistics(screenWidth),
        const SizedBox(height: 20),
        _buildEmotionInsights(screenWidth),
      ],
    );
  }

  Widget _buildEmotionFilters(double screenWidth) {
    final chipHeight = screenWidth > 600 ? 56.0 : 50.0;
    final chipFontSize = _getResponsiveFontSize(screenWidth, 14.0);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: chipHeight,
        margin: const EdgeInsets.only(bottom: 20),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // 전체 보기 칩
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  '전체',
                  style: GoogleFonts.notoSans(
                    fontSize: chipFontSize,
                    fontWeight: FontWeight.w500,
                    color: filterEmotion == null
                        ? Colors.white
                        : const Color(0xFF6B73FF),
                  ),
                ),
                selected: filterEmotion == null,
                selectedColor: const Color(0xFF6B73FF),
                backgroundColor: Colors.white.withOpacity(0.9),
                onSelected: (_) => setState(() => filterEmotion = null),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                pressElevation: 0,
              ),
            ),
            // 감정별 필터 칩들
            ...emotionData.entries.map((entry) {
              final emotion = entry.key;
              final data = entry.value;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    data['name'],
                    style: GoogleFonts.notoSans(
                      fontSize: chipFontSize,
                      fontWeight: FontWeight.w500,
                      color: filterEmotion == emotion
                          ? Colors.white
                          : data['color'],
                    ),
                  ),
                  selected: filterEmotion == emotion,
                  selectedColor: data['color'],
                  backgroundColor: Colors.white.withOpacity(0.9),
                  onSelected: (_) => setState(() => filterEmotion = emotion),
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
    );
  }

  Widget _buildCalendarContainer(double screenWidth) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(screenWidth > 600 ? 24 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
          color: const Color(0xFF6B73FF),
        ),
        Text(
          '${selectedDate.year}년 ${selectedDate.month}월',
          style: GoogleFonts.notoSans(
            fontSize: headerFontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
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
          color: const Color(0xFF6B73FF),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(double screenWidth) {
    final weekdayFontSize = _getResponsiveFontSize(screenWidth, 14.0);
    final cellSize = screenWidth > 600 ? 48.0 : 40.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['일', '월', '화', '수', '목', '금', '토']
          .map((day) => Container(
        width: cellSize,
        height: cellSize,
        alignment: Alignment.center,
        child: Text(
          day,
          style: GoogleFonts.notoSans(
            fontSize: weekdayFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid(double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double availableWidth = constraints.maxWidth;
        double cellSize = (availableWidth - 48) / 7; // 좌우 여백 및 간격 고려
        double cellHeight = cellSize * 1.15; // 세로 비율 조정

        // 최소/최대 크기 제한
        cellSize = cellSize.clamp(32.0, 60.0);
        cellHeight = cellHeight.clamp(36.0, 70.0);

        return SizedBox(
          height: cellHeight * 6, // 6주
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: cellSize / cellHeight,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
              final weekDay = firstDay.weekday % 7;
              final dayNum = index - weekDay + 1;
              final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox();
              }

              // 더미 감정 데이터
              final hasEmotion = Random().nextBool();
              final emotions = emotionData.keys.toList();
              final randomEmotion = emotions[Random().nextInt(emotions.length)];
              final emotionInfo = hasEmotion ? emotionData[randomEmotion] : null;

              final isToday = dayNum == DateTime.now().day &&
                  selectedDate.month == DateTime.now().month &&
                  selectedDate.year == DateTime.now().year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    // 상세 정보 보기 등 추가 구현
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF6B73FF)
                        : emotionInfo != null
                        ? emotionInfo['color'].withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(cellSize * 0.28),
                    border: isToday
                        ? Border.all(
                      color: const Color(0xFF6B73FF),
                      width: 2,
                    )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: GoogleFonts.notoSans(
                          fontSize: (cellSize * 0.32).clamp(10.0, 16.0),
                          fontWeight: FontWeight.w500,
                          color: isToday
                              ? Colors.white
                              : const Color(0xFF2D3748),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (emotionInfo != null)
                        Padding(
                          padding: EdgeInsets.only(top: cellSize * 0.08),
                          child: SizedBox(
                            height: (cellSize * 0.48).clamp(12.0, 24.0),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: RabbitEmoticon(emotion: _mapStringToRabbitEmotion(randomEmotion)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmotionStatistics(double screenWidth) {
    final titleFontSize = _getResponsiveFontSize(screenWidth, 16.0);
    final itemFontSize = _getResponsiveFontSize(screenWidth, 14.0);
    final percentageFontSize = _getResponsiveFontSize(screenWidth, 12.0);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(screenWidth > 600 ? 24 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '📊',
                  style: TextStyle(fontSize: titleFontSize + 4),
                ),
                Text(
                  '이번 달 감정 통계',
                  style: GoogleFonts.notoSans(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth > 600 ? 20 : 16),

            // 감정 통계 바
            ...emotionData.entries.take(4).map((entry) {
              final emotion = entry.key;
              final data = entry.value;
              final percentage = Random().nextDouble() * 0.8 + 0.1;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RabbitEmoticon(emotion: _mapStringToRabbitEmotion(emotion)),
                        const SizedBox(width: 8),
                        Text(
                          data['name'],
                          style: GoogleFonts.notoSans(
                            fontSize: itemFontSize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(percentage * 100).toInt()}%',
                          style: GoogleFonts.notoSans(
                            fontSize: percentageFontSize,
                            fontWeight: FontWeight.w600,
                            color: data['color'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: screenWidth > 600 ? 8 : 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: data['color'],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionInsights(double screenWidth) {
    final titleFontSize = _getResponsiveFontSize(screenWidth, 16.0);
    final contentFontSize = _getResponsiveFontSize(screenWidth, 14.0);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(screenWidth > 600 ? 24 : 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B73FF), Color(0xFF9333EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B73FF).withOpacity(0.3),
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
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth > 600 ? 16 : 12),
            Text(
              '이번 달에는 긍정적인 감정이 많이 나타났어요! 😊\n특히 주말에 행복한 순간들이 많았답니다.',
              style: GoogleFonts.notoSans(
                fontSize: contentFontSize,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
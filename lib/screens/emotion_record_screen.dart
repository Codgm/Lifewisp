import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/emotion_record.dart';
import '../providers/emotion_provider.dart';
import '../providers/user_provider.dart';
import '../utils/emotion_utils.dart';
import '../utils/theme.dart';
import '../widgets/rabbit_emoticon.dart';
import '../widgets/common_app_bar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EmotionRecordScreen extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialEmotion;
  final String? initialDiary;
  final bool isEdit;
  const EmotionRecordScreen({Key? key, this.initialDate, this.initialEmotion, this.initialDiary, this.isEdit = false}) : super(key: key);

  @override
  State<EmotionRecordScreen> createState() => _EnhancedEmotionRecordScreenState();
}

class _EnhancedEmotionRecordScreenState extends State<EmotionRecordScreen> with TickerProviderStateMixin {
  late DateTime selectedDate;
  String? selectedEmotion;
  late TextEditingController _controller;
  List<String> selectedCategories = [];
  List<File> selectedImages = [];
  List<Uint8List> selectedImageBytes = []; // For web compatibility
  static final Map<String, Uint8List> _webImageCache = {};

  // 애니메이션 컨트롤러들
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // 카테고리 데이터
  final Map<String, Map<String, dynamic>> categories = {
    '건강': {
      'icon': Icons.health_and_safety,
      'items': ['운동완료', '충분한수면', '건강식단', '금연', '금주', '명상']
    },
    '성취': {
      'icon': Icons.emoji_events,
      'items': ['목표달성', '새로운도전', '학습완료', '업무성공', '창작활동', '문제해결']
    },
    '관계': {
      'icon': Icons.people,
      'items': ['가족시간', '친구만남', '연인데이트', '새로운인연', '소통', '배려']
    },
    '취미': {
      'icon': Icons.palette,
      'items': ['독서', '영화감상', '음악감상', '요리', '여행', '게임']
    },
    '기타': {
      'icon': Icons.more_horiz,
      'items': ['날씨좋음', '맛있는음식', '좋은소식', '선물받음', '휴식', '반성']
    }
  };

  IconData _getCategoryItemIcon(String item) {
    switch (item) {
    // 건강 카테고리
      case '운동완료': return Icons.fitness_center;
      case '충분한수면': return Icons.bedtime;
      case '건강식단': return Icons.local_dining;
      case '금연': return Icons.smoke_free;
      case '금주': return Icons.no_drinks;
      case '명상': return Icons.self_improvement;

    // 성취 카테고리
      case '목표달성': return Icons.flag;
      case '새로운도전': return Icons.rocket_launch;
      case '학습완료': return Icons.school;
      case '업무성공': return Icons.work;
      case '창작활동': return Icons.palette;
      case '문제해결': return Icons.lightbulb;

    // 관계 카테고리
      case '가족시간': return Icons.family_restroom;
      case '친구만남': return Icons.group;
      case '연인데이트': return Icons.favorite;
      case '새로운인연': return Icons.handshake;
      case '소통': return Icons.chat;
      case '배려': return Icons.volunteer_activism;

    // 취미 카테고리
      case '독서': return Icons.menu_book;
      case '영화감상': return Icons.movie;
      case '음악감상': return Icons.music_note;
      case '요리': return Icons.restaurant;
      case '여행': return Icons.flight;
      case '게임': return Icons.sports_esports;

    // 기타 카테고리
      case '날씨좋음': return Icons.wb_sunny;
      case '맛있는음식': return Icons.restaurant_menu;
      case '좋은소식': return Icons.celebration;
      case '선물받음': return Icons.card_giftcard;
      case '휴식': return Icons.weekend;
      case '반성': return Icons.psychology;

      default: return Icons.circle;
    }
  }


  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    selectedEmotion = widget.initialEmotion;
    _controller = TextEditingController(text: widget.initialDiary ?? '');

    // 애니메이션 초기화
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // 반응형 도우미 메서드들
  double _getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  double _getScreenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  bool _isSmallScreen(BuildContext context) => _getScreenWidth(context) < 600;
  bool _isMediumScreen(BuildContext context) => _getScreenWidth(context) >= 600 && _getScreenWidth(context) < 1024;
  bool _isLargeScreen(BuildContext context) => _getScreenWidth(context) >= 1024;

  double _getResponsivePadding(BuildContext context) {
    if (_isSmallScreen(context)) return 16.0;
    if (_isMediumScreen(context)) return 32.0;
    return 48.0;
  }

  double _getResponsiveCardPadding(BuildContext context) {
    if (_isSmallScreen(context)) return 16.0;
    if (_isMediumScreen(context)) return 20.0;
    return 24.0;
  }

  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (_isSmallScreen(context)) return baseFontSize * 0.9;
    if (_isMediumScreen(context)) return baseFontSize;
    return baseFontSize * 1.1;
  }

  int _getCrossAxisCount(BuildContext context) {
    if (_isSmallScreen(context)) return 4;
    if (_isMediumScreen(context)) return 5;
    return 6;
  }

// 그리고 이모티콘 크기도 약간 조정하는 것이 좋습니다:
  double _getEmotionSize(BuildContext context) {
    if (_isSmallScreen(context)) return 55.0;
    if (_isMediumScreen(context)) return 65.0;
    return 75.0;
  }

  double _getPhotoSize(BuildContext context) {
    if (_isSmallScreen(context)) return 100.0;
    if (_isMediumScreen(context)) return 120.0;
    return 140.0;
  }

  double _getMaxWidth(BuildContext context) {
    if (_isLargeScreen(context)) return 800.0;
    return double.infinity;
  }

  // Web-compatible image widget
  Widget _buildImageWidget(dynamic image, {double? width, double? height, BoxFit? fit}) {
    if (kIsWeb) {
      // For web, use Image.memory with Uint8List
      if (image is Uint8List) {
        return Image.memory(
          image,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.grey[500],
              ),
            );
          },
        );
      }
    } else {
      // For mobile, use Image.file with File
      if (image is File) {
        return Image.file(
          image,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: Icon(
                Icons.broken_image_rounded,
                color: Colors.grey[500],
              ),
            );
          },
        );
      }
    }

    // Fallback
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported_rounded,
        color: Colors.grey[500],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();
    final screenWidth = _getScreenWidth(context);
    final maxWidth = _getMaxWidth(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CommonAppBar(
          title: widget.isEdit ? '감정 기록 수정' : '감정 기록',
          emoji: '📝'
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Container(
              width: maxWidth,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(_getResponsivePadding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 날짜 선택 섹션
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildDateSection(isDark),
                      ),

                      SizedBox(height: _isSmallScreen(context) ? 16 : 24),

                      // 감정 선택 섹션
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildEmotionSection(isDark),
                      ),

                      SizedBox(height: _isSmallScreen(context) ? 16 : 24),

                      // 카테고리 선택 섹션
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildCategorySection(isDark),
                      ),

                      SizedBox(height: _isSmallScreen(context) ? 16 : 24),

                      // 사진 업로드 섹션
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildPhotoSection(isDark),
                      ),

                      SizedBox(height: _isSmallScreen(context) ? 16 : 24),

                      // 일기 입력 섹션
                      SlideTransition(
                        position: _slideAnimation,
                        child: _buildDiarySection(isDark),
                      ),

                      SizedBox(height: _isSmallScreen(context) ? 24 : 32),

                      // 저장 버튼
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildSaveButton(isDark),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(_getResponsiveCardPadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            LifewispColors.darkCardBg.withOpacity(0.9),
            LifewispColors.darkCardBg.withOpacity(0.7),
          ]
              : [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: _isSmallScreen(context) ? 15 : 20,
            offset: Offset(0, _isSmallScreen(context) ? 6 : 8),
          ),
        ],
        border: isDark
            ? Border.all(color: LifewispColors.darkPrimary.withOpacity(0.3))
            : Border.all(color: LifewispColors.accent.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(_isSmallScreen(context) ? 10 : 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDark
                    ? [LifewispColors.darkPrimary, LifewispColors.darkPrimary.withOpacity(0.7)]
                    : [LifewispColors.accent, LifewispColors.accent.withOpacity(0.7)],
              ),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: _isSmallScreen(context) ? 18 : 20,
            ),
          ),
          SizedBox(width: _isSmallScreen(context) ? 12 : 16),
          Flexible(
            child: TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Text(
                '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                style: LifewispTextStyles.getStaticFont(
                  context,
                  fontSize: _getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LifewispColors.darkMainText
                      : LifewispColors.mainText,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _buildEmotionSection 메서드를 다음과 같이 수정하세요:

  Widget _buildEmotionSection(bool isDark) {
    final emotionSize = _getEmotionSize(context);
    final crossAxisCount = _getCrossAxisCount(context);

    return Container(
      padding: EdgeInsets.all(_getResponsiveCardPadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            LifewispColors.darkCardBg.withOpacity(0.9),
            LifewispColors.darkCardBg.withOpacity(0.7),
          ]
              : [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: _isSmallScreen(context) ? 15 : 20,
            offset: Offset(0, _isSmallScreen(context) ? 6 : 8),
          ),
        ],
        border: isDark
            ? Border.all(color: LifewispColors.darkPrimary.withOpacity(0.3))
            : Border.all(color: LifewispColors.accent.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '😊',
                style: LifewispTextStyles.getStaticFont(context, fontSize: _isSmallScreen(context) ? 20 : 24),
              ),
              SizedBox(width: _isSmallScreen(context) ? 8 : 12),
              Flexible(
                child: Text(
                  '오늘의 기분은 어떠세요?',
                  style: LifewispTextStyles.getStaticFont(
                    context,
                    fontSize: _getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LifewispColors.darkMainText
                        : LifewispColors.mainText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: _isSmallScreen(context) ? 16 : 24),
          // Wrap 사용으로 변경
          Wrap(
            spacing: _isSmallScreen(context) ? 8 : 12,
            runSpacing: _isSmallScreen(context) ? 12 : 16,
            alignment: WrapAlignment.center,
            children: emotionEmoji.entries.map((e) {
              final isSelected = selectedEmotion == e.key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedEmotion = e.key;
                  });
                },
                child: AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    width: emotionSize + 20, // 고정 너비로 overflow 방지
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 이모티콘 컨테이너 - 선택 상태에 따른 배경
                        Container(
                          padding: EdgeInsets.all(_isSmallScreen(context) ? 8 : 12),
                          decoration: isSelected ? BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [LifewispColors.darkPrimary.withOpacity(0.2), LifewispColors.darkPrimary.withOpacity(0.1)]
                                  : [LifewispColors.accent.withOpacity(0.2), LifewispColors.accent.withOpacity(0.1)],
                            ),
                            border: Border.all(
                              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                              width: 2,
                            ),
                          ) : null,
                          child: RabbitEmoticon(
                            emotion: _mapStringToRabbitEmotion(e.key),
                            size: emotionSize * 0.7, // 크기 조정
                          ),
                        ),
                        SizedBox(height: _isSmallScreen(context) ? 6 : 8),
                        // 선택된 상태를 나타내는 인디케이터
                        Container(
                          height: _isSmallScreen(context) ? 3 : 4,
                          width: _isSmallScreen(context) ? 30 : 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: _isSmallScreen(context) ? 4 : 6),
                        // 감정 텍스트
                        Text(
                          e.key,
                          style: LifewispTextStyles.getStaticFont(
                            context,
                            fontSize: _getResponsiveFontSize(context, _isSmallScreen(context) ? 11 : 12),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                                : (isDark ? LifewispColors.darkSubText : LifewispColors.subText),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(_getResponsiveCardPadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            LifewispColors.darkCardBg.withOpacity(0.9),
            LifewispColors.darkCardBg.withOpacity(0.7),
          ]
              : [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: _isSmallScreen(context) ? 15 : 20,
            offset: Offset(0, _isSmallScreen(context) ? 6 : 8),
          ),
        ],
        border: isDark
            ? Border.all(color: LifewispColors.darkPrimary.withOpacity(0.3))
            : Border.all(color: LifewispColors.accent.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🏷️',
                style: TextStyle(fontSize: _isSmallScreen(context) ? 20 : 24),
              ),
              SizedBox(width: _isSmallScreen(context) ? 8 : 12),
              Flexible(
                child: Text(
                  '오늘 하루를 간단히 표현해보세요',
                  style: LifewispTextStyles.getStaticFont(
                    context,
                    fontSize: _getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LifewispColors.darkMainText
                        : LifewispColors.mainText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _isSmallScreen(context) ? 16 : 20),
          ...categories.entries.map((category) => _buildCategoryGroup(category, isDark)).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryGroup(MapEntry<String, Map<String, dynamic>> category, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: _isSmallScreen(context) ? 8 : 12),
          child: Row(
            children: [
              Container( // 아이콘을 컨테이너로 감싸서 배경 추가
                padding: EdgeInsets.all(_isSmallScreen(context) ? 6 : 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? LifewispColors.darkPrimary.withOpacity(0.1)
                      : LifewispColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.value['icon'],
                  size: _isSmallScreen(context) ? 16 : 18,
                  color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
                ),
              ),
              SizedBox(width: 12),
              Text(
                category.key,
                style: LifewispTextStyles.getStaticFont(
                  context,
                  fontSize: _getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: _isSmallScreen(context) ? 6 : 8,
          runSpacing: _isSmallScreen(context) ? 6 : 8,
          children: (category.value['items'] as List<String>).map((item) {
            final isSelected = selectedCategories.contains(item);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedCategories.remove(item);
                  } else {
                    selectedCategories.add(item);
                  }
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                    horizontal: _isSmallScreen(context) ? 12 : 16,
                    vertical: _isSmallScreen(context) ? 8 : 10 // 패딩 조정
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                    colors: isDark
                        ? [LifewispColors.darkPrimary.withOpacity(0.8), LifewispColors.darkPrimary.withOpacity(0.6)]
                        : [LifewispColors.accent.withOpacity(0.8), LifewispColors.accent.withOpacity(0.6)],
                  )
                      : LinearGradient(
                    colors: isDark
                        ? [LifewispColors.darkCardBg.withOpacity(0.6), LifewispColors.darkCardBg.withOpacity(0.4)]
                        : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 16 : 20),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                        : (isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3)),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row( // 아이콘과 텍스트를 나란히 배치
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryItemIcon(item), // 개별 아이템 아이콘 함수
                      size: _isSmallScreen(context) ? 14 : 16,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? LifewispColors.darkSubText : LifewispColors.subText),
                    ),
                    SizedBox(width: 6),
                    Text(
                      item,
                      style: LifewispTextStyles.getStaticFont(
                        context,
                        fontSize: _getResponsiveFontSize(context, 14),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? LifewispColors.darkSubText : LifewispColors.subText),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: _isSmallScreen(context) ? 12 : 16),
      ],
    );
  }

  Widget _buildPhotoSection(bool isDark) {
    final photoSize = _getPhotoSize(context);

    return Container(
      padding: EdgeInsets.all(_getResponsiveCardPadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            LifewispColors.darkCardBg.withOpacity(0.9),
            LifewispColors.darkCardBg.withOpacity(0.7),
          ]
              : [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: _isSmallScreen(context) ? 15 : 20,
            offset: Offset(0, _isSmallScreen(context) ? 6 : 8),
          ),
        ],
        border: isDark
            ? Border.all(color: LifewispColors.darkPrimary.withOpacity(0.3))
            : Border.all(color: LifewispColors.accent.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📷',
                style: TextStyle(fontSize: _isSmallScreen(context) ? 20 : 24),
              ),
              SizedBox(width: _isSmallScreen(context) ? 8 : 12),
              Flexible(
                child: Text(
                  '소중한 순간을 사진으로 남겨보세요',
                  style: LifewispTextStyles.getStaticFont(
                    context,
                    fontSize: _getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LifewispColors.darkMainText
                        : LifewispColors.mainText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _isSmallScreen(context) ? 16 : 20),
          if ((kIsWeb ? selectedImageBytes.isNotEmpty : selectedImages.isNotEmpty)) ...[
            Container(
              height: photoSize,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (kIsWeb ? selectedImageBytes.length : selectedImages.length) + 1,
                itemBuilder: (context, index) {
                  if (index == (kIsWeb ? selectedImageBytes.length : selectedImages.length)) {
                    return _buildAddPhotoButton(isDark, photoSize);
                  }
                  return _buildPhotoItem(
                      kIsWeb ? selectedImageBytes[index] : selectedImages[index],
                      index,
                      isDark,
                      photoSize
                  );
                },
              ),
            ),
          ] else ...[
            _buildAddPhotoButton(isDark, photoSize),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton(bool isDark, double size) {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        width: size,
        height: size,
        margin: EdgeInsets.only(right: _isSmallScreen(context) ? 8 : 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 12 : 16),
          border: Border.all(
            color: isDark ? LifewispColors.darkPrimary.withOpacity(0.4) : LifewispColors.accent.withOpacity(0.4),
            width: 2,
            style: BorderStyle.solid,
          ),
          gradient: LinearGradient(
            colors: isDark
                ? [LifewispColors.darkPrimary.withOpacity(0.1), LifewispColors.darkPrimary.withOpacity(0.05)]
                : [LifewispColors.accent.withOpacity(0.1), LifewispColors.accent.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: _isSmallScreen(context) ? 24 : 32,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(height: _isSmallScreen(context) ? 4 : 8),
            Text(
              '사진 추가',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 12),
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(dynamic image, int index, bool isDark, double size) {
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(right: _isSmallScreen(context) ? 8 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 12 : 16),
            child: _buildImageWidget(
              image,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: _isSmallScreen(context) ? 6 : 8,
            right: _isSmallScreen(context) ? 6 : 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (kIsWeb) {
                    selectedImageBytes.removeAt(index);
                  } else {
                    selectedImages.removeAt(index);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.all(_isSmallScreen(context) ? 3 : 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: _isSmallScreen(context) ? 14 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiarySection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(_getResponsiveCardPadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            LifewispColors.darkCardBg.withOpacity(0.9),
            LifewispColors.darkCardBg.withOpacity(0.7),
          ]
              : [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: _isSmallScreen(context) ? 15 : 20,
            offset: Offset(0, _isSmallScreen(context) ? 6 : 8),
          ),
        ],
        border: isDark
            ? Border.all(color: LifewispColors.darkPrimary.withOpacity(0.3))
            : Border.all(color: LifewispColors.accent.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '✍️',
                style: TextStyle(fontSize: _isSmallScreen(context) ? 20 : 24),
              ),
              SizedBox(width: _isSmallScreen(context) ? 8 : 12),
              Flexible(
                child: Text(
                  '더 자세한 이야기가 있다면?',
                  style: LifewispTextStyles.getStaticFont(
                    context,
                    fontSize: _getResponsiveFontSize(context, context.watch<UserProvider>().fontSize + 2),
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? LifewispColors.darkMainText
                        : LifewispColors.mainText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _isSmallScreen(context) ? 16 : 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 12 : 16),
              gradient: LinearGradient(
                colors: isDark
                    ? [
                  LifewispColors.darkPrimary.withOpacity(0.08),
                  LifewispColors.darkPrimary.withOpacity(0.04),
                ]
                    : [
                  LifewispColors.accent.withOpacity(0.08),
                  LifewispColors.accent.withOpacity(0.04),
                ],
              ),
            ),
            child: TextField(
              controller: _controller,
              maxLines: _isSmallScreen(context) ? 5 : 6,
              decoration: InputDecoration(
                hintText: '오늘 하루의 특별한 순간이나 느낌을\n자유롭게 적어보세요...',
                hintStyle: LifewispTextStyles.getStaticFont(
                  context,
                  color: isDark
                      ? LifewispColors.darkSubText.withOpacity(0.7)
                      : LifewispColors.subText.withOpacity(0.7),
                  fontSize: _getResponsiveFontSize(context, 15),
                  height: 1.5,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 12 : 16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(_isSmallScreen(context) ? 16 : 20),
              ),
              style: LifewispTextStyles.getStaticFont(
                context,
                fontSize: _getResponsiveFontSize(context, context.watch<UserProvider>().fontSize - 1),
                height: 1.6,
                color: isDark
                    ? LifewispColors.darkMainText
                    : LifewispColors.mainText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    final bool hasContent = selectedEmotion != null ||
        selectedCategories.isNotEmpty ||
        (kIsWeb ? selectedImageBytes.isNotEmpty : selectedImages.isNotEmpty) ||
        (_controller.text.trim().isNotEmpty);

    return Container(
      width: double.infinity,
      height: _isSmallScreen(context) ? 50 : 60,
      constraints: BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        gradient: hasContent
            ? LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDark
              ? [LifewispColors.darkPrimary, LifewispColors.darkPrimary.withOpacity(0.8)]
              : [LifewispColors.accent, LifewispColors.accentDark],
        )
            : LinearGradient(
          colors: isDark
              ? [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.2)]
              : [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 16 : 20),
        boxShadow: hasContent
            ? [
          BoxShadow(
            color: isDark
                ? LifewispColors.darkPrimary.withOpacity(0.4)
                : LifewispColors.accent.withOpacity(0.4),
            blurRadius: _isSmallScreen(context) ? 15 : 20,
            offset: Offset(0, _isSmallScreen(context) ? 8 : 10),
          ),
        ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: hasContent ? () {
          // 이미지 파일 경로 리스트 생성 (수정된 부분)
          List<String> imagePaths = [];

          if (kIsWeb) {
            // 웹에서는 EmotionProvider를 통해 이미지 저장
            imagePaths = EmotionProvider.saveWebImages(selectedImageBytes);
          } else {
            // 모바일에서는 기존대로 파일 경로 사용
            imagePaths = selectedImages.map((file) => file.path).toList();
          }

          final record = EmotionRecord(
            date: selectedDate,
            emotion: selectedEmotion ?? 'happy',
            diary: _controller.text?.trim() ?? '',
            categories: List.from(selectedCategories),
            imagePaths: imagePaths,
          );

          if (widget.isEdit) {
            Navigator.pop(context, record);
          } else {
            context.read<EmotionProvider>().addRecord(record);
            Navigator.pop(context);
          }
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 16 : 20),
          ),
          disabledBackgroundColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isEdit ? Icons.edit_rounded : Icons.save_rounded,
              color: hasContent ? Colors.white : Colors.grey,
              size: _isSmallScreen(context) ? 20 : 24,
            ),
            SizedBox(width: _isSmallScreen(context) ? 8 : 12),
            Text(
              widget.isEdit ? '수정하기' : '저장하기',
              style: LifewispTextStyles.getStaticFont(
                context,
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.w700,
                color: hasContent ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.all(_getResponsiveCardPadding(context)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [LifewispColors.darkCardBg, LifewispColors.darkCardBg.withOpacity(0.9)]
                  : [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(_isSmallScreen(context) ? 20 : 24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.4) : Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: _isSmallScreen(context) ? 16 : 24),
                Text(
                  '사진 선택',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.w700,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                ),
                SizedBox(height: _isSmallScreen(context) ? 16 : 24),
                if (_isSmallScreen(context)) ...[
                  // Stack buttons vertically on small screens
                  _buildImageSourceButton(
                    icon: Icons.camera_alt,
                    label: '카메라',
                    onTap: () => _pickImage(ImageSource.camera),
                    isDark: isDark,
                  ),
                  SizedBox(height: 12),
                  _buildImageSourceButton(
                    icon: Icons.photo_library,
                    label: '갤러리',
                    onTap: () => _pickImage(ImageSource.gallery),
                    isDark: isDark,
                  ),
                ] else ...[
                  // Side by side on larger screens
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageSourceButton(
                          icon: Icons.camera_alt,
                          label: '카메라',
                          onTap: () => _pickImage(ImageSource.camera),
                          isDark: isDark,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildImageSourceButton(
                          icon: Icons.photo_library,
                          label: '갤러리',
                          onTap: () => _pickImage(ImageSource.gallery),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: _isSmallScreen(context) ? 16 : 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: _isSmallScreen(context) ? 16 : 20
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [LifewispColors.darkPrimary.withOpacity(0.1), LifewispColors.darkPrimary.withOpacity(0.05)]
                : [LifewispColors.accent.withOpacity(0.1), LifewispColors.accent.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(_isSmallScreen(context) ? 12 : 16),
          border: Border.all(
            color: isDark ? LifewispColors.darkPrimary.withOpacity(0.3) : LifewispColors.accent.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: _isSmallScreen(context) ? 28 : 32,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(height: _isSmallScreen(context) ? 6 : 8),
            Text(
              label,
              style: LifewispTextStyles.getStaticFont(
                context,
                fontSize: _getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        if (kIsWeb) {
          // For web, read the image as bytes
          image.readAsBytes().then((bytes) {
            setState(() {
              selectedImageBytes.add(bytes);
            });
          });
        } else {
          // For mobile, add as File
          selectedImages.add(File(image.path));
        }
      });
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
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'result_screen.dart';
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
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 날짜 선택 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildDateSection(isDark),
                  ),

                  SizedBox(height: 24),

                  // 감정 선택 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildEmotionSection(isDark),
                  ),

                  SizedBox(height: 24),

                  // 카테고리 선택 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildCategorySection(isDark),
                  ),

                  SizedBox(height: 24),

                  // 사진 업로드 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildPhotoSection(isDark),
                  ),

                  SizedBox(height: 24),

                  // 일기 입력 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildDiarySection(isDark),
                  ),

                  SizedBox(height: 32),

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
    );
  }

  Widget _buildDateSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
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
            padding: EdgeInsets.all(12),
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
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          TextButton(
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
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

  Widget _buildEmotionSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
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
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 12),
              Text(
                '오늘의 기분은 어떠세요?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LifewispColors.darkMainText
                      : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: emotionEmoji.entries.map((e) {
              final isSelected = selectedEmotion == e.key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedEmotion = e.key;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected
                        ? LinearGradient(
                      colors: isDark
                          ? [LifewispColors.darkPrimary, LifewispColors.darkPrimary.withOpacity(0.7)]
                          : [LifewispColors.accent, LifewispColors.accent.withOpacity(0.7)],
                    )
                        : LinearGradient(
                      colors: isDark
                          ? [LifewispColors.darkCardBg.withOpacity(0.8), LifewispColors.darkCardBg.withOpacity(0.6)]
                          : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? (isDark
                            ? LifewispColors.darkPrimary.withOpacity(0.4)
                            : LifewispColors.accent.withOpacity(0.3))
                            : (isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.black.withOpacity(0.06)),
                        blurRadius: isSelected ? 12 : 6,
                        offset: Offset(0, isSelected ? 6 : 3),
                      ),
                    ],
                    border: isSelected
                        ? Border.all(
                      color: isDark
                          ? LifewispColors.darkPrimary.withOpacity(0.5)
                          : LifewispColors.accent.withOpacity(0.4),
                      width: 2,
                    )
                        : Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: RabbitEmoticon(
                      emotion: _mapStringToRabbitEmotion(e.key),
                      size: 50,
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
      padding: EdgeInsets.all(24),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
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
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 12),
              Text(
                '오늘 하루를 간단히 표현해보세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LifewispColors.darkMainText
                      : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
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
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                category.value['icon'],
                size: 18,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
              SizedBox(width: 8),
              Text(
                category.key,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? LifewispColors.darkPrimary : LifewispColors.accent)
                        : (isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3)),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? LifewispColors.darkSubText : LifewispColors.subText),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhotoSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(24),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
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
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 12),
              Text(
                '소중한 순간을 사진으로 남겨보세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LifewispColors.darkMainText
                      : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if ((kIsWeb ? selectedImageBytes.isNotEmpty : selectedImages.isNotEmpty)) ...[
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (kIsWeb ? selectedImageBytes.length : selectedImages.length) + 1,
                itemBuilder: (context, index) {
                  if (index == (kIsWeb ? selectedImageBytes.length : selectedImages.length)) {
                    return _buildAddPhotoButton(isDark);
                  }
                  return _buildPhotoItem(
                    kIsWeb ? selectedImageBytes[index] : selectedImages[index], 
                    index, 
                    isDark
                  );
                },
              ),
            ),
          ] else ...[
            _buildAddPhotoButton(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton(bool isDark) {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        width: 120,
        height: 120,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
              size: 32,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(height: 8),
            Text(
              '사진 추가',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(dynamic image, int index, bool isDark) {
    return Container(
      width: 120,
      height: 120,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(16),
            child: _buildImageWidget(
              image,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
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
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
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
      padding: EdgeInsets.all(24),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
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
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 12),
              Text(
                '더 자세한 이야기가 있다면?',
                style: TextStyle(
                  fontSize: context.watch<UserProvider>().fontSize + 2,
                  fontFamily: context.watch<UserProvider>().selectedFont,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? LifewispColors.darkMainText
                      : LifewispColors.mainText,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '오늘 하루의 특별한 순간이나 느낌을\n자유롭게 적어보세요...',
                hintStyle: TextStyle(
                  color: isDark
                      ? LifewispColors.darkSubText.withOpacity(0.7)
                      : LifewispColors.subText.withOpacity(0.7),
                  fontSize: 15,
                  height: 1.5,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(20),
              ),
              style: TextStyle(
                fontSize: context.watch<UserProvider>().fontSize - 1,
                fontFamily: context.watch<UserProvider>().selectedFont,
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
      height: 60,
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: hasContent
            ? [
          BoxShadow(
            color: isDark
                ? LifewispColors.darkPrimary.withOpacity(0.4)
                : LifewispColors.accent.withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: hasContent ? () {
          // 이미지 파일 경로 리스트 생성 (웹에서는 임시 경로 사용)
          final imagePaths = kIsWeb 
              ? selectedImageBytes.asMap().entries.map((entry) => 'web_image_${entry.key}').toList()
              : selectedImages.map((file) => file.path).toList();

          final record = EmotionRecord(
            date: selectedDate,
            emotion: selectedEmotion ?? 'happy',
            diary: _controller.text?.trim() ?? '',
            categories: List.from(selectedCategories), // 선택된 카테고리들
            imagePaths: imagePaths, // 이미지 파일 경로들
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
            borderRadius: BorderRadius.circular(20),
          ),
          disabledBackgroundColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isEdit ? Icons.edit_rounded : Icons.save_rounded,
              color: hasContent ? Colors.white : Colors.grey,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              widget.isEdit ? '수정하기' : '저장하기',
              style: TextStyle(
                fontSize: 18,
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
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [LifewispColors.darkCardBg, LifewispColors.darkCardBg.withOpacity(0.9)]
                  : [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
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
              SizedBox(height: 24),
              Text(
                '사진 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
              ),
              SizedBox(height: 24),
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
              SizedBox(height: 24),
            ],
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
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [LifewispColors.darkPrimary.withOpacity(0.1), LifewispColors.darkPrimary.withOpacity(0.05)]
                : [LifewispColors.accent.withOpacity(0.1), LifewispColors.accent.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? LifewispColors.darkPrimary.withOpacity(0.3) : LifewispColors.accent.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isDark ? LifewispColors.darkPrimary : LifewispColors.accent,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
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
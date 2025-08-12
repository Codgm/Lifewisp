import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/emotion_record.dart';
import '../providers/emotion_provider.dart';
import '../utils/theme.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/rabbit_emoticon.dart';
import 'emotion_record_screen.dart';


class DiaryDetailScreen extends StatefulWidget {
  final EmotionRecord record;
  const DiaryDetailScreen({Key? key, required this.record}) : super(key: key);

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Web-compatible image widget - 수정된 버전
  Widget _buildImageWidget(String imagePath, bool isDark, {double? width, double? height}) {
    // 웹에서 이미지 처리
    if (kIsWeb) {
      // EmotionProvider에서 웹 이미지 데이터 가져오기
      final imageBytes = EmotionProvider.getWebImage(imagePath);

      if (imageBytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.memory(
            imageBytes,
            width: width ?? 160,
            height: height ?? 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImage(isDark, width, height);
            },
          ),
        );
      } else {
        // 캐시에 이미지가 없을 때 개선된 플레이스홀더 표시
        return Container(
          width: width ?? 160,
          height: height ?? 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? LifewispColors.darkCardBg : const Color(0xFFF8F9FA),
                isDark ? LifewispColors.darkCardBg.withOpacity(0.8) : const Color(0xFFE9ECEF),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? LifewispColors.darkCardBorder : const Color(0xFFDEE2E6),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_rounded,
                size: 32,
                color: isDark ? LifewispColors.darkPrimary : LifewispColors.purple,
              ),
              const SizedBox(height: 8),
              Text(
                '웹 이미지',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '이미지를 불러올 수\n없습니다',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? LifewispColors.darkSubText : LifewispColors.subText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
    }

    // 모바일에서는 File로 이미지 표시
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            file,
            width: width ?? 160,
            height: height ?? 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImage(isDark, width, height);
            },
          ),
        );
      } else {
        return _buildFileNotFoundImage(isDark, width, height);
      }
    } catch (e) {
      return _buildErrorImage(isDark, width, height);
    }
  }

  // 에러 이미지 위젯
  Widget _buildErrorImage(bool isDark, double? width, double? height) {
    return Container(
      width: width ?? 160,
      height: height ?? 200,
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? LifewispColors.darkCardBorder : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            size: 40,
            color: isDark ? LifewispColors.darkSubText : Colors.grey[500],
          ),
          const SizedBox(height: 8),
          Text(
            '이미지를 불러올 수\n없습니다',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? LifewispColors.darkSubText : Colors.grey[500],
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 파일 없음 이미지 위젯
  Widget _buildFileNotFoundImage(bool isDark, double? width, double? height) {
    return Container(
      width: width ?? 160,
      height: height ?? 200,
      decoration: BoxDecoration(
        color: isDark ? LifewispColors.darkCardBg : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? LifewispColors.darkCardBorder : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_rounded,
            size: 40,
            color: isDark ? LifewispColors.darkSubText : Colors.grey[500],
          ),
          const SizedBox(height: 8),
          Text(
            '이미지 파일이\n없습니다',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? LifewispColors.darkSubText : Colors.grey[500],
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 감정에 따른 RabbitEmotion 매핑 함수
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

  // 감정에 따른 색상 반환 함수 (theme.dart 색상 사용)
  Color _getEmotionColor(String emotion, BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    switch (emotion.toLowerCase()) {
      case 'happy':
        return isDark ? LifewispColors.darkYellow : const Color(0xFFFFB800);
      case 'sad':
        return isDark ? LifewispColors.darkBlue : const Color(0xFF4A90E2);
      case 'angry':
        return isDark ? LifewispColors.darkRed : const Color(0xFFE74C3C);
      case 'excited':
        return isDark ? LifewispColors.darkOrange : const Color(0xFFFF6B35);
      case 'calm':
        return isDark ? LifewispColors.darkGreen : const Color(0xFF27AE60);
      case 'anxious':
        return isDark ? LifewispColors.darkPurple : const Color(0xFF9B59B6);
      case 'love':
        return isDark ? LifewispColors.darkPink : LifewispColors.pink;
      case 'tired':
        return isDark ? LifewispColors.darkLightGray : const Color(0xFF7F8C8D);
      case 'despair':
        return isDark ? LifewispColors.darkBlack : const Color(0xFF2C3E50);
      case 'confidence':
        return isDark ? LifewispColors.darkMint : const Color(0xFF1ABC9C);
      default:
        return isDark ? LifewispColors.darkLightGray : const Color(0xFF7F8C8D);
    }
  }

  List<Widget> _buildResponsiveActions(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // 기본 액션 버튼들
    final allActions = [
      _buildActionButton(
        context,
        icon: Icons.share_rounded,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4FACFE),
            Color(0xFF00F2FE),
          ],
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/share');
        },
      ),
      _buildActionButton(
        context,
        icon: Icons.edit_rounded,
        backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
        iconColor: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
        onPressed: () async {
          final updated = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, _) => EmotionRecordScreen(
                initialDate: widget.record.date,
                initialEmotion: widget.record.emotion,
                initialDiary: widget.record.diary,
                isEdit: true,
              ),
              transitionsBuilder: (context, animation, _, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  )),
                  child: child,
                );
              },
            ),
          );
          if (updated != null && updated is EmotionRecord) {
            context.read<EmotionProvider>().editRecord(widget.record, updated);
          }
        },
      ),
      _buildActionButton(
        context,
        icon: Icons.delete_outline_rounded,
        gradient: LinearGradient(
          colors: [
            LifewispColors.pink,
            LifewispColors.pinkAccent,
          ],
        ),
        onPressed: () => _showDeleteDialog(context),
      ),
    ];

    // 작은 화면에서는 더보기 메뉴 사용
    if (isSmallScreen) {
      return [
        allActions[0], // 공유 버튼은 항상 표시
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? LifewispColors.darkCardBg : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.more_vert_rounded,
              color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
              size: 18,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.2),
          color: isDark ? LifewispColors.darkCardBg : Colors.white,
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '수정',
                    style: TextStyle(
                      color: isDark ? LifewispColors.darkMainText : LifewispColors.mainText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: LifewispColors.pink,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '삭제',
                    style: TextStyle(
                      color: LifewispColors.pink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                final updated = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, _) => EmotionRecordScreen(
                      initialDate: widget.record.date,
                      initialEmotion: widget.record.emotion,
                      initialDiary: widget.record.diary,
                      isEdit: true,
                    ),
                    transitionsBuilder: (context, animation, _, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOutCubic,
                        )),
                        child: child,
                      );
                    },
                  ),
                );
                if (updated != null && updated is EmotionRecord) {
                  context.read<EmotionProvider>().editRecord(widget.record, updated);
                }
                break;
              case 'delete':
                _showDeleteDialog(context);
                break;
            }
          },
        ),
        const SizedBox(width: 8),
      ];
    }

    // 일반 화면에서는 모든 버튼 표시
    return [
      ...allActions,
      const SizedBox(width: 16),
    ];
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    Gradient? gradient,
    Color? backgroundColor,
    Color? iconColor,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // 반응형 크기 설정
    final buttonSize = screenWidth < 360 ? 36.0 : (screenWidth < 600 ? 40.0 : 44.0);
    final iconSize = screenWidth < 360 ? 16.0 : (screenWidth < 600 ? 18.0 : 20.0);

    return Container(
      width: buttonSize,
      height: buttonSize,
      margin: EdgeInsets.only(right: screenWidth < 360 ? 4.0 : 8.0),
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(screenWidth < 360 ? 12.0 : 16.0),
        boxShadow: [
          BoxShadow(
            color: (gradient != null
                ? gradient.colors.first
                : (backgroundColor ?? Colors.grey)).withOpacity(0.3),
            blurRadius: screenWidth < 360 ? 8.0 : 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(screenWidth < 360 ? 12.0 : 16.0),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LifewispGradients.onboardingBgFor('emotion', dark: isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // CommonAppBar 사용
              CommonAppBar(
                title: '오늘의 감정 일기',
                emoji: '📔',
                showBackButton: true,
                actions: _buildResponsiveActions(context, isDark),
              ),

              // 메인 콘텐츠
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 감정 카드 (RabbitEmoticon 사용)
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  isDark ? LifewispColors.darkCardBg : Colors
                                      .white,
                                  isDark ? LifewispColors.darkCardBg
                                      .withOpacity(0.95) : Colors.white
                                      .withOpacity(0.95),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? Colors.black : Colors.black)
                                      .withOpacity(isDark ? 0.3 : 0.1),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // RabbitEmoticon 사용
                                RabbitEmoticon(
                                  emotion: _getEmotionType(
                                      widget.record.emotion),
                                  size: 140,
                                ),

                                const SizedBox(height: 28),

                                // 감정 라벨
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _getEmotionColor(widget.record.emotion,
                                            context).withOpacity(0.2),
                                        _getEmotionColor(widget.record.emotion,
                                            context).withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _getEmotionColor(
                                          widget.record.emotion, context)
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.record.emotion.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _getEmotionColor(
                                          widget.record.emotion, context),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // 날짜
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? LifewispColors.darkCardBg
                                        .withOpacity(0.5) : const Color(
                                        0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDark ? LifewispColors
                                          .darkCardBorder : const Color(
                                          0xFFE9ECEF),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isDark ? Colors.black : Colors
                                            .black).withOpacity(
                                            isDark ? 0.2 : 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${widget.record.date.year}년 ${widget.record
                                        .date.month}월 ${widget.record.date
                                        .day}일',
                                    style: LifewispTextStyles.getStaticFont(
                                        context).copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 카테고리 표시 (추가된 부분)
                        if (widget.record.categories != null &&
                            widget.record.categories!.isNotEmpty) ...[
                          SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    isDark ? LifewispColors.darkCardBg : Colors
                                        .white,
                                    isDark ? LifewispColors.darkCardBg
                                        .withOpacity(0.98) : Colors.white
                                        .withOpacity(0.98),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : Colors
                                        .black).withOpacity(
                                        isDark ? 0.3 : 0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              LifewispColors.purple.withOpacity(
                                                  0.2),
                                              LifewispColors.purple.withOpacity(
                                                  0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              16),
                                          border: Border.all(
                                            color: LifewispColors.purple
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.local_offer_rounded,
                                          color: LifewispColors.purple,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '하루의 특별한 순간들',
                                        style: LifewispTextStyles.getStaticFont(
                                            context).copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: widget.record.categories!.map((
                                        category) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              _getEmotionColor(
                                                  widget.record.emotion,
                                                  context).withOpacity(0.15),
                                              _getEmotionColor(
                                                  widget.record.emotion,
                                                  context).withOpacity(0.08),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              20),
                                          border: Border.all(
                                            color: _getEmotionColor(
                                                widget.record.emotion, context)
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          category,
                                          style: LifewispTextStyles.getStaticFont(
                                            context,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _getEmotionColor(
                                                widget.record.emotion, context),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // 사진 표시 (수정된 부분)
                        if (widget.record.imagePaths != null &&
                            widget.record.imagePaths!.isNotEmpty) ...[
                          SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    isDark ? LifewispColors.darkCardBg : Colors
                                        .white,
                                    isDark ? LifewispColors.darkCardBg
                                        .withOpacity(0.98) : Colors.white
                                        .withOpacity(0.98),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : Colors
                                        .black).withOpacity(
                                        isDark ? 0.3 : 0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFF4FACFE)
                                                  .withOpacity(0.2),
                                              const Color(0xFF00F2FE)
                                                  .withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              16),
                                          border: Border.all(
                                            color: const Color(0xFF4FACFE)
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.photo_library_rounded,
                                          color: const Color(0xFF4FACFE),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '소중한 순간들',
                                        style: LifewispTextStyles.getStaticFont(
                                            context).copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: widget.record.imagePaths!
                                          .length,
                                      itemBuilder: (context, index) {
                                        final imagePath = widget.record
                                            .imagePaths![index];
                                        return Container(
                                          width: 160,
                                          margin: EdgeInsets.only(
                                            right: index <
                                                widget.record.imagePaths!
                                                    .length - 1 ? 16 : 0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                    0.1),
                                                blurRadius: 12,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: _buildImageWidget(
                                              imagePath, isDark),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // 일기 내용 카드
                        if (widget.record.diary
                            .trim()
                            .isNotEmpty) ...[
                          SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    isDark ? LifewispColors.darkCardBg : Colors
                                        .white,
                                    isDark ? LifewispColors.darkCardBg
                                        .withOpacity(0.98) : Colors.white
                                        .withOpacity(0.98),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : Colors
                                        .black).withOpacity(
                                        isDark ? 0.3 : 0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              LifewispColors.pink.withOpacity(
                                                  0.2),
                                              LifewispColors.pink.withOpacity(
                                                  0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              16),
                                          border: Border.all(
                                            color: LifewispColors.pink
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.auto_stories_rounded,
                                          color: LifewispColors.pink,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '오늘의 기록',
                                        style: LifewispTextStyles.getStaticFont(
                                            context).copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          isDark ? LifewispColors.darkCardBg
                                              .withOpacity(0.5) : const Color(
                                              0xFFF8F9FA),
                                          isDark ? LifewispColors.darkCardBg
                                              .withOpacity(0.3) : const Color(
                                              0xFFF1F3F4),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark ? LifewispColors
                                            .darkCardBorder : const Color(
                                            0xFFE9ECEF),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDark ? Colors.black : Colors
                                              .black).withOpacity(
                                              isDark ? 0.1 : 0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      widget.record.diary,
                                      style: LifewispTextStyles.getStaticFont(
                                          context).copyWith(
                                        fontSize: 18,
                                        height: 1.8,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // 감정 통계 미리보기 (개선된 디자인)
                        SlideTransition(
                          position: _slideAnimation,
                          child: GestureDetector(
                            onTap: () {
                              // 감정 통계 페이지로 이동
                              Navigator.pushNamed(context, '/statistics');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    LifewispColors.pink.withOpacity(0.15),
                                    LifewispColors.purple.withOpacity(0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: LifewispColors.pink.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: LifewispColors.pink.withOpacity(0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          isDark
                                              ? LifewispColors.darkCardBg
                                              : Colors.white,
                                          isDark ? LifewispColors.darkCardBg
                                              .withOpacity(0.95) : Colors.white
                                              .withOpacity(0.95),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDark ? Colors.black : Colors
                                              .black).withOpacity(
                                              isDark ? 0.3 : 0.1),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.analytics_rounded,
                                      color: LifewispColors.pink,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          '감정 통계 보러가기',
                                          style: LifewispTextStyles.getStaticFont(
                                              context).copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '나의 감정 패턴을 확인해보세요',
                                          style: LifewispTextStyles.getStaticFont(
                                              context).copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (isDark
                                          ? LifewispColors.darkCardBg
                                          : Colors.white).withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: LifewispColors.pink,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: isDark ? LifewispColors.darkCardBg : Colors.white,
            contentPadding: const EdgeInsets.all(32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LifewispColors.pink.withOpacity(0.2),
                        LifewispColors.pinkAccent.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: LifewispColors.pink.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: LifewispColors.pink,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '기록 삭제',
                  style: LifewispTextStyles.getStaticFont(context).copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '이 감정 기록을 삭제할까요?\n삭제된 기록은 복구할 수 없어요.',
                  textAlign: TextAlign.center,
                  style: LifewispTextStyles.getStaticFont(context).copyWith(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: LifewispTextStyles.getStaticFont(context).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<EmotionProvider>().deleteRecord(
                              widget.record);
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LifewispColors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: LifewispColors.pink.withOpacity(0.3),
                        ),
                        child: Text(
                          '삭제',
                          style: LifewispTextStyles.getStaticFont(
                            context,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      );
    }
  }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

// 🌸 온보딩 기반 메인 색상 (파스텔 그라데이션 테마)
final pastelPink = Color(0xFFFFE5F1); // 연한 핑크
final pastelBlue = Color(0xFFF0F8FF); // 연한 하늘색
final pastelMint = Color(0xFFE8F5E8); // 연한 민트
final pastelYellow = Color(0xFFFFF8E1); // 연한 노랑
final pastelPurple = Color(0xFFDDA0DD); // 연한 보라
final cherryPink = Color(0xFFFFB6C1); // 체리 핑크
final softPurple = Color(0xFF9B59B6); // 부드러운 보라
final brightPink = Color(0xFFFF6B9D); // 밝은 핑크

// 텍스트 가독성을 위한 진한 색상들
final darkText = Color(0xFF2D3748); // 진한 회색 (가독성 최우선)
final mediumText = Color(0xFF4A5568); // 중간 회색
final lightText = Color(0xFF718096); // 연한 회색
final whiteText = Color(0xFFFFFFFF); // 흰색 텍스트

// 🌙 다크모드 색상 (온보딩 테마의 어두운 버전)
final darkBackground = Color(0xFF1A1B23); // 깊은 네이비
final darkSurface = Color(0xFF2D2E36); // 어두운 표면
final darkCard = Color(0xFF373843); // 어두운 카드
final darkAccent = Color(0xFF6B46C1); // 어두운 보라 액센트
final darkPink = Color(0xFFEC4899); // 어두운 핑크
final darkMint = Color(0xFF10B981); // 어두운 민트

// 기존 변수들을 새로운 파스텔 테마로 업데이트
final lifewispPrimary = brightPink;
final lifewispAccent = softPurple;
final lifewispBlue = pastelBlue;
final lifewispGradient = [brightPink, softPurple, pastelBlue];
final lifewispCard = Colors.white;

// 기존 벚꽃 테마 색상들 (하위 호환성)
final cherryBlossomPink = brightPink;
final cherryBlossomLight = pastelPink;
final cherryBlossomWhite = Color(0xFFFCFCFD);
final cherryBlossomDeep = darkText;
final cherryBlossomAccent = cherryPink;

final bunnyPurple = pastelPurple;
final bunnyLavender = Color(0xFFE1BEE7);
final bunnyMint = pastelMint;

final cherryBlossomGradientColors = [pastelPink, brightPink, cherryBlossomWhite, bunnyLavender];

// 감정별 색상 (가독성 고려)
Map<String, Color> emotionColorFor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? {
    '😊': Color(0xFFFEF3C7), // 밝은 노랑
    '😢': Color(0xFF93C5FD), // 밝은 파랑
    '😡': Color(0xFFFCA5A5), // 밝은 빨강
    '😍': Color(0xFFF472B6), // 밝은 핑크
    '😱': Color(0xFFA78BFA), // 밝은 보라
  }
      : {
    '😊': Color(0xFFFEF3C7), // 밝은 노랑
    '😢': Color(0xFFDBEAFE), // 연한 파랑
    '😡': Color(0xFFFECDCD), // 연한 빨강
    '😍': pastelPink, // 연한 핑크
    '😱': pastelPurple, // 연한 보라
  };
}

Map<String, Color> emotionColorNameFor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? {
    'happy': Color(0xFFFEF3C7),
    'sad': Color(0xFF93C5FD),
    'angry': Color(0xFFFCA5A5),
    'love': Color(0xFFF472B6),
    'fear': Color(0xFFA78BFA),
  }
      : {
    'happy': Color(0xFFFFEB3B),
    'sad': Color(0xFF2196F3),
    'angry': Color(0xFFF44336),
    'love': brightPink,
    'fear': softPurple,
  };
}

// 정적 테마 (기본값) - Poor Story를 기본 폰트로 설정
ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: GoogleFonts.poorStory().fontFamily, // Poor Story를 기본 폰트로 설정
  scaffoldBackgroundColor: Color(0xFFFCFCFD),
  primaryColor: brightPink,
  colorScheme: ColorScheme.fromSeed(
    seedColor: brightPink,
    brightness: Brightness.light,
    background: Color(0xFFFCFCFD),
    surface: Colors.white,
    primary: brightPink,
    secondary: softPurple,
    tertiary: pastelMint,
    onPrimary: whiteText,
    onSecondary: whiteText,
    onSurface: darkText,
    onBackground: darkText,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poorStory(
      fontSize: 22,
      color: darkText,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: darkText),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    shadowColor: Colors.black.withOpacity(0.08),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: brightPink,
      foregroundColor: whiteText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      textStyle: GoogleFonts.poorStory(fontSize: 18, fontWeight: FontWeight.w600),
      elevation: 3,
      shadowColor: brightPink.withOpacity(0.3),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: brightPink,
    foregroundColor: whiteText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    elevation: 6,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: brightPink, width: 2),
    ),
    hintStyle: GoogleFonts.poorStory(color: lightText),
  ),
  textTheme: GoogleFonts.poorStoryTextTheme().copyWith(
    bodyMedium: GoogleFonts.poorStory(fontSize: 16, color: darkText),
    bodyLarge: GoogleFonts.poorStory(fontSize: 18, color: darkText),
    titleLarge: GoogleFonts.poorStory(fontSize: 22, color: darkText, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.poorStory(fontSize: 18, color: darkText, fontWeight: FontWeight.w500),
    labelLarge: GoogleFonts.poorStory(fontSize: 16, color: mediumText),
    bodySmall: GoogleFonts.poorStory(fontSize: 14, color: mediumText),
  ),
);

ThemeData lifewispDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.poorStory().fontFamily, // Poor Story를 기본 폰트로 설정
  scaffoldBackgroundColor: darkBackground,
  primaryColor: darkPink,
  colorScheme: ColorScheme.fromSeed(
    seedColor: darkPink,
    brightness: Brightness.dark,
    background: darkBackground,
    surface: darkSurface,
    primary: darkPink,
    secondary: darkAccent,
    tertiary: darkMint,
    onPrimary: whiteText,
    onSecondary: whiteText,
    onSurface: whiteText,
    onBackground: whiteText,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poorStory(
      fontSize: 22,
      color: whiteText,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: whiteText),
  ),
  cardTheme: CardThemeData(
    color: darkCard,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    shadowColor: Colors.black.withOpacity(0.3),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkPink,
      foregroundColor: whiteText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      textStyle: GoogleFonts.poorStory(fontSize: 18, fontWeight: FontWeight.w600),
      elevation: 3,
      shadowColor: darkPink.withOpacity(0.3),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: darkPink,
    foregroundColor: whiteText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    elevation: 6,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF404249),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xFF52525B), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Color(0xFF52525B), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: darkPink, width: 2),
    ),
    hintStyle: GoogleFonts.poorStory(color: Color(0xFF9CA3AF)),
  ),
  textTheme: GoogleFonts.poorStoryTextTheme().copyWith(
    bodyMedium: GoogleFonts.poorStory(fontSize: 16, color: whiteText),
    bodyLarge: GoogleFonts.poorStory(fontSize: 18, color: whiteText),
    titleLarge: GoogleFonts.poorStory(fontSize: 22, color: whiteText, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.poorStory(fontSize: 18, color: whiteText, fontWeight: FontWeight.w500),
    labelLarge: GoogleFonts.poorStory(fontSize: 16, color: Color(0xFFD1D5DB)),
    bodySmall: GoogleFonts.poorStory(fontSize: 14, color: Color(0xFFD1D5DB)),
  ),
);

// Custom color palette for all screens (온보딩 파스텔 테마 적용)
class LifewispColors {
  // 🌸 라이트 테마 색상
  static const Color statCardBg = Colors.white;
  static const Color statCardText = Color(0xFF2D3748);
  static const Color statCardSubText = Color(0xFF4A5568);
  static const Color statCardIcon = Color(0xFFFF6B9D);
  static const Color statCardBorder = Color(0xFFE2E8F0);
  static const Color statCardShadow = Color(0x10000000);

  static const Color diaryCardBg = Colors.white;
  static const Color diaryCardText = Color(0xFF2D3748);
  static const Color diaryCardSubText = Color(0xFF4A5568);
  static const Color diaryCardBorder = Color(0xFFE2E8F0);
  static const Color diaryCardShadow = Color(0x10000000);

  static const Color filterChipBg = Color(0xFFF8FAFC);
  static const Color filterChipSelected = Color(0xFFFF6B9D);
  static const Color filterChipText = Color(0xFF2D3748);
  static const Color filterChipTextSelected = Color(0xFFFFFFFF);

  static const Color cardShadow = Color(0x10000000);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color mainText = Color(0xFF2D3748);
  static const Color subText = Color(0xFF4A5568);
  static const Color accentText = Color(0xFFFF6B9D);

  // 기본 컬러 팔레트
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF2D3748);
  static const Color gray = Color(0xFF718096);
  static const Color lightGray = Color(0xFFF8FAFC);
  static const Color darkGray = Color(0xFF4A5568);

  static const Color purple = Color(0xFF9B59B6);
  static const Color purpleDark = Color(0xFF7C3AED);
  static const Color blue = Color(0xFFF0F8FF);
  static const Color pink = Color(0xFFFF6B9D);
  static const Color pinkLight = Color(0xFFFFE5F1);
  static const Color mint = Color(0xFFE8F5E8);
  static const Color yellow = Color(0xFFFFF8E1);
  static const Color orange = Color(0xFFFFED4E);
  static const Color green = Color(0xFF10B981);
  static const Color red = Color(0xFFEF4444);

  static const Color primary = Color(0xFFF88EB2);
  static const Color secondary = Color(0xFF9B59B6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color danger = Color(0xFFF67171);
  static const Color success = Color(0xFF47BD96);
  static const Color pinkAccent = Color(0xFFFFB6C1);
  static const Color lightPurple = Color(0xFFDDA0DD);
  static const Color lightLavender = Color(0xFFE5DEFF);
  static const Color lavender = Color(0xFFE5DEFF);
  static const Color accent = Color(0xFFFBB1CA);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color accentDark = Color(0xFF9B97E8);

  // 🌙 다크 테마 색상
  static const Color darkCardBg = Color(0xFF373843);
  static const Color darkCardText = Color(0xFFFFFFFF);
  static const Color darkCardSubText = Color(0xFFD1D5DB);
  static const Color darkCardBorder = Color(0xFF52525B);
  static const Color darkCardShadow = Color(0x30000000);
  static const Color darkFilterChipBg = Color(0xFF404249);
  static const Color darkFilterChipSelected = Color(0xFFEC4899);
  static const Color darkFilterChipText = Color(0xFFFFFFFF);
  static const Color darkFilterChipTextSelected = Color(0xFFFFFFFF);
  static const Color darkMainText = Color(0xFFFFFFFF);
  static const Color darkSubText = Color(0xFFD1D5DB);
  static const Color darkAccentText = Color(0xFFEC4899);
  static const Color darkWhite = Color(0xFFFFFFFF);
  static const Color darkBlack = Color(0xFF1A1B23);
  static const Color darkLightGray = Color(0xFF9297A5);
  static const Color darkPurple = Color(0xFF8D79BC);
  static const Color darkPurpleDark = Color(0xFF553C9A);
  static const Color darkBlue = Color(0xFF3B82F6);
  static const Color darkPink = Color(0xFFC3799D);
  static const Color darkPinkLight = Color(0xFFF472B6);
  static const Color darkMint = Color(0xFF10B981);
  static const Color darkYellow = Color(0xFFF59E0B);
  static const Color darkOrange = Color(0xFFF97316);
  static const Color darkGreen = Color(0xFF059669);
  static const Color darkRed = Color(0xFFDC2626);
  static const Color darkPrimary = Color(0xFFEC84B7);
  static const Color darkSecondary = Color(0xFFA085E1);
  static const Color darkWarning = Color(0xFFF59E0B);
  static const Color darkInfo = Color(0xFF3B82F6);
  static const Color darkDanger = Color(0xFFDC2626);
  static const Color darkSuccess = Color(0xFF059669);
  static const Color darkPinkAccent = Color(0xFFF472B6);
  static const Color darkAccent = Color(0xFF6B46C1);
  static const Color darkSubBg = Color(0xFF404249);
  static const Color warningDark = Color(0xFFE65100);
}

// 🌸 온보딩 기반 그라데이션
class LifewispGradients {
  // 메인 온보딩 그라데이션
  static const LinearGradient onboardingBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE5F1), // 연한 핑크
      Color(0xFFF0F8FF), // 연한 하늘색
      Color(0xFFE8F5E8), // 연한 민트
      Color(0xFFFFF8E1), // 연한 노랑
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient onboardingBgDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F2937), // 어두운 회색
      Color(0xFF111827), // 더 어두운 회색
      Color(0xFF1E293B), // 어두운 슬레이트
      Color(0xFF0F172A), // 가장 어두운 색
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient statCard = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFFB6C1)],
  );

  static const LinearGradient purple = LinearGradient(
    colors: [Color(0xFF9B59B6), Color(0xFFDDA0DD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mint = LinearGradient(
    colors: [Color(0xFFE8F5E8), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orange = LinearGradient(
    colors: [Color(0xFFFFF8E1), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blue = LinearGradient(
    colors: [Color(0xFFF0F8FF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondary = LinearGradient(
    colors: [Color(0xFFC896DD), Color(0xFFA48DD8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFFFF8E1), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient danger = LinearGradient(
    colors: [Color(0xFFFFE5E5), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient background = onboardingBg;
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFFF496B6), Color(0xFFBD89D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient profileHeaderGradient = LinearGradient(
    colors: [Color(0xFFF1A3BD), Color(0xFFCD9EE1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 감정별 그라데이션
  static LinearGradient onboardingBgFor(String emotionType, {bool dark = false}) {
    switch (emotionType) {
      case 'happy':
        return LinearGradient(
          colors: dark
              ? [Color(0xFF1F2937), Color(0xFF059669)]
              : [Color(0xFFFFF8E1), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sad':
        return LinearGradient(
          colors: dark
              ? [Color(0xFF1E293B), Color(0xFF3B82F6)]
              : [Color(0xFFF0F8FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'angry':
        return LinearGradient(
          colors: dark
              ? [Color(0xFF1F2937), Color(0xFFDC2626)]
              : [Color(0xFFFFE5E5), Color(0xFFFECDCD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'love':
        return LinearGradient(
          colors: dark
              ? [Color(0xFF1F2937), Color(0xFFEC4899)]
              : [Color(0xFFFFE5F1), Color(0xFFFFB6C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'fear':
        return LinearGradient(
          colors: dark
              ? [Color(0xFF1E293B), Color(0xFF6B46C1)]
              : [Color(0xFFE5DEFF), Color(0xFFDDA0DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return dark ? onboardingBgDark : onboardingBg;
    }
  }
}

// Helper extension for using gradients as BoxDecoration
extension GradientDecoration on LinearGradient {
  BoxDecoration get asBoxDecoration => BoxDecoration(gradient: this);
}

// 🌸 온보딩 파스텔 테마 텍스트 스타일 - Poor Story를 기본으로 변경
class LifewispTextStyles {
  static final statCard = GoogleFonts.poorStory(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: LifewispColors.statCardText,
  );
  static final statCardSub = GoogleFonts.poorStory(
    fontSize: 12,
    color: LifewispColors.statCardSubText,
  );
  static final diaryCard = GoogleFonts.poorStory(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: LifewispColors.diaryCardText,
    height: 1.4,
  );
  static final diaryCardSub = GoogleFonts.poorStory(
    fontSize: 13,
    color: LifewispColors.diaryCardSubText,
  );
  static final filterChip = GoogleFonts.poorStory(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: LifewispColors.filterChipText,
  );
  static final filterChipSelected = GoogleFonts.poorStory(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: LifewispColors.filterChipTextSelected,
  );
  static final main = GoogleFonts.poorStory(
    fontSize: 16,
    color: LifewispColors.mainText,
  );
  static final sub = GoogleFonts.poorStory(
    fontSize: 14,
    color: LifewispColors.subText,
    height: 1.4,
  );
  static final accent = GoogleFonts.poorStory(
    fontSize: 16,
    color: LifewispColors.accentText,
    fontWeight: FontWeight.w700,
  );
  static final title = GoogleFonts.poorStory(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: LifewispColors.mainText,
  );
  static final titleBold = GoogleFonts.poorStory(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: LifewispColors.mainText,
  );
  static final subtitle = GoogleFonts.poorStory(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: LifewispColors.subText,
    height: 1.4,
  );
  static final body = GoogleFonts.poorStory(
    fontSize: 16,
    color: LifewispColors.mainText,
    height: 1.4,
  );
  static final buttonBold = GoogleFonts.poorStory(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: LifewispColors.white,
  );

  // DARK THEME VARIANTS (가독성 최우선)
  static final darkStatCard = GoogleFonts.poorStory(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: LifewispColors.darkCardText,
  );
  static final darkStatCardSub = GoogleFonts.poorStory(
    fontSize: 12,
    color: LifewispColors.darkCardSubText,
  );
  static final darkDiaryCard = GoogleFonts.poorStory(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: LifewispColors.darkCardText,
    height: 1.4,
  );
  static final darkDiaryCardSub = GoogleFonts.poorStory(
    fontSize: 13,
    color: LifewispColors.darkCardSubText,
  );
  static final darkFilterChip = GoogleFonts.poorStory(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: LifewispColors.darkFilterChipText,
  );
  static final darkFilterChipSelected = GoogleFonts.poorStory(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: LifewispColors.darkFilterChipTextSelected,
  );
  static final darkMain = GoogleFonts.poorStory(
    fontSize: 16,
    color: LifewispColors.darkMainText,
  );
  static final darkSub = GoogleFonts.poorStory(
    fontSize: 14,
    color: LifewispColors.darkSubText,
    height: 1.4,
  );
  static final darkAccent = GoogleFonts.poorStory(
    fontSize: 16,
    color: LifewispColors.darkAccentText,
    fontWeight: FontWeight.w700,
  );
  static final darkTitle = GoogleFonts.poorStory(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: LifewispColors.darkMainText,
  );
  static final darkTitleBold = GoogleFonts.poorStory(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: LifewispColors.darkMainText,
  );
  static final darkSubtitle = GoogleFonts.poorStory(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: LifewispColors.darkSubText,
    height: 1.4,
  );
  static final darkBody = GoogleFonts.poorStory(
    fontSize: 16,
    color: LifewispColors.darkMainText,
    height: 1.4,
  );
  static final darkButtonBold = GoogleFonts.poorStory(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: LifewispColors.darkWhite,
  );
  static final caption = GoogleFonts.poorStory(
    fontSize: 12,
    color: LifewispColors.subText,
    height: 1.2,
  );
  static final darkCaption = GoogleFonts.poorStory(
    fontSize: 12,
    color: LifewispColors.darkSubText,
    height: 1.2,
  );

  // 🌸 벚꽃 토끼 온보딩 텍스트 스타일
  static TextStyle onboardingTitle(BuildContext context) =>
      GoogleFonts.poorStory(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Color(0xFF4A148C), // 진한 벚꽃 보라
      );

  static TextStyle onboardingSubtitle(BuildContext context) =>
      GoogleFonts.poorStory(
        fontSize: 18,
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFFE1BEE7)
            : Color(0xFF7B1FA2), // 벚꽃 보라
      );

  static TextStyle onboardingButton(BuildContext context) =>
      GoogleFonts.poorStory(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle onboardingEmotionLabel(BuildContext context) =>
      GoogleFonts.poorStory(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFFFACDE3)
            : Color(0xFF4A148C),
      );

  static TextStyle onboardingFeatureTitle(BuildContext context) =>
      GoogleFonts.poorStory(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Color(0xFF4A148C),
      );

  static TextStyle onboardingFeatureSubtitle(BuildContext context) =>
      GoogleFonts.poorStory(
        fontSize: 14,
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFFE1BEE7)
            : Color(0xFF7B1FA2),
      );

  // Helper: 동적 폰트 생성자
  static TextStyle getFont(BuildContext context, {double? fontSize, FontWeight? fontWeight, Color? color, double? height}) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final fontName = userProvider.selectedFont;
    final fontSizeMultiplier = userProvider.fontSize / 16.0; // 기본 폰트 크기 16을 기준으로 배율 계산

    // 폰트 크기 조정 (사용자 설정 반영)
    final adjustedFontSize = fontSize != null ? fontSize * fontSizeMultiplier : null;

    // 선택된 폰트에 따라 GoogleFonts 적용
    switch (fontName) {
      case 'Poor Story':
        return GoogleFonts.poorStory(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case 'Jua':
        return GoogleFonts.jua(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case 'Noto Sans':
        return GoogleFonts.notoSans(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case 'Do Hyeon':
        return GoogleFonts.doHyeon(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case 'Black Han Sans':
        return GoogleFonts.blackHanSans(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case 'Cute Font':
        return GoogleFonts.cuteFont(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      default:
        return GoogleFonts.poorStory( // 기본값을 Poor Story로 변경
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
    }
  }

  // Helper: GoogleFonts.poorStory 커스텀 생성자 (하위 호환성 유지)
  static TextStyle poorStory({double? fontSize, FontWeight? fontWeight, Color? color, double? height}) {
    return GoogleFonts.poorStory(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Helper: 정적 컨텍스트 없이 사용 가능한 폰트 스타일 생성자
  // 화면에서 직접 GoogleFonts.poorStory() 대신 사용할 수 있는 함수
  static TextStyle getStaticFont(BuildContext context, {double? fontSize, FontWeight? fontWeight, Color? color, double? height}) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final fontName = userProvider.selectedFont;
    final fontSizeMultiplier = userProvider.fontSize / 16.0; // 기본 폰트 크기 16을 기준으로 배율 계산

    // 폰트 크기 조정 (사용자 설정 반영)
    final adjustedFontSize = fontSize != null ? fontSize * fontSizeMultiplier : null;

    // 선택된 폰트에 따라 GoogleFonts 적용
    switch (fontName) {
      case 'Poor Story':
        return GoogleFonts.poorStory(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case 'Jua':
        return GoogleFonts.jua(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case 'Noto Sans':
        return GoogleFonts.notoSans(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case 'Do Hyeon':
        return GoogleFonts.doHyeon(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case 'Black Han Sans':
        return GoogleFonts.blackHanSans(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case 'Cute Font':
        return GoogleFonts.cuteFont(
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      default:
        return GoogleFonts.poorStory( // 기본값을 Poor Story로 변경
          fontSize: adjustedFontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
    }
  }
}

// 동적 테마 생성 함수 (사용자 설정 반영) - Poor Story를 기본으로 변경
ThemeData getAppTheme(BuildContext context, {bool isDark = false}) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final fontName = userProvider.selectedFont;
  final fontSize = userProvider.fontSize;
  final fontSizeMultiplier = fontSize / 16.0; // 기본 폰트 크기 16을 기준으로 배율 계산

  // 선택된 폰트에 따라 fontFamily 설정
  String? fontFamily;
  switch (fontName) {
    case 'Poor Story':
      fontFamily = GoogleFonts.poorStory().fontFamily;
      break;
    case 'Jua':
      fontFamily = GoogleFonts.jua().fontFamily;
      break;
    case 'Noto Sans':
      fontFamily = GoogleFonts.notoSans().fontFamily;
      break;
    case 'Do Hyeon':
      fontFamily = GoogleFonts.doHyeon().fontFamily;
      break;
    case 'Black Han Sans':
      fontFamily = GoogleFonts.blackHanSans().fontFamily;
      break;
    case 'Cute Font':
      fontFamily = GoogleFonts.cuteFont().fontFamily;
      break;
    default:
      fontFamily = GoogleFonts.poorStory().fontFamily; // 기본값을 Poor Story로 변경
  }

  // 기본 테마 가져오기
  final baseTheme = isDark ? lifewispDarkTheme : appTheme;

  // 텍스트 테마 생성 (폰트 크기 조정)
  final baseTextTheme = isDark ?
  GoogleFonts.poorStoryTextTheme(ThemeData.dark().textTheme) :
  GoogleFonts.poorStoryTextTheme();

  final adjustedTextTheme = baseTextTheme.copyWith(
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      fontFamily: fontFamily,
      fontSize: 16 * fontSizeMultiplier,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      fontFamily: fontFamily,
      fontSize: 18 * fontSizeMultiplier,
    ),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      fontFamily: fontFamily,
      fontSize: 22 * fontSizeMultiplier,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontFamily: fontFamily,
      fontSize: 18 * fontSizeMultiplier,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontFamily: fontFamily,
      fontSize: 16 * fontSizeMultiplier,
    ),
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      fontFamily: fontFamily,
      fontSize: 14 * fontSizeMultiplier,
    ),
  );

  // 새 테마 생성 (폰트 설정 적용)
  return baseTheme.copyWith(
    textTheme: adjustedTextTheme,
    appBarTheme: baseTheme.appBarTheme.copyWith(
      titleTextStyle: baseTheme.appBarTheme.titleTextStyle?.copyWith(
        fontFamily: fontFamily,
        fontSize: 20 * fontSizeMultiplier,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: baseTheme.elevatedButtonTheme.style?.copyWith(
        textStyle: MaterialStateProperty.all<TextStyle>(
          TextStyle(
            fontFamily: fontFamily,
            fontSize: 16 * fontSizeMultiplier,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

// Helper: get theme-aware color or style
// Example: LifewispTextStyles.mainFor(context)
extension LifewispTextStylesExt on LifewispTextStyles {
  static TextStyle mainFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? LifewispTextStyles.darkMain : LifewispTextStyles.main;
  static TextStyle subFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? LifewispTextStyles.darkSub : LifewispTextStyles.sub;
  static TextStyle titleFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? LifewispTextStyles.darkTitle : LifewispTextStyles.title;
  static TextStyle titleBoldFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? LifewispTextStyles.darkTitleBold : LifewispTextStyles.titleBold;
  static TextStyle subtitleFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? LifewispTextStyles.darkSubtitle : LifewispTextStyles.subtitle;
  static TextStyle bodyFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? LifewispTextStyles.darkBody : LifewispTextStyles.body;
  static TextStyle buttonBoldFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? LifewispTextStyles.darkButtonBold : LifewispTextStyles.buttonBold;

  // 🌸 벚꽃 토끼 테마 전용 스타일들
  static TextStyle profileTitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.darkTitleBold.copyWith(fontSize: 28)
          : LifewispTextStyles.titleBold.copyWith(fontSize: 28, color: Color(0xFF4A148C));

  static TextStyle profileSubtitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.darkSubtitle.copyWith(fontSize: 16)
          : LifewispTextStyles.subtitle.copyWith(fontSize: 16, color: Color(0xFF7B1FA2));

  static TextStyle statValue(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.darkStatCard.copyWith(fontSize: 24)
          : LifewispTextStyles.statCard.copyWith(fontSize: 24, color: Color(0xFF4A148C));

  static TextStyle statLabel(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.darkStatCardSub.copyWith(fontSize: 13)
          : LifewispTextStyles.statCardSub.copyWith(fontSize: 13, color: Color(0xFF7B1FA2));

  static TextStyle menuSectionTitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.darkTitle.copyWith(fontSize: 18, fontWeight: FontWeight.w700)
          : LifewispTextStyles.title.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF4A148C));

  static TextStyle menuItemTitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.darkMain.copyWith(fontSize: 16, fontWeight: FontWeight.w600)
          : LifewispTextStyles.main.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4A148C));

  static TextStyle menuItemSubtitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.darkSub.copyWith(fontSize: 14)
          : LifewispTextStyles.sub.copyWith(fontSize: 14, color: Color(0xFF7B1FA2));

  // 🐰 토끼 감정 표현 스타일
  static TextStyle emotionTitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.getStaticFont(context, fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF8BBD9))
          : LifewispTextStyles.getStaticFont(context, fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A148C));

  static TextStyle emotionSubtitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.getStaticFont(context, fontSize: 14, color: Color(0xFFE1BEE7))
          : LifewispTextStyles.getStaticFont(context, fontSize: 14, color: Color(0xFF7B1FA2));

  // 🌸 벚꽃 카드 스타일
  static TextStyle cardTitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.getStaticFont(context, fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)
          : LifewispTextStyles.getStaticFont(context, fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4A148C));

  static TextStyle cardSubtitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.getStaticFont(context, fontSize: 14, color: Color(0xFFE1BEE7))
          : LifewispTextStyles.getStaticFont(context, fontSize: 14, color: Color(0xFF7B1FA2));

  static TextStyle cardContent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? LifewispTextStyles.getStaticFont(context, fontSize: 16, color: Colors.white, height: 1.4)
          : LifewispTextStyles.getStaticFont(context, fontSize: 16, color: Color(0xFF4A148C), height: 1.4);
}

extension LifewispColorsExt on LifewispColors {
  static Color cardBgFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? LifewispColors.darkCardBg : LifewispColors.diaryCardBg;
  static Color mainTextFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? LifewispColors.darkMainText : LifewispColors.mainText;
  static Color subTextFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? LifewispColors.darkSubText : LifewispColors.subText;
  static Map<String, Color> emotionColor(BuildContext context) => emotionColorFor(context);

  // 🌸 벚꽃 테마 전용 헬퍼들
  static Color cherryBlossomFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Color(0xFFF8BBD9) : Color(0xFFF8BBD9);
  static Color bunnyPurpleFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Color(0xFFCE93D8) : Color(0xFFCE93D8);
  static Color backgroundFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Color(0xFF2D1B2E) : Color(0xFFFEF7FC);
  static Color surfaceFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Color(0xFF3D2A3E) : Color(0xFFFEF7FC);

  // 🐰 토끼 감정별 색상 헬퍼
  static Color happyBunnyFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Color(0xFFFFF59D) : Color(0xFFFFF9C4);
  static Color sadBunnyFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Color(0xFFB3E5FC) : Color(0xFFE0F7FA);
  static Color angryBunnyFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Color(0xFFFF8A80) : Color(0xFFFFCDD2);
  static Color loveBunnyFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Color(0xFFF8BBD9) : Color(0xFFFDE2F3);
  static Color fearBunnyFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Color(0xFFCE93D8) : Color(0xFFE1BEE7);
}

// 🌸 벚꽃 테마 헬퍼 함수들
class CherryBlossomTheme {
  // 벚꽃 그라데이션 배경 생성
  static BoxDecoration cherryBlossomBackground(BuildContext context, {double opacity = 1.0}) {
    return BoxDecoration(
      gradient: Theme.of(context).brightness == Brightness.dark
          ? LifewispGradients.onboardingBgDark.scale(opacity)
          : LifewispGradients.onboardingBg.scale(opacity),
    );
  }

  // 토끼 카드 데코레이션
  static BoxDecoration bunnyCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: LifewispColorsExt.surfaceFor(context),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: (Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Color(0xFFF8BBD9)).withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: (Theme.of(context).brightness == Brightness.dark
            ? Color(0xFF4A3D4A)
            : Color(0xFFFDE2F3)).withOpacity(0.3),
        width: 1,
      ),
    );
  }

  // 감정별 벚꽃 색상 가져오기
  static Color getEmotionCherryColor(String emotion, BuildContext context) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case '😊':
        return LifewispColorsExt.happyBunnyFor(context);
      case 'sad':
      case '😢':
        return LifewispColorsExt.sadBunnyFor(context);
      case 'angry':
      case '😡':
        return LifewispColorsExt.angryBunnyFor(context);
      case 'love':
      case '😍':
        return LifewispColorsExt.loveBunnyFor(context);
      case 'fear':
      case '😱':
        return LifewispColorsExt.fearBunnyFor(context);
      default:
        return LifewispColorsExt.cherryBlossomFor(context);
    }
  }
}

// LinearGradient extension for opacity scaling
extension LinearGradientExt on LinearGradient {
  LinearGradient scale(double opacity) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors.map((color) => color.withOpacity(opacity)).toList(),
      stops: stops,
    );
  }
}
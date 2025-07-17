import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// chat_screen.dart의 gradient 색상 기반 파스텔 컬러
final chatGradientColors = [
  Color(0xFFE8F4FD), // 연한 하늘색
  Color(0xFFF0F8FF), // 거의 흰색
  Color(0xFFFFF0F5), // 연한 분홍
];

final lifewispPrimary = Color(0xFF6B73FF); // chat_screen 포인트 컬러
final lifewispAccent = Color(0xFFB5EAEA); // 추가 파스텔톤
final lifewispCard = Colors.white;

final emotionColorMap = {
  '😊': Color(0xFFFFF9C4),
  '😢': Color(0xFFE0F7FA),
  '😡': Color(0xFFFFCDD2),
  '😍': Color(0xFFFFF1F3),
  '😱': Color(0xFFE1BEE7),
};

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: GoogleFonts.jua().fontFamily,
  scaffoldBackgroundColor: chatGradientColors[0],
  primaryColor: lifewispPrimary,
  colorScheme: ColorScheme.fromSeed(seedColor: lifewispPrimary),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.jua(
      fontSize: 22,
      color: lifewispPrimary,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: lifewispPrimary),
  ),
  cardTheme: CardThemeData(
    color: lifewispCard,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    shadowColor: chatGradientColors[1],
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lifewispPrimary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      textStyle: GoogleFonts.jua(fontSize: 18),
      elevation: 2,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: lifewispPrimary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: chatGradientColors[1],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    hintStyle: GoogleFonts.jua(color: Colors.grey[400]),
  ),
  textTheme: GoogleFonts.juaTextTheme().copyWith(
    bodyMedium: GoogleFonts.jua(fontSize: 16, color: lifewispPrimary),
    titleLarge: GoogleFonts.jua(fontSize: 22, color: lifewispPrimary),
  ),
); 
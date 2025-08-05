import 'package:flutter/material.dart';

enum Season {
  spring,    // 봄 - 벚꽃
  summer,    // 여름 - 초록 잎
  autumn,    // 가을 - 단풍
  winter,    // 겨울 - 눈
}

class SeasonUtils {
  /// 현재 날짜를 기반으로 계절을 반환합니다.
  static Season getCurrentSeason() {
    final now = DateTime.now();
    final month = now.month;
    
    // 한국의 계절 구분 (대략적)
    // 봄: 3-5월, 여름: 6-8월, 가을: 9-11월, 겨울: 12-2월
    if (month >= 3 && month <= 5) {
      return Season.spring;
    } else if (month >= 6 && month <= 8) {
      return Season.summer;
    } else if (month >= 9 && month <= 11) {
      return Season.autumn;
    } else {
      return Season.winter;
    }
  }

  /// 특정 날짜의 계절을 반환합니다.
  static Season getSeasonForDate(DateTime date) {
    final month = date.month;
    
    if (month >= 3 && month <= 5) {
      return Season.spring;
    } else if (month >= 6 && month <= 8) {
      return Season.summer;
    } else if (month >= 9 && month <= 11) {
      return Season.autumn;
    } else {
      return Season.winter;
    }
  }

  /// 계절에 따른 색상을 반환합니다.
  static List<Color> getSeasonColors(Season season, bool isDark) {
    switch (season) {
      case Season.spring:
        return isDark
            ? [const Color(0xFFFF69B4), const Color(0xFF32CD32)] // 핑크, 그린
            : [const Color(0xFFFFB6C1), const Color(0xFF90EE90)]; // 연한 핑크, 연한 그린
      case Season.summer:
        return isDark
            ? [const Color(0xFF32CD32), const Color(0xFFFFFF00)] // 그린, 옐로우
            : [const Color(0xFF90EE90), const Color(0xFFFFFACD)]; // 연한 그린, 연한 옐로우
      case Season.autumn:
        return isDark
            ? [const Color(0xFFFF4500), const Color(0xFFDC143C)] // 오렌지, 레드
            : [const Color(0xFFFFA07A), const Color(0xFFFFB6C1)]; // 연한 오렌지, 연한 레드
      case Season.winter:
        return isDark
            ? [const Color(0xFF87CEEB), const Color(0xFF9370DB)] // 블루, 퍼플
            : [const Color(0xFFB0E0E6), const Color(0xFFDDA0DD)]; // 연한 블루, 연한 퍼플
    }
  }

  /// 계절에 따른 설명을 반환합니다.
  static String getSeasonDescription(Season season) {
    switch (season) {
      case Season.spring:
        return '봄의 벚꽃이 만개했어요! 🌸';
      case Season.summer:
        return '무성한 여름의 초록이 가득해요! 🌿';
      case Season.autumn:
        return '아름다운 가을 단풍이 물들었어요! 🍁';
      case Season.winter:
        return '고요한 겨울의 눈이 내려요! ❄️';
    }
  }

  /// 계절에 따른 성장 메시지를 반환합니다.
  static String getGrowthMessageForSeason(Season season) {
    switch (season) {
      case Season.spring:
        return '봄의 새로운 시작과 함께 감정도 새롭게 피어나요! 🌸';
      case Season.summer:
        return '여름의 무성한 초록처럼 감정도 풍성하게 자라나요! 🌿';
      case Season.autumn:
        return '가을의 성숙한 단풍처럼 감정도 깊어지고 있어요! 🍁';
      case Season.winter:
        return '겨울의 고요함처럼 마음도 차분하게 정리되고 있어요! ❄️';
    }
  }

  /// 계절에 따른 이모지를 반환합니다.
  static String getSeasonEmoji(Season season) {
    switch (season) {
      case Season.spring:
        return '🌸';
      case Season.summer:
        return '🌿';
      case Season.autumn:
        return '🍁';
      case Season.winter:
        return '❄️';
    }
  }

  /// 계절에 따른 한국어 이름을 반환합니다.
  static String getSeasonName(Season season) {
    switch (season) {
      case Season.spring:
        return '봄';
      case Season.summer:
        return '여름';
      case Season.autumn:
        return '가을';
      case Season.winter:
        return '겨울';
    }
  }
} 
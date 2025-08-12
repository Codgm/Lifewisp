# 🌸 Lifewisp - 감정 일기 & AI 상담사

<div align="center">

![Lifewisp Logo](https://img.shields.io/badge/Lifewisp-감정일기앱-pink?style=for-the-badge&logo=flutter)
![Flutter](https://img.shields.io/badge/Flutter-3.16.0-blue?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.1.3-blue?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**당신의 감정을 이해하고 함께 성장하는 AI 상담사와 함께하는 감정 일기 앱**

[📱 기능 소개](#-주요-기능) • [🚀 시작하기](#-시작하기) • [🛠️ 기술 스택](#️-기술-스택) • [📱 스크린샷](#-스크린샷)

</div>

---

## ✨ 주요 기능

### 📝 **감정 일기 작성**
- 🐰 귀여운 토끼 이모티콘으로 감정 선택
- 📅 날짜별 감정 기록 및 일기 작성
- 🏷️ 카테고리별 활동 분류 (건강, 성취, 관계, 취미, 기타)
- 📸 이미지 첨부로 소중한 순간 기록
- 🌙 다크모드 지원으로 편안한 사용

### 📊 **감정 분석 & 통계**
- 📈 감정별 분포 차트 및 통계
- 📅 월간 감정 변화 추적
- 🔥 감정 히트맵으로 패턴 분석
- 📊 특이점 분석으로 감정 변화 인사이트

### 🤖 **AI 상담사**
- 💬 개인화된 감정 상담
- 🧠 AI 기반 감정 분석 및 조언
- 💡 맞춤형 성장 제안
- 🎯 프리미엄 기능으로 더 깊은 분석

### 📱 **사용자 경험**
- ✨ 부드러운 애니메이션과 직관적인 UI
- 🎨 아름다운 파스텔 테마
- 📱 반응형 디자인으로 모든 기기 지원
- 🔄 실시간 데이터 동기화

---

## 🚀 시작하기

### 📋 요구사항

- Flutter 3.16.0 이상
- Dart 3.1.3 이상
- Android Studio / VS Code
- iOS 개발을 위한 Xcode (macOS)
- Android 개발을 위한 Android Studio

### 🔧 설치 방법

1. **저장소 클론**
```bash
git clone https://github.com/your-username/lifewisp.git
cd lifewisp
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **환경 설정**
```bash
# .env 파일 생성 (필요한 경우)
cp .env.example .env
```

4. **앱 실행**
```bash
# iOS 시뮬레이터
flutter run -d ios

# Android 에뮬레이터
flutter run -d android

# 웹 브라우저
flutter run -d chrome
```

### 🏗️ 빌드

```bash
# Android APK 빌드
flutter build apk --release

# iOS 빌드
flutter build ios --release

# 웹 빌드
flutter build web --release
```

---

## 🛠️ 기술 스택

### 📱 **프론트엔드**
- **Flutter** - 크로스 플랫폼 UI 프레임워크
- **Dart** - 프로그래밍 언어
- **Material Design 3** - 디자인 시스템

### 🎨 **UI/UX**
- **Google Fonts** - 타이포그래피
- **Flutter Animate** - 애니메이션
- **Lottie** - 고급 애니메이션
- **FL Chart** - 데이터 시각화
- **Confetti** - 축하 효과

### 💾 **데이터 관리**
- **Provider** - 상태 관리
- **SharedPreferences** - 로컬 설정 저장
- **SQLite** - 구조화된 데이터 저장
- **Path Provider** - 파일 시스템 접근

### 🤖 **AI & 분석**
- **HTTP** - API 통신
- **JSON** - 데이터 직렬화
- **Crypto** - 데이터 암호화

### 📸 **미디어**
- **Image Picker** - 이미지 선택
- **Cached Network Image** - 이미지 캐싱
- **Gallery Saver** - 갤러리 저장

### 🔔 **알림 & 권한**
- **Flutter Local Notifications** - 로컬 알림
- **Permission Handler** - 권한 관리
- **Connectivity Plus** - 네트워크 상태

---

## 📱 스크린샷

<div align="center">

| 대시보드 | 감정 기록 | AI 채팅 |
|---------|----------|---------|
| ![Dashboard](assets/images/dashboard.png) | ![Emotion Record](assets/images/emotion_record.png) | ![AI Chat](assets/images/ai_chat.png) |

| 감정 분석 | 캘린더 | 설정 |
|----------|--------|------|
| ![Analysis](assets/images/analysis.png) | ![Calendar](assets/images/calendar.png) | ![Settings](assets/images/settings.png) |

</div>

---

## 🏗️ 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── emotion_record.dart   # 감정 기록 모델
│   ├── emotion_character.dart
│   └── user.dart
├── screens/                  # 화면들
│   ├── auth/                 # 인증 관련
│   ├── dashboard_screen.dart # 메인 대시보드
│   ├── emotion_record_screen.dart # 감정 기록
│   ├── analysis_screen.dart  # 감정 분석
│   ├── chat_screen.dart      # AI 채팅
│   ├── calendar_screen.dart  # 캘린더
│   ├── profile_screen.dart   # 프로필
│   ├── settings_screen.dart  # 설정
│   ├── subscription_screen.dart # 구독
│   ├── advanced_analysis_screen.dart # 고급 분석
│   ├── result_screen.dart    # 결과 화면
│   ├── share_screen.dart     # 공유
│   ├── splash_screen.dart    # 스플래시
│   ├── onboarding_screen.dart # 온보딩
│   └── diary_detail_screen.dart # 일기 상세
├── providers/                # 상태 관리
│   ├── emotion_provider.dart
│   ├── user_provider.dart
│   └── subscription_provider.dart
├── widgets/                  # 재사용 위젯
│   ├── custom_bottom_nav_bar.dart
│   ├── common_app_bar.dart
│   ├── rabbit_emoticon.dart
│   ├── emotion_charts.dart
│   ├── season_animation.dart
│   └── premium_gate.dart
├── services/                 # 서비스
│   ├── local_storage_service.dart
│   └── gpt_service.dart
└── utils/                    # 유틸리티
    └── theme.dart
```

---

## 🎯 주요 기능 상세

### 📝 감정 기록 시스템
- **감정 선택**: 10가지 감정 (행복, 슬픔, 분노, 흥분, 평온, 불안, 사랑, 피곤, 절망, 자신감)
- **카테고리 분류**: 건강, 성취, 관계, 취미, 기타
- **이미지 첨부**: 최대 5장까지 사진 기록
- **일기 작성**: 자유로운 텍스트 기록

### 📊 분석 기능
- **감정 분포**: 파이 차트로 감정별 분포 표시
- **월간 트렌드**: 선 그래프로 감정 변화 추적
- **히트맵**: 캘린더 형태로 감정 패턴 시각화
- **특이점 분석**: 비정상적인 감정 변화 감지

### 🤖 AI 상담사
- **개인화 상담**: 사용자 감정 패턴 기반 맞춤 조언
- **감정 분석**: AI가 감정 상태를 분석하고 제안
- **성장 가이드**: 개인별 성장 목표 제시
- **프리미엄 기능**: 무제한 AI 상담 (구독 시)

### 🎨 동적 폰트 시스템
- **폰트 종류 변경**: 다양한 폰트 스타일 지원
- **폰트 크기 조절**: 가독성을 위한 텍스트 크기 조정
- **행간 설정**: 읽기 편안한 텍스트 간격 조정
- **접근성 최적화**: 시각적 편의성 향상

---

## 🎨 디자인 시스템

### 색상 팔레트
```dart
// 메인 색상
final brightPink = Color(0xFFFF6B9D);      // 메인 핑크
final softPurple = Color(0xFF9B59B6);      // 보조 보라
final pastelPink = Color(0xFFFFE5F1);      // 연한 핑크
final pastelBlue = Color(0xFFF0F8FF);      // 연한 하늘색
final pastelMint = Color(0xFFE8F5E8);      // 연한 민트

// 다크모드
final darkBackground = Color(0xFF1A1B23);  // 깊은 네이비
final darkSurface = Color(0xFF2D2E36);     // 어두운 표면
final darkCard = Color(0xFF373843);        // 어두운 카드
```

### 타이포그래피
- **메인 폰트**: Google Fonts Jua
- **가독성**: 높은 대비와 적절한 크기
- **반응형**: 다양한 화면 크기에 대응

### 애니메이션
- **전체적으로**: 부드러운 애니메이션 적용
- **라이브러리**: flutter_animate, lottie 사용
- **성능**: 60fps 유지

---

## 🔧 개발 가이드

### 코드 스타일
```dart
// 파일명: snake_case
// 클래스명: PascalCase
// 변수명: camelCase
// 상수: UPPER_SNAKE_CASE

class EmotionRecord {
  final DateTime date;
  final String emotion;
  final String diary;
  
  const EmotionRecord({
    required this.date,
    required this.emotion,
    required this.diary,
  });
}
```

### 상태 관리
```dart
// Provider 패턴 사용
class EmotionProvider extends ChangeNotifier {
  List<EmotionRecord> _records = [];
  
  List<EmotionRecord> get records => _records;
  
  void addRecord(EmotionRecord record) {
    _records.add(record);
    notifyListeners();
  }
}
```

### 테마 사용
```dart
// 테마 접근
final isDark = Theme.of(context).brightness == Brightness.dark;
final colors = LifewispColors.forTheme(context);
```

---

## 🚀 배포

### Android
1. `android/app/build.gradle`에서 버전 설정
2. `flutter build apk --release` 실행
3. Google Play Console에 업로드

### iOS
1. `ios/Runner/Info.plist`에서 버전 설정
2. `flutter build ios --release` 실행
3. App Store Connect에 업로드

### 웹
1. `flutter build web --release` 실행
2. `build/web` 폴더를 웹 서버에 배포

---

## 🤝 기여하기

1. **Fork** 프로젝트
2. **Feature branch** 생성 (`git checkout -b feature/AmazingFeature`)
3. **Commit** 변경사항 (`git commit -m 'Add some AmazingFeature'`)
4. **Push** 브랜치 (`git push origin feature/AmazingFeature`)
5. **Pull Request** 생성

### 개발 환경 설정
```bash
# 코드 포맷팅
flutter format .

# 린트 검사
flutter analyze

# 테스트 실행
flutter test
```

---

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

## 🙏 감사의 말

- **Flutter Team** - 훌륭한 프레임워크 제공
- **Provider Team** - 상태 관리 솔루션
- **FL Chart Team** - 데이터 시각화 라이브러리
- **모든 오픈소스 기여자들** - 이 프로젝트에 영감을 주신 분들

---

## 📞 연락처

---

<div align="center">

**⭐ 이 프로젝트가 도움이 되었다면 스타를 눌러주세요!**

Made with ❤️ by [서규민]

</div>

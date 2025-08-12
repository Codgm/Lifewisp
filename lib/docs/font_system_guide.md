# Lifewisp 동적 폰트 시스템 가이드

## 개요

이 문서는 Lifewisp 앱의 동적 폰트 시스템 사용 방법을 설명합니다. 동적 폰트 시스템은 사용자가 앱 설정에서 폰트 종류와 크기를 변경할 수 있게 해주는 기능입니다.

## 기본 원칙

1. 앱 전체에서 일관된 폰트 스타일을 유지하기 위해 직접 `GoogleFonts.jua()` 등의 호출을 피하고 제공된 헬퍼 함수를 사용합니다.
2. 테마 시스템을 통해 다크 모드와 라이트 모드에 맞는 스타일을 자동으로 적용합니다.
3. 사용자 설정에 따라 폰트 종류와 크기가 동적으로 변경됩니다.

## 사용 방법

### 1. 테마를 통한 폰트 사용 (권장)

가장 권장되는 방법은 테마 시스템을 통해 폰트를 사용하는 것입니다. 이 방법은 다크 모드와 라이트 모드를 자동으로 처리합니다.

```dart
Text(
  '텍스트 내용',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### 2. LifewispTextStylesExt 확장 사용

특정 스타일이 필요한 경우 `LifewispTextStylesExt` 확장 메서드를 사용합니다.

```dart
Text(
  '텍스트 내용',
  style: LifewispTextStylesExt.mainFor(context),
)
```

### 3. 동적 폰트 헬퍼 함수 사용

기존 코드에서 `GoogleFonts.jua()`를 직접 사용하는 경우, 이를 `LifewispTextStyles.getStaticFont(context)`로 대체합니다.

```dart
// 변경 전
Text(
  '텍스트 내용',
  style: GoogleFonts.jua(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  ),
)

// 변경 후
Text(
  '텍스트 내용',
  style: LifewispTextStyles.getStaticFont(
    context,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  ),
)
```

### 4. 정적 테마 사용 (레거시 지원)

기존 코드와의 호환성을 위해 `LifewispTextStyles.jua()` 메서드도 계속 지원됩니다. 그러나 새로운 코드에서는 사용을 권장하지 않습니다.

```dart
Text(
  '텍스트 내용',
  style: LifewispTextStyles.jua(
    fontSize: 16,
    color: Colors.black,
  ),
)
```

## 폰트 종류

현재 지원되는 폰트 종류는 다음과 같습니다:

1. Jua (기본값)
2. Noto Sans
3. Do Hyeon
4. Black Han Sans
5. Cute Font

## 폰트 크기

사용자는 설정에서 폰트 크기를 조정할 수 있습니다. 기본 크기는 16입니다.

## 개발자 참고 사항

- 새로운 화면이나 위젯을 개발할 때는 항상 동적 폰트 시스템을 사용하세요.
- 폰트 스타일을 하드코딩하지 마세요.
- 테마 시스템을 최대한 활용하여 다크 모드와 라이트 모드를 자동으로 처리하세요.
- 특별한 이유가 없는 한 직접 `GoogleFonts` API를 호출하지 마세요.
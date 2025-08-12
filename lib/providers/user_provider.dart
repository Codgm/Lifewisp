import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  String? _userEmail;
  String? _userNickname;
  String? _profileImagePath;
  String? _photoUrl;
  bool _isPremium = false;
  ThemeMode _themeMode = ThemeMode.light;
  
  // AuthProvider 참조
  AuthProvider? _authProvider;
  
  // 앱 설정들
  bool _notificationEnabled = true;
  TimeOfDay _reminderTime = TimeOfDay(hour: 21, minute: 0);
  int _weekStartDay = 1; // 0: 일요일, 1: 월요일
  String _selectedFont = 'Poor Story';
  double _fontSize = 16.0;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  final NotificationService _notificationService = NotificationService();
  static const int DAILY_REMINDER_ID = 1000;

  // AuthProvider에서 로그인 상태 가져오기
  bool get isLoggedIn => _authProvider?.isAuthenticated ?? false;

  // 사용자 정보 가져오기
  String? get userEmail => _authProvider?.currentUser?.email ?? _userEmail;
  String? get userNickname => _authProvider?.currentUser?.nickname ?? _userNickname;
  String? get profileImagePath => _profileImagePath;
  String? get profileImageUrl => _authProvider?.currentUser?.photoUrl ?? _profileImagePath;
  bool get isPremium => _authProvider?.currentUser?.isPremium ?? _isPremium;
  ThemeMode get themeMode => _themeMode;
  
  // 앱 설정 getters
  bool get notificationEnabled => _notificationEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  int get weekStartDay => _weekStartDay;
  String get selectedFont => _selectedFont;
  double get fontSize => _fontSize;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> setFontSettings(String font, double size) async {
    _selectedFont = font;
    _fontSize = size;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_font', font);
    await prefs.setDouble('font_size', size);
  }

  Future<void> _loadFontSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedFont = prefs.getString('selected_font') ?? 'Poor Story'; // 기본값 변경
    _fontSize = prefs.getDouble('font_size') ?? 16.0;
    notifyListeners();
  }

  // 초기화 시 설정 로드
  Future<void> initialize({AuthProvider? authProvider}) async {
    // AuthProvider 설정
    if (authProvider != null) {
      _authProvider = authProvider;
      
      // AuthProvider의 상태 변경 감지
      _authProvider!.addListener(_onAuthStateChanged);
    }
    await _notificationService.initialize();
    await _loadSettings();
    if (_notificationEnabled) {
      await _scheduleDailyReminder();
    }
  }
  
  // AuthProvider 상태 변경 감지 핸들러
  void _onAuthStateChanged() {
    // AuthProvider의 상태가 변경되면 UserProvider도 업데이트
    notifyListeners();
  }
  
  @override
  void dispose() {
    // 리스너 제거
    if (_authProvider != null) {
      _authProvider!.removeListener(_onAuthStateChanged);
    }
    super.dispose();
  }

  // 로그인 상태 확인 - AuthProvider로 대체되어 더 이상 사용하지 않음
  Future<void> _checkLoginStatus() async {
    // 이 메서드는 더 이상 사용하지 않습니다.
    // AuthProvider에서 로그인 상태를 관리합니다.
    print('_checkLoginStatus는 더 이상 사용하지 않습니다. AuthProvider를 사용하세요.');
  }

  // 설정 저장
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.toString());
    await prefs.setString('userNickname', _userNickname ?? '');
    await prefs.setString('profileImagePath', _profileImagePath ?? '');
    await prefs.setBool('notificationEnabled', _notificationEnabled);
    await prefs.setInt('reminderHour', _reminderTime.hour);
    await prefs.setInt('reminderMinute', _reminderTime.minute);
    await prefs.setInt('weekStartDay', _weekStartDay);
    await prefs.setString('selectedFont', _selectedFont);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
  }

  // 설정 로드
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 테마 설정
    final themeModeString = prefs.getString('themeMode');
    if (themeModeString != null) {
      switch (themeModeString) {
        case 'ThemeMode.light':
          _themeMode = ThemeMode.light;
          break;
        case 'ThemeMode.dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'ThemeMode.system':
          _themeMode = ThemeMode.system;
          break;
      }
    }
    
    // 사용자 정보
    _userNickname = prefs.getString('userNickname');
    _profileImagePath = prefs.getString('profileImagePath');
    
    // 앱 설정들
    _notificationEnabled = prefs.getBool('notificationEnabled') ?? true;
    final reminderHour = prefs.getInt('reminderHour') ?? 21;
    final reminderMinute = prefs.getInt('reminderMinute') ?? 0;
    _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    _weekStartDay = prefs.getInt('weekStartDay') ?? 1;
    _selectedFont = prefs.getString('selectedFont') ?? 'Poor Story';
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    
    notifyListeners();
  }

  // 알림 권한 상태 확인
  Future<bool> checkNotificationPermissions() async {
    try {
      return await _notificationService.hasPermissions();
    } catch (e) {
      print('Error checking notification permissions: $e');
      return false;
    }
  }

  // 알림 권한 요청
  Future<bool> requestNotificationPermissions() async {
    try {
      return await _notificationService.requestPermissions();
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }

  // 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 비밀번호 유효성 검사
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  // 비밀번호 해시화 (실제 구현시 더 안전한 방법 사용)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 로그인 - AuthProvider 사용
  Future<bool> login(String email, String password) async {
    // 이 메서드는 더 이상 직접 사용하지 않고 AuthProvider를 통해 로그인합니다.
    // 호환성을 위해 유지하지만 실제 구현은 AuthProvider로 위임합니다.
    throw Exception('이 메서드는 더 이상 사용되지 않습니다. AuthProvider를 사용하세요.');
  }

  // 회원가입 - AuthProvider 사용
  Future<bool> signup(String email, String password, String nickname) async {
    // 이 메서드는 더 이상 직접 사용하지 않고 AuthProvider를 통해 회원가입합니다.
    // 호환성을 위해 유지하지만 실제 구현은 AuthProvider로 위임합니다.
    throw Exception('이 메서드는 더 이상 사용되지 않습니다. AuthProvider를 사용하세요.');
  }

  // 로그아웃 - AuthProvider 사용
  Future<void> logout() async {
    // 이 메서드는 더 이상 직접 사용하지 않고 AuthProvider를 통해 로그아웃합니다.
    // 호환성을 위해 유지하지만 실제 구현은 AuthProvider로 위임합니다.
    throw Exception('이 메서드는 더 이상 사용되지 않습니다. AuthProvider를 사용하세요.');
  }

  // 비밀번호 찾기 - AuthProvider 사용
  Future<bool> resetPassword(String email) async {
    // 이 메서드는 더 이상 직접 사용하지 않고 AuthProvider를 통해 비밀번호 재설정합니다.
    // 호환성을 위해 유지하지만 실제 구현은 AuthProvider로 위임합니다.
    throw Exception('이 메서드는 더 이상 사용되지 않습니다. AuthProvider를 사용하세요.');
  }

  Future<void> _scheduleDailyReminder() async {
    if (!_notificationEnabled) {
      print('Notifications are disabled, skipping schedule');
      return;
    }

    try {
      // 기존 알림 취소
      await _notificationService.cancelNotification(DAILY_REMINDER_ID);

      // 권한 확인
      bool hasPermission = await _notificationService.hasPermissions();
      if (!hasPermission) {
        print('No notification permission, requesting...');
        hasPermission = await _notificationService.requestPermissions();
        if (!hasPermission) {
          print('Notification permission denied');
          return;
        }
      }

      // 새 알림 스케줄
      await _notificationService.scheduleDailyNotification(
        id: DAILY_REMINDER_ID,
        title: '✨ LifeWisp 감정 기록',
        body: '오늘 하루의 감정은 어떠셨나요? 잠깐만 시간을 내서 기록해보세요! 💕',
        time: _reminderTime,
        enableSound: _soundEnabled,
        enableVibration: _vibrationEnabled,
        payload: 'daily_reminder',
      );

      print('Daily reminder scheduled successfully at ${_reminderTime.hour}:${_reminderTime.minute}');
    } catch (e) {
      print('Error scheduling daily reminder: $e');
      // 사용자에게 에러 알림 (선택사항)
      // _showNotificationError(e.toString());
    }
  }

  // 데일리 알림 취소 - 수정됨
  Future<void> _cancelDailyReminder() async {
    try {
      await _notificationService.cancelNotification(DAILY_REMINDER_ID);
      print('Daily reminder cancelled successfully');
    } catch (e) {
      print('Error cancelling daily reminder: $e');
    }
  }

  Future<bool> sendTestNotification() async {
    try {
      // 권한 확인
      bool hasPermission = await _notificationService.hasPermissions();
      if (!hasPermission) {
        hasPermission = await _notificationService.requestPermissions();
        if (!hasPermission) {
          print('Test notification failed: No permission');
          return false;
        }
      }

      await _notificationService.showNotification(
        id: 9999,
        title: '🧪 테스트 알림',
        body: '알림이 정상적으로 작동하고 있어요! 🎉',
        enableSound: _soundEnabled,
        enableVibration: _vibrationEnabled,
      );

      print('Test notification sent successfully');
      return true;
    } catch (e) {
      print('테스트 알림 전송 실패: $e');
      return false;
    }
  }


  // 테마 설정
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveSettings();
    notifyListeners();
  }

  // 닉네임 설정
  Future<void> setUserNickname(String nickname) async {
    _userNickname = nickname;
    if (_userEmail != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userNickname_$_userEmail', nickname);
    }
    await _saveSettings();
    notifyListeners();
  }

  // 프로필 사진 설정
  Future<void> setProfileImage(String imagePath) async {
    _profileImagePath = imagePath;
    await _saveSettings();
    notifyListeners();
  }

  // 알림 설정
  Future<void> setNotificationEnabled(bool enabled) async {
    try {
      _notificationEnabled = enabled;

      if (enabled) {
        // 알림 활성화 시 권한 확인 후 스케줄 설정
        final hasPermission = await requestNotificationPermissions();
        if (hasPermission) {
          await _scheduleDailyReminder();
        } else {
          print('Cannot enable notifications: Permission denied');
          // 권한이 없으면 설정을 다시 false로 변경
          _notificationEnabled = false;
        }
      } else {
        // 알림 비활성화 시 기존 알림 취소
        await _cancelDailyReminder();
      }

      await _saveSettings();
      notifyListeners();
    } catch (e) {
      print('Error setting notification enabled: $e');
    }
  }

  // 알림 시간 설정
  Future<void> setReminderTime(TimeOfDay time) async {
    try {
      _reminderTime = time;

      // 알림이 활성화되어 있으면 새 시간으로 재스케줄
      if (_notificationEnabled) {
        await _scheduleDailyReminder();
      }

      await _saveSettings();
      notifyListeners();
    } catch (e) {
      print('Error setting reminder time: $e');
    }
  }


  // 주 시작 요일 설정
  Future<void> setWeekStartDay(int day) async {
    _weekStartDay = day;
    await _saveSettings();
    notifyListeners();
  }

  // 소리 설정
  Future<void> setSoundEnabled(bool enabled) async {
    try {
      _soundEnabled = enabled;

      // 알림이 활성화되어 있으면 새 설정으로 재스케줄
      if (_notificationEnabled) {
        await _scheduleDailyReminder();
      }

      await _saveSettings();
      notifyListeners();
    } catch (e) {
      print('Error setting sound enabled: $e');
    }
  }

  // 진동 설정
  Future<void> setVibrationEnabled(bool enabled) async {
    try {
      _vibrationEnabled = enabled;

      // 알림이 활성화되어 있으면 새 설정으로 재스케줄
      if (_notificationEnabled) {
        await _scheduleDailyReminder();
      }

      await _saveSettings();
      notifyListeners();
    } catch (e) {
      print('Error setting vibration enabled: $e');
    }
  }

  Future<void> debugNotifications() async {
    final pendingNotifications = await _notificationService.getPendingNotifications();
    print('Pending notifications: ${pendingNotifications.length}');
    for (final notification in pendingNotifications) {
      print('ID: ${notification.id}, Title: ${notification.title}');
    }
  }
}

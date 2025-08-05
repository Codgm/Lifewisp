import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userNickname;
  String? _profileImagePath;
  ThemeMode _themeMode = ThemeMode.light;
  
  // 앱 설정들
  bool _notificationEnabled = true;
  TimeOfDay _reminderTime = TimeOfDay(hour: 21, minute: 0);
  int _weekStartDay = 1; // 0: 일요일, 1: 월요일
  String _selectedFont = 'Jua';
  double _fontSize = 16.0;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userNickname => _userNickname;
  String? get profileImagePath => _profileImagePath;
  ThemeMode get themeMode => _themeMode;
  
  // 앱 설정 getters
  bool get notificationEnabled => _notificationEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  int get weekStartDay => _weekStartDay;
  String get selectedFont => _selectedFont;
  double get fontSize => _fontSize;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  // 초기화 시 설정 로드
  Future<void> initialize() async {
    await _loadSettings();
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
    _selectedFont = prefs.getString('selectedFont') ?? 'Jua';
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    
    notifyListeners();
  }

  // 더미 로그인
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _userEmail = email;
    if (_userNickname == null) {
      _userNickname = email.split('@').first;
    }
    await _saveSettings();
    notifyListeners();
    return true;
  }

  // 더미 회원가입
  Future<bool> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _userEmail = email;
    if (_userNickname == null) {
      _userNickname = email.split('@').first;
    }
    await _saveSettings();
    notifyListeners();
    return true;
  }

  // 로그아웃
  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    notifyListeners();
  }

  // 비밀번호 찾기(더미)
  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
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
    _notificationEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // 알림 시간 설정
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    await _saveSettings();
    notifyListeners();
  }

  // 주 시작 요일 설정
  Future<void> setWeekStartDay(int day) async {
    _weekStartDay = day;
    await _saveSettings();
    notifyListeners();
  }

  // 폰트 설정
  Future<void> setFontSettings(String font, double size) async {
    _selectedFont = font;
    _fontSize = size;
    await _saveSettings();
    notifyListeners();
  }

  // 소리 설정
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }

  // 진동 설정
  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }
} 
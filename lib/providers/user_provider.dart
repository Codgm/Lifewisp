import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

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
  String? get profileImageUrl => _profileImagePath;
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
    await _checkLoginStatus();
  }

  // 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');
    final savedPassword = prefs.getString('userPassword');
    
    if (savedEmail != null && savedPassword != null) {
      // 자동 로그인 (실제 구현시 토큰 검증 필요)
      _isLoggedIn = true;
      _userEmail = savedEmail;
      _userNickname = prefs.getString('userNickname') ?? savedEmail.split('@').first;
      notifyListeners();
    }
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

  // 로그인
  Future<bool> login(String email, String password) async {
    // 입력 유효성 검사
    if (!_isValidEmail(email)) {
      throw Exception('올바른 이메일 형식을 입력해주세요.');
    }
    
    if (!_isValidPassword(password)) {
      throw Exception('비밀번호는 최소 6자 이상이어야 합니다.');
    }

    await Future.delayed(const Duration(seconds: 1)); // 실제 API 호출 시뮬레이션

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPassword = prefs.getString('userPassword_$email');
      
      if (savedPassword != null && savedPassword == _hashPassword(password)) {
        // 로그인 성공
        _isLoggedIn = true;
        _userEmail = email;
        _userNickname = prefs.getString('userNickname_$email') ?? email.split('@').first;
        
        // 로그인 정보 저장
        await prefs.setString('userEmail', email);
        await prefs.setString('userPassword', _hashPassword(password));
        await prefs.setString('userNickname_$email', _userNickname!);
        
        await _saveSettings();
        notifyListeners();
        return true;
      } else {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      }
    } catch (e) {
      throw Exception('로그인에 실패했습니다: ${e.toString()}');
    }
  }

  // 회원가입
  Future<bool> signup(String email, String password, String nickname) async {
    // 입력 유효성 검사
    if (!_isValidEmail(email)) {
      throw Exception('올바른 이메일 형식을 입력해주세요.');
    }
    
    if (!_isValidPassword(password)) {
      throw Exception('비밀번호는 최소 6자 이상이어야 합니다.');
    }
    
    if (nickname.trim().isEmpty) {
      throw Exception('닉네임을 입력해주세요.');
    }

    await Future.delayed(const Duration(seconds: 1)); // 실제 API 호출 시뮬레이션

    try {
      final prefs = await SharedPreferences.getInstance();
      final existingUser = prefs.getString('userPassword_$email');
      
      if (existingUser != null) {
        throw Exception('이미 가입된 이메일입니다.');
      }
      
      // 회원가입 성공
      _isLoggedIn = true;
      _userEmail = email;
      _userNickname = nickname;
      
      // 사용자 정보 저장
      await prefs.setString('userEmail', email);
      await prefs.setString('userPassword', _hashPassword(password));
      await prefs.setString('userNickname_$email', nickname);
      await prefs.setString('userPassword_$email', _hashPassword(password));
      
      await _saveSettings();
      notifyListeners();
      return true;
    } catch (e) {
      throw Exception('회원가입에 실패했습니다: ${e.toString()}');
    }
  }

  // 로그아웃
  Future<void> logout() async {
    _isLoggedIn = false;
    _userEmail = null;
    _userNickname = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('userPassword');
    
    notifyListeners();
  }

  // 비밀번호 찾기
  Future<bool> resetPassword(String email) async {
    if (!_isValidEmail(email)) {
      throw Exception('올바른 이메일 형식을 입력해주세요.');
    }

    await Future.delayed(const Duration(seconds: 1)); // 실제 API 호출 시뮬레이션

    try {
      final prefs = await SharedPreferences.getInstance();
      final existingUser = prefs.getString('userPassword_$email');
      
      if (existingUser == null) {
        throw Exception('가입되지 않은 이메일입니다.');
      }
      
      // 실제 구현시 이메일 발송 로직 추가
      return true;
    } catch (e) {
      throw Exception('비밀번호 재설정에 실패했습니다: ${e.toString()}');
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

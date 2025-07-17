import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userNickname;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userNickname => _userNickname;

  // 더미 로그인
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _userEmail = email;
    _userNickname = email.split('@').first;
    notifyListeners();
    return true;
  }

  // 더미 회원가입
  Future<bool> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _userEmail = email;
    _userNickname = email.split('@').first;
    notifyListeners();
    return true;
  }

  // 로그아웃
  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    _userNickname = null;
    notifyListeners();
  }

  // 비밀번호 찾기(더미)
  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
} 
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_model;

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  String? _userId;
  String? _userEmail;
  String? _userNickname;
  String? _userPhotoUrl;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userNickname => _userNickname;
  String? get userPhotoUrl => _userPhotoUrl;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  
  // 현재 사용자 정보를 User 모델로 반환
  app_model.User? get currentUser {
    if (!_isAuthenticated || _userId == null) return null;
    
    return app_model.User(
      userId: _userId!,
      nickname: _userNickname ?? _userEmail?.split('@').first ?? '사용자',
      email: _userEmail,
      photoUrl: _userPhotoUrl,
    );
  }

  // 이메일/비밀번호 로그인
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        _userId = user.uid;
        _userEmail = user.email;
        _userNickname = await _getNickname(user.uid) ?? user.displayName ?? user.email?.split('@').first;
        _userPhotoUrl = user.photoURL;
        _isAuthenticated = true;
        
        // 닉네임 저장
        if (_userNickname != null) {
          await _saveNickname(user.uid, _userNickname!);
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  // 이메일/비밀번호 회원가입
  Future<bool> signUp(String email, String password, String nickname) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // 사용자 프로필 업데이트 (닉네임 설정)
        await user.updateDisplayName(nickname);
        
        _userId = user.uid;
        _userEmail = user.email;
        _userNickname = nickname;
        _isAuthenticated = true;
        
        // 닉네임 저장
        await _saveNickname(user.uid, nickname);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Firebase 로그아웃
      await _firebaseAuth.signOut();
      
      // 구글 로그인 사용자인 경우 구글 로그아웃도 실행
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      _userId = null;
      _userEmail = null;
      _userNickname = null;
      _userPhotoUrl = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  // 자동 로그인 체크
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Firebase 현재 사용자 확인
      final currentUser = _firebaseAuth.currentUser;
      
      if (currentUser != null) {
        _userId = currentUser.uid;
        _userEmail = currentUser.email;
        _userNickname = await _getNickname(currentUser.uid) ?? 
                       currentUser.displayName ?? 
                       currentUser.email?.split('@').first;
        _userPhotoUrl = currentUser.photoURL;
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('자동 로그인 체크 오류: $e');
    }
  }
  
  // 구글 로그인
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 구글 로그인 프로세스 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 사용자가 로그인 취소
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // 구글 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Firebase 인증 정보 생성
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Firebase로 로그인
      firebase_auth.UserCredential userCredential;
      try {
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      } catch (e) {
        print('Firebase 인증 오류: $e');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final user = userCredential.user;
      
      if (user != null) {
        _userId = user.uid;
        _userEmail = user.email;
        _userNickname = await _getNickname(user.uid) ?? user.displayName ?? user.email?.split('@').first;
        _userPhotoUrl = user.photoURL;
        _isAuthenticated = true;
        
        // 닉네임이 없는 경우 저장
        if (_userNickname != null && (await _getNickname(user.uid)) == null) {
          await _saveNickname(user.uid, _userNickname!);
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('구글 로그인 오류: $e');
      return false;
    }
  }

  // 비밀번호 재설정
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('비밀번호 재설정 이메일 전송 중 오류가 발생했습니다: $e');
    }
  }
  
  // 닉네임 저장
  Future<void> _saveNickname(String userId, String nickname) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname_$userId', nickname);
    } catch (e) {
      print('닉네임 저장 오류: $e');
    }
  }
  
  // 닉네임 가져오기
  Future<String?> _getNickname(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('nickname_$userId');
    } catch (e) {
      print('닉네임 조회 오류: $e');
      return null;
    }
  }
  
  // Firebase 인증 오류 처리
  Exception _handleFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('등록되지 않은 이메일입니다.');
      case 'wrong-password':
        return Exception('비밀번호가 올바르지 않습니다.');
      case 'invalid-email':
        return Exception('유효하지 않은 이메일 형식입니다.');
      case 'user-disabled':
        return Exception('비활성화된 계정입니다.');
      case 'email-already-in-use':
        return Exception('이미 사용 중인 이메일입니다.');
      case 'operation-not-allowed':
        return Exception('이 로그인 방식은 현재 지원되지 않습니다.');
      case 'weak-password':
        return Exception('비밀번호가 너무 약합니다. 6자 이상 입력해주세요.');
      case 'network-request-failed':
        return Exception('네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.');
      case 'too-many-requests':
        return Exception('너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.');
      default:
        return Exception('인증 오류가 발생했습니다: ${e.message}');
    }
  }
}
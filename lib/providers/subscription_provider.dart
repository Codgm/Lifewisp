// providers/subscription_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionTier {
  free,
  premium,
}

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionTier _currentTier = SubscriptionTier.free;
  DateTime? _subscriptionEndDate;
  bool _isLoading = false;
  String? _currentUserId; // 현재 사용자 ID 추가
  bool get canUseCloudStorage => isPremium;
  bool get canAutoSync => isPremium;
  bool get canBackupToCloud => isPremium;

  // 사용자별 AI 채팅 사용량 추적
  Map<String, int> _userAiChatUsage = {};
  Map<String, DateTime> _userLastResetDate = {};

  // 무료 사용자 제한
  static const int _maxRecordsPerMonthFree = 30;
  static const int _maxAiChatPerMonthFree = 5;

  // Getters
  SubscriptionTier get currentTier => _currentTier;
  bool get isPremium => _currentTier == SubscriptionTier.premium;
  bool get isFree => _currentTier == SubscriptionTier.free;
  DateTime? get subscriptionEndDate => _subscriptionEndDate;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;

  // AI 채팅 관련 getters (현재 사용자 기준)
  int get aiChatUsesThisMonth {
    if (_currentUserId == null) return 0;
    _checkAndResetMonthlyUsage(_currentUserId!);
    return _userAiChatUsage[_currentUserId] ?? 0;
  }

  int get maxAiChatPerMonth => isFree ? _maxAiChatPerMonthFree : -1; // -1 = unlimited
  bool get canUseAiChat => isPremium || aiChatUsesThisMonth < _maxAiChatPerMonthFree;
  int get remainingAiChats => isFree ? (_maxAiChatPerMonthFree - aiChatUsesThisMonth).clamp(0, _maxAiChatPerMonthFree) : -1;

  // 기능 접근 권한
  bool get canUseAIChat => canUseAiChat;
  bool get canUseAIGeneration => isPremium;
  bool get canUseAdvancedAnalysis => isPremium;

  int get maxRecordsPerMonth => isFree ? _maxRecordsPerMonthFree : -1;

  // 사용자 초기화
  Future<void> initializeUser(String userId) async {
    if (_currentUserId == userId) return; // 이미 같은 사용자

    _isLoading = true;
    _currentUserId = userId;
    notifyListeners();

    try {
      await _loadUserSubscriptionData(userId);
      await _loadUserUsageData(userId);
    } catch (e) {
      print('구독 정보 사용자 초기화 실패: $e');
      // 기본값으로 설정
      _currentTier = SubscriptionTier.premium; // 테스트용
      _subscriptionEndDate = DateTime.now().add(Duration(days: 365));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자별 구독 데이터 로드
  Future<void> _loadUserSubscriptionData(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    // 사용자별 구독 정보 키
    final tierKey = 'subscription_tier_$userId';
    final endDateKey = 'subscription_end_date_$userId';

    // 저장된 구독 정보 불러오기
    final tierString = prefs.getString(tierKey);
    if (tierString != null) {
      _currentTier = tierString == 'premium' ? SubscriptionTier.premium : SubscriptionTier.free;
    } else {
      // 테스트용으로 기본 프리미엄 상태로 설정
      _currentTier = SubscriptionTier.premium;
      _subscriptionEndDate = DateTime.now().add(Duration(days: 365));

      // SharedPreferences에 저장
      await prefs.setString(tierKey, 'premium');
      await prefs.setString(endDateKey, _subscriptionEndDate!.toIso8601String());
    }

    // 구독 만료일 불러오기
    final endDateString = prefs.getString(endDateKey);
    if (endDateString != null) {
      _subscriptionEndDate = DateTime.parse(endDateString);

      // 만료된 구독 확인
      if (_subscriptionEndDate != null &&
          DateTime.now().isAfter(_subscriptionEndDate!) &&
          _currentTier == SubscriptionTier.premium) {
        await _downgradeToFree(userId);
      }
    }
  }

  // 사용자별 사용량 데이터 로드
  Future<void> _loadUserUsageData(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    // 사용자별 사용량 정보
    final usageKey = 'ai_chat_usage_$userId';
    final resetDateKey = 'ai_chat_reset_date_$userId';

    _userAiChatUsage[userId] = prefs.getInt(usageKey) ?? 0;

    final resetDateString = prefs.getString(resetDateKey);
    if (resetDateString != null) {
      _userLastResetDate[userId] = DateTime.parse(resetDateString);
    } else {
      _userLastResetDate[userId] = DateTime.now();
    }
  }

  // 사용자별 사용량 데이터 저장
  Future<void> _saveUserUsageData(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    final usageKey = 'ai_chat_usage_$userId';
    final resetDateKey = 'ai_chat_reset_date_$userId';

    await prefs.setInt(usageKey, _userAiChatUsage[userId] ?? 0);
    await prefs.setString(resetDateKey, (_userLastResetDate[userId] ?? DateTime.now()).toIso8601String());
  }

  // AI 채팅 사용량 추적 및 월별 초기화 (사용자별)
  void _checkAndResetMonthlyUsage(String userId) {
    final now = DateTime.now();
    final lastReset = _userLastResetDate[userId] ?? DateTime.now();
    final isNewMonth = now.month != lastReset.month || now.year != lastReset.year;

    if (isNewMonth) {
      _userAiChatUsage[userId] = 0;
      _userLastResetDate[userId] = now;
      _saveUserUsageData(userId); // 비동기로 저장
    }
  }

  // AI 채팅 사용량 증가 (현재 사용자)
  void incrementAiChatUsage() async {
    if (_currentUserId == null) return;

    if (isFree) {
      _checkAndResetMonthlyUsage(_currentUserId!);
      final currentUsage = _userAiChatUsage[_currentUserId] ?? 0;
      if (currentUsage < _maxAiChatPerMonthFree) {
        _userAiChatUsage[_currentUserId!] = currentUsage + 1;
        await _saveUserUsageData(_currentUserId!);
        notifyListeners();
      }
    }
  }

  // 프리미엄 구독 (현재 사용자)
  Future<bool> upgradeToPremium() async {
    if (_currentUserId == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // 실제로는 여기서 in_app_purchase 패키지를 사용
      await Future.delayed(Duration(seconds: 2));

      _currentTier = SubscriptionTier.premium;
      _subscriptionEndDate = DateTime.now().add(Duration(days: 30));

      // 사용자별 구독 정보 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('subscription_tier_$_currentUserId', 'premium');
      await prefs.setString('subscription_end_date_$_currentUserId', _subscriptionEndDate!.toIso8601String());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('구독 업그레이드 실패: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 구독 취소 (현재 사용자)
  Future<void> cancelSubscription() async {
    if (_currentUserId != null) {
      await _downgradeToFree(_currentUserId!);
    }
  }

  // 무료로 다운그레이드 (특정 사용자)
  Future<void> _downgradeToFree(String userId) async {
    _currentTier = SubscriptionTier.free;
    _subscriptionEndDate = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_tier_$userId', 'free');
    await prefs.remove('subscription_end_date_$userId');

    notifyListeners();
  }

  // 기능 사용 가능 여부 체크
  bool canUseFeature(String featureName) {
    switch (featureName) {
      case 'ai_chat':
        return canUseAiChat;
      case 'ai_generation':
      case 'advanced_analysis':
        return isPremium;
      case 'cloud_storage':
      case 'auto_sync':
      case 'cloud_backup':
        return isPremium;
      case 'manual_record':
      case 'basic_stats':
        return true;
      default:
        return false;
    }
  }

  // 기능별 제한 정보 반환 (현재 사용자)
  Map<String, dynamic> getFeatureLimits() {
    return {
      'user_id': _currentUserId,
      'records_per_month': maxRecordsPerMonth,
      'ai_chat_per_month': maxAiChatPerMonth,
      'ai_chat_used': aiChatUsesThisMonth,
      'ai_chat_remaining': remainingAiChats,
      'unlimited_ai_chat': isPremium,
      'advanced_analysis': isPremium,
      'cloud_storage': canUseCloudStorage,
      'auto_sync': canAutoSync,
      'cloud_backup': canBackupToCloud,
      'premium_expires': _subscriptionEndDate?.toIso8601String(),
    };
  }

  // 사용량 통계 (현재 사용자)
  Map<String, dynamic> getUsageStats() {
    return {
      'user_id': _currentUserId,
      'subscription_tier': _currentTier.toString().split('.').last,
      'is_premium': isPremium,
      'ai_chat_uses_this_month': aiChatUsesThisMonth,
      'ai_chat_limit_reached': !canUseAiChat && isFree,
      'premium_expiry': _subscriptionEndDate?.toIso8601String(),
      'days_until_expiry': _subscriptionEndDate != null
          ? _subscriptionEndDate!.difference(DateTime.now()).inDays
          : null,
    };
  }

  // 사용량 제한 체크 (현재 사용자)
  Future<bool> checkUsageLimit(String featureType) async {
    if (_currentUserId == null) return false;
    if (isPremium) return true;

    switch (featureType) {
      case 'emotion_record':
        return true; // 임시로 항상 true
      case 'ai_chat':
        return canUseAiChat;
      default:
        return true;
    }
  }

  // 사용자 변경 시 데이터 클리어
  void clearForUserChange() {
    _currentUserId = null;
    _currentTier = SubscriptionTier.free;
    _subscriptionEndDate = null;
    // 사용량 데이터는 유지 (다른 사용자 데이터)
    notifyListeners();
  }

  // 특정 사용자의 사용량 데이터 삭제
  Future<void> clearUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    // 해당 사용자의 모든 키 삭제
    await prefs.remove('subscription_tier_$userId');
    await prefs.remove('subscription_end_date_$userId');
    await prefs.remove('ai_chat_usage_$userId');
    await prefs.remove('ai_chat_reset_date_$userId');

    // 메모리에서도 제거
    _userAiChatUsage.remove(userId);
    _userLastResetDate.remove(userId);

    print('Cleared subscription data for user $userId');
  }

  // 다중 사용자 지원을 위한 사용량 조회
  int getAiChatUsageForUser(String userId) {
    _checkAndResetMonthlyUsage(userId);
    return _userAiChatUsage[userId] ?? 0;
  }

  // 디버그용 메서드들
  void resetUsage() async {
    if (_currentUserId != null) {
      _userAiChatUsage[_currentUserId!] = 0;
      _userLastResetDate[_currentUserId!] = DateTime.now();
      await _saveUserUsageData(_currentUserId!);
      notifyListeners();
    }
  }

  void setTrialPremium() async {
    if (_currentUserId == null) return;

    _currentTier = SubscriptionTier.premium;
    _subscriptionEndDate = DateTime.now().add(Duration(days: 7));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_tier_$_currentUserId', 'premium');
    await prefs.setString('subscription_end_date_$_currentUserId', _subscriptionEndDate!.toIso8601String());

    notifyListeners();
  }

  void simulateNewMonth() async {
    if (_currentUserId != null) {
      _userAiChatUsage[_currentUserId!] = 0;
      _userLastResetDate[_currentUserId!] = DateTime.now();
      await _saveUserUsageData(_currentUserId!);
      notifyListeners();
    }
  }

  // 상태 저장/로드
  void saveState() async {
    if (_currentUserId != null) {
      await _saveUserUsageData(_currentUserId!);
    }
    debugPrint('Saving subscription state: ${getUsageStats()}');
  }

  void loadState() {
    debugPrint('Loading subscription state for user: $_currentUserId');
  }

  @override
  void dispose() {
    saveState();
    super.dispose();
  }
}
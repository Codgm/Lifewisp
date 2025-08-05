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
  
  // AI 채팅 사용량 추적
  int _aiChatUsesThisMonth = 0;
  DateTime _lastAiChatResetDate = DateTime.now();
  
  // 무료 사용자 제한
  static const int _maxRecordsPerMonthFree = 30;
  static const int _maxAiChatPerMonthFree = 5;

  // Getters
  SubscriptionTier get currentTier => _currentTier;
  bool get isPremium => _currentTier == SubscriptionTier.premium;
  bool get isFree => _currentTier == SubscriptionTier.free;
  DateTime? get subscriptionEndDate => _subscriptionEndDate;
  bool get isLoading => _isLoading;
  
  // AI 채팅 관련 getters
  int get aiChatUsesThisMonth {
    _checkAndResetMonthlyUsage();
    return _aiChatUsesThisMonth;
  }
  
  int get maxAiChatPerMonth => isFree ? _maxAiChatPerMonthFree : -1; // -1 = unlimited
  bool get canUseAiChat => isPremium || aiChatUsesThisMonth < _maxAiChatPerMonthFree;
  int get remainingAiChats => isFree ? (_maxAiChatPerMonthFree - aiChatUsesThisMonth).clamp(0, _maxAiChatPerMonthFree) : -1;

  // 무료 사용자 제한사항 체크 (테스트용으로 임시 해제)
  bool get canUseAIChat => canUseAiChat; // AI 채팅 사용량 기반으로 변경
  bool get canUseAIGeneration => isPremium;
  bool get canUseAdvancedAnalysis => isPremium;

  // 무료 사용자는 월 10개 기록 제한 (예시) - 테스트용으로 증가
  int get maxRecordsPerMonth => isFree ? _maxRecordsPerMonthFree : -1; // 무제한은 -1로 표시

  // 초기화
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // // 저장된 구독 정보 불러오기
      // final tierString = prefs.getString('subscription_tier') ?? 'free';
      // _currentTier = tierString == 'premium'
      //     ? SubscriptionTier.premium
      //     : SubscriptionTier.free;

      // 테스트용으로 기본 프리미엄 상태로 설정
      _currentTier = SubscriptionTier.premium;
      _subscriptionEndDate = DateTime.now().add(Duration(days: 365)); // 1년 구독

            // 구독 만료일 불러오기
      // final endDateString = prefs.getString('subscription_end_date');
      // if (endDateString != null) {
      //   _subscriptionEndDate = DateTime.parse(endDateString);

      // SharedPreferences에 저장
      await prefs.setString('subscription_tier', 'premium');
      await prefs.setString('subscription_end_date', _subscriptionEndDate!.toIso8601String());

    } catch (e) {
      print('구독 정보 초기화 실패: $e');
      _currentTier = SubscriptionTier.premium; // 실패해도 프리미엄으로 설정
    }

    _isLoading = false;
    notifyListeners();
  }

  // AI 채팅 사용량 추적 및 월별 초기화
  void _checkAndResetMonthlyUsage() {
    final now = DateTime.now();
    final isNewMonth = now.month != _lastAiChatResetDate.month || now.year != _lastAiChatResetDate.year;

    if (isNewMonth) {
      _aiChatUsesThisMonth = 0;
      _lastAiChatResetDate = now;
    }
  }

  // AI 채팅 사용량 증가
  void incrementAiChatUsage() {
    if (isFree) {
      _checkAndResetMonthlyUsage();
      if (_aiChatUsesThisMonth < _maxAiChatPerMonthFree) {
        _aiChatUsesThisMonth++;
        notifyListeners();
      }
    }
  }

  // 프리미엄 구독
  Future<bool> upgradeToPremium() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 실제로는 여기서 in_app_purchase 패키지를 사용
      // 지금은 시뮬레이션
      await Future.delayed(Duration(seconds: 2));

      _currentTier = SubscriptionTier.premium;
      _subscriptionEndDate = DateTime.now().add(Duration(days: 30)); // 1개월 구독

      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('subscription_tier', 'premium');
      await prefs.setString('subscription_end_date', _subscriptionEndDate!.toIso8601String());

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

  // 구독 취소
  Future<void> cancelSubscription() async {
    await _downgradeToFree();
  }

  // 무료로 다운그레이드
  Future<void> _downgradeToFree() async {
    _currentTier = SubscriptionTier.free;
    _subscriptionEndDate = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_tier', 'free');
    await prefs.remove('subscription_end_date');

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
      case 'manual_record':
      case 'basic_stats':
        return true; // 무료 사용자도 사용 가능
      default:
        return false;
    }
  }

  // 기능별 제한 정보 반환
  Map<String, dynamic> getFeatureLimits() {
    return {
      'records_per_month': maxRecordsPerMonth,
      'ai_chat_per_month': maxAiChatPerMonth,
      'ai_chat_used': aiChatUsesThisMonth,
      'ai_chat_remaining': remainingAiChats,
      'unlimited_ai_chat': isPremium,
      'advanced_analysis': isPremium,
      'premium_expires': _subscriptionEndDate?.toIso8601String(),
    };
  }

  // 사용량 통계
  Map<String, dynamic> getUsageStats() {
    return {
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

  // 사용량 제한 체크 (예: 월별 기록 개수)
  Future<bool> checkUsageLimit(String featureType) async {
    if (isPremium) return true; // 프리미엄은 제한 없음

    // 실제로는 데이터베이스에서 이번 달 사용량을 확인
    // 지금은 시뮬레이션
    switch (featureType) {
      case 'emotion_record':
      // 예: 이번 달 기록 개수 확인
        return true; // 임시로 항상 true
      case 'ai_chat':
        return canUseAiChat;
      default:
        return true;
    }
  }

  // 디버그용 - 사용량 리셋
  void resetUsage() {
    _aiChatUsesThisMonth = 0;
    _lastAiChatResetDate = DateTime.now();
    notifyListeners();
  }

  // 디버그용 - 무료 체험 설정
  void setTrialPremium() {
    _currentTier = SubscriptionTier.premium;
    _subscriptionEndDate = DateTime.now().add(Duration(days: 7)); // 7일 체험
    notifyListeners();
  }

  // 월 초기화 (테스트용)
  void simulateNewMonth() {
    _aiChatUsesThisMonth = 0;
    _lastAiChatResetDate = DateTime.now();
    notifyListeners();
  }

  // 상태 저장/로드 (실제 앱에서는 SharedPreferences나 Hive 사용)
  void saveState() {
    // TODO: 실제 저장 로직 구현
    debugPrint('Saving subscription state: ${getUsageStats()}');
  }

  void loadState() {
    // TODO: 실제 로드 로직 구현
    debugPrint('Loading subscription state');
  }

  @override
  void dispose() {
    saveState();
    super.dispose();
  }
}
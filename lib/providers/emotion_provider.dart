import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lifewisp/providers/subscription_provider.dart';
import '../models/emotion_record.dart';
import '../services/local_storage_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/sync_service.dart';
import '../providers/auth_provider.dart';

class EmotionProvider with ChangeNotifier {
  final List<EmotionRecord> _records = [];
  final LocalStorageService _localStorage = LocalStorageService();
  final CloudStorageService _cloudStorage = CloudStorageService();
  final SyncService _syncService = SyncService();

  static final Map<String, Uint8List> _webImageCache = {};
  bool _initialized = false;
  bool _isOnline = false;

  // AuthProvider 참조
  AuthProvider? _authProvider;
  SubscriptionProvider? _subscriptionProvider;

  List<EmotionRecord> get records => List.from(_records);
  bool get initialized => _initialized;
  bool get isOnline => _isOnline;
  String? get currentUserId => _authProvider?.userId;
  SyncStatus get syncStatus => _syncService.syncStatus;
  String? get lastSyncError => _syncService.lastError;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;

  bool get canUseCloudStorage => _subscriptionProvider?.canUseCloudStorage ?? false;
  bool get canAutoSync => _subscriptionProvider?.canAutoSync ?? false;

  // 동기화 상태 스트림
  Stream<SyncStatus> get syncStatusStream => _syncService.syncStatusStream;

  // AuthProvider 설정 및 초기화
  Future<void> initialize(AuthProvider authProvider) async {
    _authProvider = authProvider;
    _subscriptionProvider =  _subscriptionProvider;

    // AuthProvider의 인증 상태 변경 감지
    _authProvider!.addListener(_onAuthStateChanged);
    // SubscriptionProvider의 구독 상태 변경 감지
    _subscriptionProvider!.addListener(_onSubscriptionStateChanged);

    // 연결 상태 모니터링 시작
    _startConnectivityMonitoring();

    // 현재 로그인되어 있다면 데이터 로드 및 동기화
    if (_authProvider!.isAuthenticated) {
      await _initializeUserData();
    }
  }

  // 구독 상태 변경 시 호출되는 핸들러
  void _onSubscriptionStateChanged() async {
    if (!canUseCloudStorage) {
      // 구독이 해지되면 자동 동기화 중단
      _syncService.stopAutoSync();
      print('Cloud storage disabled due to subscription downgrade');
    } else if (_authProvider?.isAuthenticated == true && _isOnline) {
      // 구독이 활성화되면 자동 동기화 시작
      final userId = _authProvider!.userId!;
      _syncService.startAutoSync(userId);
      print('Cloud storage enabled due to subscription upgrade');
    }
    notifyListeners();
  }

  // 연결 상태 모니터링
  void _startConnectivityMonitoring() {
    _cloudStorage.connectivityStream.listen((isConnected) async {
      _isOnline = isConnected;
      notifyListeners();

      // 온라인 상태가 되면 자동 동기화 시도
      if (isConnected && 
          _authProvider?.isAuthenticated == true && 
          canUseCloudStorage) {
        await _syncService.syncIncremental(_authProvider!.userId!);
      }
    });
  }

  // 사용자 데이터 초기화
  Future<void> _initializeUserData() async {
    final userId = _authProvider!.userId!;

    try {
      // 1. 로컬 데이터 로드
      await loadRecords();

      // 2. 연결 상태 확인
      _isOnline = await _cloudStorage.isConnected();

      // 3. 온라인이면 동기화 시작
      if (_isOnline && canUseCloudStorage) {
        // 백그라운드에서 동기화 실행
        _syncService.syncData(userId, isBackground: true).then((success) {
          if (success) {
            // 동기화 완료 후 로컬 데이터 다시 로드
            loadRecords();
          }
        });

        // 자동 동기화 시작
        if (canAutoSync) {
          _syncService.startAutoSync(userId);
        }
      }

      print('User data initialized for $userId');
    } catch (e) {
      print('Error initializing user data: $e');
    }
  }

  // 인증 상태 변경 시 호출되는 핸들러
  void _onAuthStateChanged() async {
    if (_authProvider!.isAuthenticated) {
      // 로그인됨 - 해당 사용자 데이터 로드 및 동기화
      await _initializeUserData();
    } else {
      // 로그아웃됨 - 메모리에서 데이터 정리
      _clearMemoryData();
      _syncService.stopAutoSync();
    }
  }

  // 메모리에서 데이터 정리 (로그아웃 시)
  void _clearMemoryData() {
    _records.clear();
    _initialized = false;
    _isOnline = false;

    // 웹 이미지 캐시도 정리
    if (kIsWeb) {
      clearAllWebImages();
    }

    notifyListeners();
  }

  // 사용자별 데이터 로드
  Future<void> loadRecords() async {
    final userId = _authProvider?.userId;
    if (userId == null) {
      print('Cannot load records: User not authenticated');
      return;
    }

    try {
      // 기존 데이터가 있다면 마이그레이션 (첫 로그인 시)
      await _localStorage.migrateOldDataToUser(userId);

      final loaded = await _localStorage.loadEmotionRecords(userId);
      _records.clear();
      _records.addAll(loaded);
      _initialized = true;

      print('Loaded ${loaded.length} records for user $userId');
    } catch (e) {
      print('Error loading records: $e');
      _initialized = true; // 에러가 있어도 초기화는 완료로 처리
    }

    notifyListeners();
  }

  // 기록 추가
  Future<void> addRecord(EmotionRecord record) async {
    final userId = _authProvider?.userId;
    if (userId == null) {
      throw Exception('사용자가 로그인되지 않았습니다.');
    }

    // 로컬에 추가
    _records.add(record);
    await _localStorage.addEmotionRecord(record, userId);
    notifyListeners();

    // 프리미엄 사용자이고 온라인이면 즉시 동기화 시도
    if (_isOnline && canUseCloudStorage) {
      _syncService.syncRecord(record, userId);
    } else if (!canUseCloudStorage) {
      print('Record saved locally only (Free user)');
    }

      print('Added record for user $userId (Cloud sync: $canUseCloudStorage)');
    }

  // 기록 삭제
  Future<void> deleteRecord(EmotionRecord record) async {
    final userId = _authProvider?.userId;
    if (userId == null) {
      throw Exception('사용자가 로그인되지 않았습니다.');
    }

    // 웹 이미지 삭제
    if (kIsWeb && record.imagePaths.isNotEmpty) {
      for (String imagePath in record.imagePaths) {
        if (imagePath.startsWith('web_image_')) {
          removeWebImage(imagePath);
        }
      }
    }

    // 로컬에서 삭제
    _records.remove(record);
    await _localStorage.removeEmotionRecord(record, userId);
    notifyListeners();

    // 온라인이면 클라우드에서도 삭제
    if (_isOnline && canUseCloudStorage) {
      _syncService.syncDeleteRecord(record.id, userId);
    }

    print('Deleted record for user $userId (Cloud sync: $canUseCloudStorage)');
  }

  // 기록 수정
  Future<void> editRecord(EmotionRecord oldRecord, EmotionRecord newRecord) async {
    final userId = _authProvider?.userId;
    if (userId == null) {
      throw Exception('사용자가 로그인되지 않았습니다.');
    }

    final idx = _records.indexOf(oldRecord);
    if (idx != -1) {
      // 기존 웹 이미지 삭제 (편집 시)
      if (kIsWeb && oldRecord.imagePaths.isNotEmpty) {
        for (String imagePath in oldRecord.imagePaths) {
          if (imagePath.startsWith('web_image_')) {
            removeWebImage(imagePath);
          }
        }
      }

      // 로컬에서 수정
      _records[idx] = newRecord;
      await _localStorage.updateEmotionRecord(oldRecord, newRecord, userId);
      notifyListeners();

      // 온라인이면 즉시 동기화 시도
      if (_isOnline && canUseCloudStorage) {
        _syncService.syncRecord(newRecord, userId);
      }

      print('Edited record for user $userId (Cloud sync: $canUseCloudStorage)');
    }
  }

  // 수동 동기화
  Future<bool> syncNow() async {
    final userId = _authProvider?.userId;
    if (userId == null) return false;
    
    if (!canUseCloudStorage) {
      print('Cloud sync not available for free users');
      return false;
    }

    return await _syncService.syncData(userId);
  }

  // 증분 동기화
  Future<bool> syncIncremental() async {
    final userId = _authProvider?.userId;
    if (userId == null) return false;
    
    if (!canUseCloudStorage) {
      return false;
    }

    final success = await _syncService.syncIncremental(userId);
    if (success) {
      // 동기화 후 로컬 데이터 다시 로드
      await loadRecords();
    }
    return success;
  }

  // 클라우드에서 복원
  Future<bool> restoreFromCloud() async {
    final userId = _authProvider?.userId;
    if (userId == null) return false;
    
    if (!canUseCloudStorage) {
      print('Cloud restore not available for free users');
      return false;
    }

    final success = await _syncService.restoreFromCloud(userId);
    if (success) {
      // 복원 후 로컬 데이터 다시 로드
      await loadRecords();
    }
    return success;
  }

  // 동기화 정보 조회
  Future<Map<String, dynamic>> getSyncInfo() async {
    final userId = _authProvider?.userId;
    if (userId == null) return {};

    return await _syncService.getSyncInfo(userId);
  }

  @override
  void dispose() {
    // AuthProvider 리스너 제거
    if (_authProvider != null) {
      _authProvider!.removeListener(_onAuthStateChanged);
    }
    
    // SubscriptionProvider 리스너 제거
    if (_subscriptionProvider != null) {
      _subscriptionProvider!.removeListener(_onSubscriptionStateChanged);
    }

    // 동기화 서비스 정리
    _syncService.dispose();

    super.dispose();
  }

  // 웹 이미지 관련 메서드들 (기존과 동일)
  static String saveWebImage(Uint8List imageBytes) {
    final imageKey = 'web_image_${DateTime.now().millisecondsSinceEpoch}_${imageBytes.hashCode}';
    _webImageCache[imageKey] = imageBytes;
    return imageKey;
  }

  static Uint8List? getWebImage(String imageKey) {
    return _webImageCache[imageKey];
  }

  static void removeWebImage(String imageKey) {
    _webImageCache.remove(imageKey);
  }

  static List<String> saveWebImages(List<Uint8List> imageBytesList) {
    List<String> imageKeys = [];
    for (Uint8List imageBytes in imageBytesList) {
      imageKeys.add(saveWebImage(imageBytes));
    }
    return imageKeys;
  }

  static void clearUnusedWebImages(List<EmotionRecord> records) {
    if (!kIsWeb) return;

    Set<String> usedKeys = {};
    for (EmotionRecord record in records) {
      if (record.imagePaths.isNotEmpty) {
        for (String imagePath in record.imagePaths) {
          if (imagePath.startsWith('web_image_')) {
            usedKeys.add(imagePath);
          }
        }
      }
    }

    List<String> keysToRemove = [];
    for (String key in _webImageCache.keys) {
      if (!usedKeys.contains(key)) {
        keysToRemove.add(key);
      }
    }

    for (String key in keysToRemove) {
      _webImageCache.remove(key);
    }
  }

  static int getWebImageCacheSize() {
    return _webImageCache.length;
  }

  static void clearAllWebImages() {
    _webImageCache.clear();
  }

  // 오프라인 작업 대기열 관리
  Future<List<EmotionRecord>> getPendingSyncRecords() async {
    final userId = _authProvider?.userId;
    if (userId == null) return [];

    return await _localStorage.getUnsyncedRecords(userId);
  }

  // 네트워크 상태에 따른 UI 힌트
  String getConnectionStatusMessage() {
    if (!canUseCloudStorage) {
      return '로컬 저장만 가능 - 프리미엄으로 업그레이드하여 클라우드 백업을 이용하세요';
    }
    
    if (!_isOnline) {
      return '오프라인 모드 - 변경사항은 다음 연결 시 동기화됩니다';
    }

    switch (syncStatus) {
      case SyncStatus.syncing:
        return '동기화 중...';
      case SyncStatus.success:
        return '모든 변경사항이 클라우드에 동기화되었습니다';
      case SyncStatus.error:
        return '동기화 오류: $lastSyncError';
      case SyncStatus.idle:
      default:
        return '온라인 (클라우드 동기화 활성)';
    }
  }
}
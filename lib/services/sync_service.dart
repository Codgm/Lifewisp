import 'dart:async';
import '../models/emotion_record.dart';
import 'local_storage_service.dart';
import 'cloud_storage_service.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncService {
  final LocalStorageService _localStorage = LocalStorageService();
  final CloudStorageService _cloudStorage = CloudStorageService();

  SyncStatus _syncStatus = SyncStatus.idle;
  String? _lastError;
  DateTime? _lastSyncTime;
  StreamController<SyncStatus>? _syncStatusController;
  Timer? _autoSyncTimer;

  // 자동 동기화 간격 (분)
  static const int autoSyncIntervalMinutes = 30;

  SyncStatus get syncStatus => _syncStatus;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;

  // 동기화 상태 스트림
  Stream<SyncStatus> get syncStatusStream {
    _syncStatusController ??= StreamController<SyncStatus>.broadcast();
    return _syncStatusController!.stream;
  }

  // 자동 동기화 시작
  void startAutoSync(String userId) {
    stopAutoSync(); // 기존 타이머 정리

    _autoSyncTimer = Timer.periodic(
      Duration(minutes: autoSyncIntervalMinutes),
          (timer) async {
        if (await _cloudStorage.isConnected()) {
          await syncData(userId, isBackground: true);
        }
      },
    );

    print('Auto sync started for user $userId (every $autoSyncIntervalMinutes minutes)');
  }

  // 자동 동기화 중지
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    print('Auto sync stopped');
  }

  // 메인 동기화 함수
  Future<bool> syncData(String userId, {bool isBackground = false}) async {
    if (_syncStatus == SyncStatus.syncing) {
      print('Sync already in progress, skipping');
      return false;
    }

    _updateSyncStatus(SyncStatus.syncing);

    try {
      // 인터넷 연결 확인
      if (!await _cloudStorage.isConnected()) {
        if (!isBackground) {
          _lastError = '인터넷 연결을 확인해주세요.';
          _updateSyncStatus(SyncStatus.error);
        } else {
          _updateSyncStatus(SyncStatus.idle);
        }
        return false;
      }

      print('Starting sync for user $userId (background: $isBackground)');

      // 1. 로컬 데이터 로드
      final localRecords = await _localStorage.loadEmotionRecords(userId);

      // 2. 클라우드 데이터 로드
      final cloudRecords = await _cloudStorage.loadRecords(userId);

      // 3. 데이터 병합
      final mergedRecords = await _localStorage.mergeRecords(localRecords, cloudRecords);

      // 4. 동기화가 필요한 로컬 기록 찾기
      final unsyncedRecords = await _getUnsyncedLocalRecords(mergedRecords);

      // 5. 로컬 기록을 클라우드에 업로드
      if (unsyncedRecords.isNotEmpty) {
        final uploadSuccess = await _cloudStorage.saveRecords(unsyncedRecords, userId);
        if (uploadSuccess) {
          // 업로드된 기록들을 동기화됨으로 마크
          final recordIds = unsyncedRecords.map((r) => r.id).toList();
          await _localStorage.markRecordsAsSynced(recordIds, userId);
          print('Uploaded ${unsyncedRecords.length} records to cloud');
        } else {
          throw Exception('클라우드 업로드 실패');
        }
      }

      // 6. 병합된 데이터를 로컬에 저장
      await _localStorage.saveEmotionRecords(mergedRecords, userId);

      // 7. 마지막 동기화 시간 저장
      _lastSyncTime = DateTime.now();
      await _localStorage.saveLastSyncTime(userId, _lastSyncTime!);

      _updateSyncStatus(SyncStatus.success);
      print('Sync completed successfully for user $userId');
      return true;

    } catch (e) {
      _lastError = e.toString();
      _updateSyncStatus(SyncStatus.error);
      print('Sync failed for user $userId: $e');
      return false;
    }
  }

  // 동기화가 필요한 로컬 기록 찾기
  Future<List<EmotionRecord>> _getUnsyncedLocalRecords(List<EmotionRecord> records) async {
    return records.where((record) => !record.isSynced).toList();
  }

  // 증분 동기화 (마지막 동기화 이후 변경사항만)
  Future<bool> syncIncremental(String userId) async {
    if (_syncStatus == SyncStatus.syncing) return false;

    try {
      _updateSyncStatus(SyncStatus.syncing);

      if (!await _cloudStorage.isConnected()) {
        _lastError = '인터넷 연결을 확인해주세요.';
        _updateSyncStatus(SyncStatus.error);
        return false;
      }

      final lastSyncTime = await _localStorage.getLastSyncTime(userId);
      if (lastSyncTime == null) {
        // 첫 동기화라면 전체 동기화 실행
        return await syncData(userId);
      }

      print('Starting incremental sync for user $userId since $lastSyncTime');

      // 1. 마지막 동기화 이후 수정된 로컬 기록
      final updatedLocalRecords = await _localStorage.getRecordsUpdatedSince(userId, lastSyncTime);

      // 2. 마지막 동기화 이후 수정된 클라우드 기록
      final updatedCloudRecords = await _cloudStorage.loadRecordsSince(userId, lastSyncTime);

      // 3. 업데이트가 없으면 종료
      if (updatedLocalRecords.isEmpty && updatedCloudRecords.isEmpty) {
        _updateSyncStatus(SyncStatus.success);
        print('No updates found, sync completed');
        return true;
      }

      // 4. 로컬 변경사항을 클라우드에 업로드
      if (updatedLocalRecords.isNotEmpty) {
        final unsyncedLocalRecords = updatedLocalRecords.where((r) => !r.isSynced).toList();
        if (unsyncedLocalRecords.isNotEmpty) {
          final uploadSuccess = await _cloudStorage.saveRecords(unsyncedLocalRecords, userId);
          if (uploadSuccess) {
            final recordIds = unsyncedLocalRecords.map((r) => r.id).toList();
            await _localStorage.markRecordsAsSynced(recordIds, userId);
            print('Uploaded ${unsyncedLocalRecords.length} updated records to cloud');
          }
        }
      }

      // 5. 클라우드 변경사항을 로컬에 반영
      if (updatedCloudRecords.isNotEmpty) {
        final allLocalRecords = await _localStorage.loadEmotionRecords(userId);
        final mergedRecords = await _localStorage.mergeRecords(allLocalRecords, updatedCloudRecords);
        await _localStorage.saveEmotionRecords(mergedRecords, userId);
        print('Applied ${updatedCloudRecords.length} cloud updates locally');
      }

      // 6. 동기화 시간 업데이트
      _lastSyncTime = DateTime.now();
      await _localStorage.saveLastSyncTime(userId, _lastSyncTime!);

      _updateSyncStatus(SyncStatus.success);
      print('Incremental sync completed for user $userId');
      return true;

    } catch (e) {
      _lastError = e.toString();
      _updateSyncStatus(SyncStatus.error);
      print('Incremental sync failed for user $userId: $e');
      return false;
    }
  }

  // 특정 기록 즉시 동기화
  Future<bool> syncRecord(EmotionRecord record, String userId) async {
    try {
      if (!await _cloudStorage.isConnected()) {
        return false;
      }

      final success = await _cloudStorage.saveRecord(record, userId);
      if (success) {
        // 로컬에서도 동기화 상태 업데이트
        await _localStorage.markRecordsAsSynced([record.id], userId);
        print('Record ${record.id} synced immediately');
      }
      return success;

    } catch (e) {
      print('Failed to sync record ${record.id}: $e');
      return false;
    }
  }

  // 기록 삭제 동기화
  Future<bool> syncDeleteRecord(String recordId, String userId) async {
    try {
      if (!await _cloudStorage.isConnected()) {
        return false;
      }

      final success = await _cloudStorage.deleteRecord(recordId, userId);
      if (success) {
        print('Record $recordId deletion synced');
      }
      return success;

    } catch (e) {
      print('Failed to sync record deletion $recordId: $e');
      return false;
    }
  }

  // 강제 클라우드에서 복원 (로컬 데이터 덮어쓰기)
  Future<bool> restoreFromCloud(String userId) async {
    if (_syncStatus == SyncStatus.syncing) return false;

    try {
      _updateSyncStatus(SyncStatus.syncing);

      if (!await _cloudStorage.isConnected()) {
        _lastError = '인터넷 연결을 확인해주세요.';
        _updateSyncStatus(SyncStatus.error);
        return false;
      }

      print('Restoring data from cloud for user $userId');

      // 클라우드에서 모든 데이터 다운로드
      final cloudRecords = await _cloudStorage.loadRecords(userId);

      // 모든 기록을 동기화됨으로 마크
      final syncedRecords = cloudRecords.map((r) => r.copyWith(isSynced: true)).toList();

      // 로컬에 저장
      await _localStorage.saveEmotionRecords(syncedRecords, userId);

      // 동기화 시간 업데이트
      _lastSyncTime = DateTime.now();
      await _localStorage.saveLastSyncTime(userId, _lastSyncTime!);

      _updateSyncStatus(SyncStatus.success);
      print('Successfully restored ${cloudRecords.length} records from cloud');
      return true;

    } catch (e) {
      _lastError = e.toString();
      _updateSyncStatus(SyncStatus.error);
      print('Failed to restore from cloud: $e');
      return false;
    }
  }

  // 동기화 상태 업데이트
  void _updateSyncStatus(SyncStatus status) {
    _syncStatus = status;
    if (status != SyncStatus.error) {
      _lastError = null;
    }
    _syncStatusController?.add(status);
  }

  // 동기화 상태 정보
  Future<Map<String, dynamic>> getSyncInfo(String userId) async {
    final localInfo = await _localStorage.getStorageInfo(userId);
    final lastSync = await _localStorage.getLastSyncTime(userId);
    final isConnected = await _cloudStorage.isConnected();

    return {
      'syncStatus': _syncStatus.name,
      'lastSyncTime': lastSync?.toIso8601String(),
      'lastError': _lastError,
      'isConnected': isConnected,
      'localRecords': localInfo['totalRecords'],
      'unsyncedRecords': localInfo['unsyncedRecords'],
      'autoSyncEnabled': _autoSyncTimer?.isActive ?? false,
    };
  }

  // 충돌 해결 전략
  EmotionRecord resolveConflict(EmotionRecord localRecord, EmotionRecord cloudRecord) {
    // 기본 전략: 최신 수정 시간을 기준으로 선택
    if (localRecord.updatedAt.isAfter(cloudRecord.updatedAt)) {
      return localRecord.copyWith(isSynced: false); // 로컬이 최신이므로 재동기화 필요
    } else if (cloudRecord.updatedAt.isAfter(localRecord.updatedAt)) {
      // 클라우드가 최신이지만 이미지는 로컬 것을 유지
      return cloudRecord.copyWith(
        imagePaths: localRecord.imagePaths,
        isSynced: true,
      );
    } else {
      // 동일한 시간이면 로컬 우선
      return localRecord;
    }
  }

  // 리소스 정리
  void dispose() {
    stopAutoSync();
    _syncStatusController?.close();
    _syncStatusController = null;
  }
}
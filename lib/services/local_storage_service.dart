import 'package:shared_preferences/shared_preferences.dart';
import '../models/emotion_record.dart';
import '../models/goal.dart';
import 'dart:convert';

class LocalStorageService {
  // 사용자별 키 생성을 위한 접두사
  static const String _emotionKeyPrefix = 'emotion_records_';
  static const String _lastSyncKey = 'last_sync_';

  // 사용자별 키 생성
  String _getUserEmotionKey(String userId) {
    return '$_emotionKeyPrefix$userId';
  }

  // 마지막 동기화 시간 키 생성
  String _getLastSyncKey(String userId) {
    return '$_lastSyncKey$userId';
  }

  // 사용자별 감정 기록 저장
  Future<void> saveEmotionRecords(List<EmotionRecord> records, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((e) => jsonEncode(e.toJson())).toList();
    final userKey = _getUserEmotionKey(userId);
    await prefs.setStringList(userKey, jsonList);
    print('Saved ${records.length} records locally for user $userId');
  }

  // 사용자별 감정 기록 불러오기
  Future<List<EmotionRecord>> loadEmotionRecords(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserEmotionKey(userId);
    final jsonList = prefs.getStringList(userKey) ?? [];
    final records = jsonList.map((e) => EmotionRecord.fromJson(jsonDecode(e))).toList();
    print('Loaded ${records.length} records locally for user $userId');
    return records;
  }

  // 단일 기록 추가 (효율적인 저장)
  Future<void> addEmotionRecord(EmotionRecord record, String userId) async {
    final existingRecords = await loadEmotionRecords(userId);
    existingRecords.add(record);
    await saveEmotionRecords(existingRecords, userId);
  }

  // 단일 기록 수정
  Future<void> updateEmotionRecord(EmotionRecord oldRecord, EmotionRecord newRecord, String userId) async {
    final existingRecords = await loadEmotionRecords(userId);
    final index = existingRecords.indexWhere((r) => r.id == oldRecord.id);

    if (index != -1) {
      existingRecords[index] = newRecord;
      await saveEmotionRecords(existingRecords, userId);
    }
  }

  // 단일 기록 삭제
  Future<void> removeEmotionRecord(EmotionRecord record, String userId) async {
    final existingRecords = await loadEmotionRecords(userId);
    existingRecords.removeWhere((r) => r.id == record.id);
    await saveEmotionRecords(existingRecords, userId);
  }

  // 동기화 상태 업데이트
  Future<void> markRecordsAsSynced(List<String> recordIds, String userId) async {
    final existingRecords = await loadEmotionRecords(userId);
    final updatedRecords = existingRecords.map((record) {
      if (recordIds.contains(record.id)) {
        return record.copyWith(isSynced: true);
      }
      return record;
    }).toList();

    await saveEmotionRecords(updatedRecords, userId);
  }

  // 동기화되지 않은 기록 조회
  Future<List<EmotionRecord>> getUnsyncedRecords(String userId) async {
    final allRecords = await loadEmotionRecords(userId);
    return allRecords.where((record) => !record.isSynced).toList();
  }

  // 특정 날짜 이후 수정된 기록 조회
  Future<List<EmotionRecord>> getRecordsUpdatedSince(String userId, DateTime since) async {
    final allRecords = await loadEmotionRecords(userId);
    return allRecords.where((record) => record.updatedAt.isAfter(since)).toList();
  }

  // 마지막 동기화 시간 저장
  Future<void> saveLastSyncTime(String userId, DateTime syncTime) async {
    final prefs = await SharedPreferences.getInstance();
    final syncKey = _getLastSyncKey(userId);
    await prefs.setString(syncKey, syncTime.toIso8601String());
    print('Last sync time saved for user $userId: $syncTime');
  }

  // 마지막 동기화 시간 불러오기
  Future<DateTime?> getLastSyncTime(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final syncKey = _getLastSyncKey(userId);
    final syncTimeString = prefs.getString(syncKey);

    if (syncTimeString != null) {
      return DateTime.parse(syncTimeString);
    }
    return null;
  }

  // 로컬 기록과 클라우드 기록 병합
  Future<List<EmotionRecord>> mergeRecords(List<EmotionRecord> localRecords, List<EmotionRecord> cloudRecords) async {
    final Map<String, EmotionRecord> mergedMap = {};

    // 로컬 기록을 먼저 맵에 추가
    for (final record in localRecords) {
      mergedMap[record.id] = record;
    }

    // 클라우드 기록과 비교하여 병합
    for (final cloudRecord in cloudRecords) {
      final localRecord = mergedMap[cloudRecord.id];

      if (localRecord == null) {
        // 로컬에 없는 클라우드 기록 추가
        mergedMap[cloudRecord.id] = cloudRecord;
      } else if (cloudRecord.updatedAt.isAfter(localRecord.updatedAt)) {
        // 클라우드 기록이 더 최신인 경우
        // 이미지 경로는 로컬 기록의 것을 유지
        mergedMap[cloudRecord.id] = cloudRecord.copyWith(
          imagePaths: localRecord.imagePaths,
        );
      }
      // 로컬 기록이 더 최신이거나 같은 경우는 그대로 유지
    }

    return mergedMap.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // 날짜 역순 정렬
  }

  // 특정 사용자의 데이터 삭제 (로그아웃 시 사용 - 선택사항)
  Future<void> clearUserEmotionRecords(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = _getUserEmotionKey(userId);
    final syncKey = _getLastSyncKey(userId);

    await prefs.remove(userKey);
    await prefs.remove(syncKey);
    print('Cleared local data for user $userId');
  }

  // 모든 사용자 데이터 삭제 (앱 재설치나 완전 초기화 시)
  Future<void> clearAllEmotionRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    // emotion_records_ 와 last_sync_ 로 시작하는 모든 키 삭제
    for (String key in allKeys) {
      if (key.startsWith(_emotionKeyPrefix) || key.startsWith(_lastSyncKey)) {
        await prefs.remove(key);
      }
    }
    print('Cleared all local emotion data');
  }

  // 저장된 사용자 목록 확인 (디버깅용)
  Future<List<String>> getSavedUserIds() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    return allKeys
        .where((key) => key.startsWith(_emotionKeyPrefix))
        .map((key) => key.substring(_emotionKeyPrefix.length))
        .toList();
  }

  // 하위 호환성을 위한 기존 데이터 마이그레이션
  Future<void> migrateOldDataToUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    const oldKey = 'emotion_records';

    // 기존 데이터가 있는지 확인
    final oldData = prefs.getStringList(oldKey);
    if (oldData != null && oldData.isNotEmpty) {
      try {
        // 기존 데이터를 새 형식으로 변환
        final migratedRecords = oldData.map((jsonString) {
          final json = jsonDecode(jsonString);
          final oldRecord = EmotionRecord.fromJson(json);

          // 새 형식으로 변환 (ID와 타임스탬프 추가)
          return oldRecord.copyWith(
            id: oldRecord.id, // 기존에 ID가 없었다면 새로 생성됨
            createdAt: oldRecord.date, // 생성일을 날짜로 설정
            updatedAt: oldRecord.date,
            isSynced: false, // 마이그레이션된 데이터는 동기화되지 않음
          );
        }).toList();

        // 새 형식으로 저장
        await saveEmotionRecords(migratedRecords, userId);

        // 기존 데이터 삭제
        await prefs.remove(oldKey);

        print('Migrated ${migratedRecords.length} records from old format to user $userId');
      } catch (e) {
        print('Error migrating old data: $e');
      }
    }
  }

  // 로컬 스토리지 상태 정보
  Future<Map<String, dynamic>> getStorageInfo(String userId) async {
    final records = await loadEmotionRecords(userId);
    final unsyncedCount = records.where((r) => !r.isSynced).length;
    final lastSync = await getLastSyncTime(userId);

    return {
      'totalRecords': records.length,
      'unsyncedRecords': unsyncedCount,
      'syncedRecords': records.length - unsyncedCount,
      'lastSyncTime': lastSync?.toIso8601String(),
    };
  }
}

extension GoalStorage on LocalStorageService {
  // 사용자별 일반 데이터 저장 (목표, 설정 등)
  Future<void> saveUserData(String userId, String dataType, String data) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${dataType}_$userId';
    await prefs.setString(key, data);
    print('Saved $dataType data for user $userId');
  }

  // 사용자별 일반 데이터 불러오기
  Future<String?> getUserData(String userId, String dataType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${dataType}_$userId';
    return prefs.getString(key);
  }

  // 사용자별 목표 저장
  Future<void> saveGoals(List<Goal> goals, String userId) async {
    final jsonList = goals.map((g) => jsonEncode(g.toJson())).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('goals_$userId', jsonList);
    print('Saved ${goals.length} goals locally for user $userId');
  }

  // 사용자별 목표 불러오기
  Future<List<Goal>> loadGoals(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('goals_$userId') ?? [];
    final goals = jsonList.map((e) => Goal.fromJson(jsonDecode(e))).toList();
    print('Loaded ${goals.length} goals locally for user $userId');
    return goals;
  }

  // 특정 사용자의 모든 데이터 삭제
  Future<void> clearAllUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    
    // 해당 사용자 ID가 포함된 모든 키 삭제
    for (String key in allKeys) {
      if (key.endsWith('_$userId')) {
        await prefs.remove(key);
      }
    }
    print('Cleared all local data for user $userId');
  }

  // 동기화되지 않은 목표 조회
  Future<List<Goal>> getUnsyncedGoals(String userId) async {
    final allGoals = await loadGoals(userId);
    return allGoals.where((goal) => !goal.isSynced).toList();
  }

  // 목표 동기화 상태 업데이트
  Future<void> markGoalsAsSynced(List<String> goalIds, String userId) async {
    final existingGoals = await loadGoals(userId);
    final updatedGoals = existingGoals.map((goal) {
      if (goalIds.contains(goal.id)) {
        return goal.copyWith(isSynced: true);
      }
      return goal;
    }).toList();

    await saveGoals(updatedGoals, userId);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emotion_record.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/goal.dart';

class CloudStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  // 사용자별 컬렉션 경로 생성
  String _getUserCollectionPath(String userId) {
    return 'users/$userId/emotion_records';
  }

  // 인터넷 연결 상태 확인
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  // 단일 기록 클라우드에 저장
  Future<bool> saveRecord(EmotionRecord record, String userId) async {
    if (!await isConnected()) return false;

    try {
      final docRef = _firestore
          .collection(_getUserCollectionPath(userId))
          .doc(record.id);

      await docRef.set(record.toFirestoreJson());
      print('Record ${record.id} saved to cloud for user $userId');
      return true;
    } catch (e) {
      print('Error saving record to cloud: $e');
      return false;
    }
  }

  // 여러 기록 일괄 저장
  Future<bool> saveRecords(List<EmotionRecord> records, String userId) async {
    if (!await isConnected() || records.isEmpty) return false;

    try {
      final batch = _firestore.batch();
      final collectionRef = _firestore.collection(_getUserCollectionPath(userId));

      for (final record in records) {
        final docRef = collectionRef.doc(record.id);
        batch.set(docRef, record.toFirestoreJson());
      }

      await batch.commit();
      print('${records.length} records saved to cloud for user $userId');
      return true;
    } catch (e) {
      print('Error saving records to cloud: $e');
      return false;
    }
  }

  // 클라우드에서 모든 기록 불러오기
  Future<List<EmotionRecord>> loadRecords(String userId) async {
    if (!await isConnected()) return [];

    try {
      final querySnapshot = await _firestore
          .collection(_getUserCollectionPath(userId))
          .orderBy('date', descending: true)
          .get();

      final records = querySnapshot.docs
          .map((doc) => EmotionRecord.fromFirestore(doc.data()))
          .toList();

      print('Loaded ${records.length} records from cloud for user $userId');
      return records;
    } catch (e) {
      print('Error loading records from cloud: $e');
      return [];
    }
  }

  // 특정 날짜 이후 기록 불러오기 (증분 동기화용)
  Future<List<EmotionRecord>> loadRecordsSince(String userId, DateTime since) async {
    if (!await isConnected()) return [];

    try {
      final querySnapshot = await _firestore
          .collection(_getUserCollectionPath(userId))
          .where('updatedAt', isGreaterThan: since.toIso8601String())
          .orderBy('updatedAt', descending: false)
          .get();

      final records = querySnapshot.docs
          .map((doc) => EmotionRecord.fromFirestore(doc.data()))
          .toList();

      print('Loaded ${records.length} updated records from cloud for user $userId since $since');
      return records;
    } catch (e) {
      print('Error loading updated records from cloud: $e');
      return [];
    }
  }

  // 단일 기록 삭제
  Future<bool> deleteRecord(String recordId, String userId) async {
    if (!await isConnected()) return false;

    try {
      await _firestore
          .collection(_getUserCollectionPath(userId))
          .doc(recordId)
          .delete();

      print('Record $recordId deleted from cloud for user $userId');
      return true;
    } catch (e) {
      print('Error deleting record from cloud: $e');
      return false;
    }
  }

  // 사용자의 모든 기록 삭제
  Future<bool> deleteAllRecords(String userId) async {
    if (!await isConnected()) return false;

    try {
      final querySnapshot = await _firestore
          .collection(_getUserCollectionPath(userId))
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('All records deleted from cloud for user $userId');
      return true;
    } catch (e) {
      print('Error deleting all records from cloud: $e');
      return false;
    }
  }

  // 동기화가 필요한 기록 확인 (로컬에만 있거나 수정된 기록)
  Future<List<EmotionRecord>> getUnsyncedRecords(
      List<EmotionRecord> localRecords, String userId) async {
    if (!await isConnected()) return localRecords.where((r) => !r.isSynced).toList();

    try {
      final cloudRecords = await loadRecords(userId);
      final cloudRecordMap = {for (var r in cloudRecords) r.id: r};

      final unsyncedRecords = <EmotionRecord>[];

      for (final localRecord in localRecords) {
        final cloudRecord = cloudRecordMap[localRecord.id];

        if (cloudRecord == null) {
          // 클라우드에 없는 새 기록
          unsyncedRecords.add(localRecord);
        } else if (localRecord.updatedAt.isAfter(cloudRecord.updatedAt)) {
          // 로컬이 더 최신인 기록
          unsyncedRecords.add(localRecord);
        }
      }

      return unsyncedRecords;
    } catch (e) {
      print('Error getting unsynced records: $e');
      return localRecords.where((r) => !r.isSynced).toList();
    }
  }

  // 클라우드 스토리지 사용량 체크 (선택사항)
  Future<int> getRecordCount(String userId) async {
    if (!await isConnected()) return 0;

    try {
      final querySnapshot = await _firestore
          .collection(_getUserCollectionPath(userId))
          .count()
          .get();

      return querySnapshot.count ?? 0; // null인 경우 0을 반환
    } catch (e) {
      print('Error getting record count: $e');
      return 0;
    }
  }

  // 연결 상태 스트림 (실시간 연결 상태 모니터링)
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }
}

extension GoalCloudStorage on CloudStorageService {
  // 사용자별 목표 컬렉션 경로 생성
  String _getUserGoalsCollectionPath(String userId) {
    return 'users/$userId/goals';
  }

  // 단일 목표 클라우드에 저장
  Future<bool> saveGoal(Goal goal, String userId) async {
    if (!await isConnected()) return false;

    try {
      final docRef = _firestore
          .collection(_getUserGoalsCollectionPath(userId))
          .doc(goal.id);

      await docRef.set(goal.toFirestoreJson());
      print('Goal ${goal.id} saved to cloud for user $userId');
      return true;
    } catch (e) {
      print('Error saving goal to cloud: $e');
      return false;
    }
  }

  // 여러 목표 일괄 저장
  Future<bool> saveGoals(List<Goal> goals, String userId) async {
    if (!await isConnected() || goals.isEmpty) return false;

    try {
      final batch = _firestore.batch();
      final collectionRef = _firestore.collection(_getUserGoalsCollectionPath(userId));

      for (final goal in goals) {
        final docRef = collectionRef.doc(goal.id);
        batch.set(docRef, goal.toFirestoreJson());
      }

      await batch.commit();
      print('${goals.length} goals saved to cloud for user $userId');
      return true;
    } catch (e) {
      print('Error saving goals to cloud: $e');
      return false;
    }
  }

  // 클라우드에서 모든 목표 불러오기
  Future<List<Goal>> loadGoals(String userId) async {
    if (!await isConnected()) return [];

    try {
      final querySnapshot = await _firestore
          .collection(_getUserGoalsCollectionPath(userId))
          .orderBy('createdAt', descending: true)
          .get();

      final goals = querySnapshot.docs
          .map((doc) => Goal.fromFirestore(doc.data()))
          .toList();

      print('Loaded ${goals.length} goals from cloud for user $userId');
      return goals;
    } catch (e) {
      print('Error loading goals from cloud: $e');
      return [];
    }
  }

  // 특정 날짜 이후 수정된 목표 불러오기 (증분 동기화용)
  Future<List<Goal>> loadGoalsSince(String userId, DateTime since) async {
    if (!await isConnected()) return [];

    try {
      final querySnapshot = await _firestore
          .collection(_getUserGoalsCollectionPath(userId))
          .where('updatedAt', isGreaterThan: since.toIso8601String())
          .orderBy('updatedAt', descending: false)
          .get();

      final goals = querySnapshot.docs
          .map((doc) => Goal.fromFirestore(doc.data()))
          .toList();

      print('Loaded ${goals.length} updated goals from cloud for user $userId since $since');
      return goals;
    } catch (e) {
      print('Error loading updated goals from cloud: $e');
      return [];
    }
  }

  // 단일 목표 삭제
  Future<bool> deleteGoal(String goalId, String userId) async {
    if (!await isConnected()) return false;

    try {
      await _firestore
          .collection(_getUserGoalsCollectionPath(userId))
          .doc(goalId)
          .delete();

      print('Goal $goalId deleted from cloud for user $userId');
      return true;
    } catch (e) {
      print('Error deleting goal from cloud: $e');
      return false;
    }
  }

  // 사용자의 모든 목표 삭제
  Future<bool> deleteAllGoals(String userId) async {
    if (!await isConnected()) return false;

    try {
      final querySnapshot = await _firestore
          .collection(_getUserGoalsCollectionPath(userId))
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('All goals deleted from cloud for user $userId');
      return true;
    } catch (e) {
      print('Error deleting all goals from cloud: $e');
      return false;
    }
  }

  // 동기화가 필요한 목표 확인
  Future<List<Goal>> getUnsyncedGoals(List<Goal> localGoals, String userId) async {
    if (!await isConnected()) return localGoals.where((g) => !g.isSynced).toList();

    try {
      final cloudGoals = await loadGoals(userId);
      final cloudGoalMap = {for (var g in cloudGoals) g.id: g};

      final unsyncedGoals = <Goal>[];

      for (final localGoal in localGoals) {
        final cloudGoal = cloudGoalMap[localGoal.id];

        if (cloudGoal == null) {
          // 클라우드에 없는 새 목표
          unsyncedGoals.add(localGoal);
        } else if (localGoal.updatedAt.isAfter(cloudGoal.updatedAt)) {
          // 로컬이 더 최신인 목표
          unsyncedGoals.add(localGoal);
        }
      }

      return unsyncedGoals;
    } catch (e) {
      print('Error getting unsynced goals: $e');
      return localGoals.where((g) => !g.isSynced).toList();
    }
  }

  // 목표 개수 조회
  Future<int> getGoalCount(String userId) async {
    if (!await isConnected()) return 0;

    try {
      final querySnapshot = await _firestore
          .collection(_getUserGoalsCollectionPath(userId))
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting goal count: $e');
      return 0;
    }
  }
}
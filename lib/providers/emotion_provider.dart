import 'package:flutter/material.dart';
import '../models/emotion_record.dart';
import '../services/local_storage_service.dart';

class EmotionProvider with ChangeNotifier {
  final List<EmotionRecord> _records = [];
  final LocalStorageService _storage = LocalStorageService();
  bool _initialized = false;

  List<EmotionRecord> get records => _records;
  bool get initialized => _initialized;

  // 앱 시작 시 호출: LocalStorage에서 데이터 불러오기
  Future<void> loadRecords() async {
    final loaded = await _storage.loadEmotionRecords();
    _records.clear();
    _records.addAll(loaded);
    _initialized = true;
    notifyListeners();
  }

  Future<void> addRecord(EmotionRecord record) async {
    _records.add(record);
    await _storage.saveEmotionRecords(_records);
    notifyListeners();
  }

  Future<void> deleteRecord(EmotionRecord record) async {
    _records.remove(record);
    await _storage.saveEmotionRecords(_records);
    notifyListeners();
  }

  Future<void> editRecord(EmotionRecord oldRecord, EmotionRecord newRecord) async {
    final idx = _records.indexOf(oldRecord);
    if (idx != -1) {
      _records[idx] = newRecord;
      await _storage.saveEmotionRecords(_records);
      notifyListeners();
    }
  }
} 
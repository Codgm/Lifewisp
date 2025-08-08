import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/emotion_record.dart';
import '../services/local_storage_service.dart';

class EmotionProvider with ChangeNotifier {
  final List<EmotionRecord> _records = [];
  final LocalStorageService _storage = LocalStorageService();
  static final Map<String, Uint8List> _webImageCache = {};
  bool _initialized = false;

  List<EmotionRecord> get records => List.from(_records);
  bool get initialized => _initialized;

  // 앱 시작 시 호출: LocalStorage에서 데이터 불러오기
  Future<void> loadRecords() async {
    final loaded = await _storage.loadEmotionRecords();
    _records.clear();
    _records.addAll(loaded);
    _initialized = true;
    notifyListeners();
  }

  // 웹 이미지 저장 (정적 메서드)
  static String saveWebImage(Uint8List imageBytes) {
    final imageKey = 'web_image_${DateTime.now().millisecondsSinceEpoch}_${imageBytes.hashCode}';
    _webImageCache[imageKey] = imageBytes;
    return imageKey;
  }

  // 웹 이미지 가져오기 (정적 메서드)
  static Uint8List? getWebImage(String imageKey) {
    return _webImageCache[imageKey];
  }

  // 웹 이미지 삭제 (정적 메서드)
  static void removeWebImage(String imageKey) {
    _webImageCache.remove(imageKey);
  }

  // 여러 웹 이미지를 한 번에 저장하고 키 목록 반환
  static List<String> saveWebImages(List<Uint8List> imageBytesList) {
    List<String> imageKeys = [];
    for (Uint8List imageBytes in imageBytesList) {
      imageKeys.add(saveWebImage(imageBytes));
    }
    return imageKeys;
  }

  // 사용하지 않는 웹 이미지 정리
  static void clearUnusedWebImages(List<EmotionRecord> records) {
    if (!kIsWeb) return;

    Set<String> usedKeys = {};
    for (EmotionRecord record in records) {
      if (record.imagePaths != null) {
        for (String imagePath in record.imagePaths!) {
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

  Future<void> addRecord(EmotionRecord record) async {
    _records.add(record);
    await _storage.saveEmotionRecords(_records);
    notifyListeners();
  }

  Future<void> deleteRecord(EmotionRecord record) async {
    // 웹 이미지 삭제
    if (kIsWeb && record.imagePaths != null) {
      for (String imagePath in record.imagePaths!) {
        if (imagePath.startsWith('web_image_')) {
          removeWebImage(imagePath);
        }
      }
    }

    _records.remove(record);
    await _storage.saveEmotionRecords(_records);
    notifyListeners();
  }

  Future<void> editRecord(EmotionRecord oldRecord, EmotionRecord newRecord) async {
    final idx = _records.indexOf(oldRecord);
    if (idx != -1) {
      // 기존 웹 이미지 삭제 (편집 시)
      if (kIsWeb && oldRecord.imagePaths != null) {
        for (String imagePath in oldRecord.imagePaths!) {
          if (imagePath.startsWith('web_image_')) {
            removeWebImage(imagePath);
          }
        }
      }

      _records[idx] = newRecord;
      await _storage.saveEmotionRecords(_records);
      notifyListeners();
    }
  }

  // 웹 이미지 캐시 상태 확인 (디버깅용)
  static int getWebImageCacheSize() {
    return _webImageCache.length;
  }

  // 전체 웹 이미지 캐시 정리 (필요시)
  static void clearAllWebImages() {
    _webImageCache.clear();
  }
}

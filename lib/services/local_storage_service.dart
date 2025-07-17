import 'package:shared_preferences/shared_preferences.dart';
import '../models/emotion_record.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _emotionKey = 'emotion_records';

  Future<void> saveEmotionRecords(List<EmotionRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((e) => _toJson(e)).toList();
    await prefs.setStringList(_emotionKey, jsonList);
  }

  Future<List<EmotionRecord>> loadEmotionRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_emotionKey) ?? [];
    return jsonList.map((e) => _fromJson(e)).toList();
  }

  String _toJson(EmotionRecord record) {
    return jsonEncode({
      'date': record.date.toIso8601String(),
      'emotion': record.emotion,
      'diary': record.diary,
    });
  }

  EmotionRecord _fromJson(String jsonStr) {
    final map = jsonDecode(jsonStr);
    return EmotionRecord(
      date: DateTime.parse(map['date']),
      emotion: map['emotion'],
      diary: map['diary'],
    );
  }
} 
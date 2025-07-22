import 'package:shared_preferences/shared_preferences.dart';
import '../models/emotion_record.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _emotionKey = 'emotion_records';

  Future<void> saveEmotionRecords(List<EmotionRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_emotionKey, jsonList);
  }

  Future<List<EmotionRecord>> loadEmotionRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_emotionKey) ?? [];
    return jsonList.map((e) => EmotionRecord.fromJson(jsonDecode(e))).toList();
  }
} 
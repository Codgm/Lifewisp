import 'package:flutter/material.dart';
import '../models/emotion_record.dart';

class EmotionProvider with ChangeNotifier {
  final List<EmotionRecord> _records = [
    EmotionRecord(date: DateTime.now(), emotion: 'happy', diary: '오늘은 정말 행복했어!'),
    EmotionRecord(date: DateTime.now().subtract(Duration(days: 1)), emotion: 'sad', diary: '어제는 조금 우울했어.'),
    EmotionRecord(date: DateTime.now().subtract(Duration(days: 2)), emotion: 'angry', diary: '그저께는 화가 났어.'),
    EmotionRecord(date: DateTime.now().subtract(Duration(days: 3)), emotion: 'love', diary: '사랑이 넘치는 하루!'),
    EmotionRecord(date: DateTime.now().subtract(Duration(days: 4)), emotion: 'fear', diary: '조금 불안했던 하루.'),
  ];

  List<EmotionRecord> get records => _records;

  void addRecord(EmotionRecord record) {
    _records.add(record);
    notifyListeners();
  }

  void deleteRecord(EmotionRecord record) {
    _records.remove(record);
    notifyListeners();
  }

  void editRecord(EmotionRecord oldRecord, EmotionRecord newRecord) {
    final idx = _records.indexOf(oldRecord);
    if (idx != -1) {
      _records[idx] = newRecord;
      notifyListeners();
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emotion_record.dart';
import '../providers/emotion_provider.dart';

class EmotionDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EmotionRecord record = ModalRoute.of(context)?.settings.arguments as EmotionRecord;

    return Scaffold(
      backgroundColor: Color(0xFFFAF3E0),
      appBar: AppBar(
        title: Text('감정 기록 상세', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${record.date.year}-${record.date.month}-${record.date.day}', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 12),
            Text('주요 감정: ${record.emotion}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('입력 내용:', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 4),
            Text(record.diary, style: TextStyle(fontSize: 18)),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<EmotionProvider>(context, listen: false).deleteRecord(record);
                  Navigator.pop(context);
                },
                child: Text('삭제하기', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
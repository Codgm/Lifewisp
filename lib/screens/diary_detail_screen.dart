import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emotion_record.dart';
import '../utils/emotion_utils.dart';
import '../providers/emotion_provider.dart';
import 'emotion_record_screen.dart';

class DiaryDetailScreen extends StatelessWidget {
  final EmotionRecord record;
  const DiaryDetailScreen({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('감정 일기 상세'),
        backgroundColor: emotionColor[record.emotion] ?? Colors.grey,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EmotionRecordScreen(
                    initialDate: record.date,
                    initialEmotion: record.emotion,
                    initialDiary: record.diary,
                    isEdit: true,
                  ),
                ),
              );
              if (updated != null && updated is EmotionRecord) {
                context.read<EmotionProvider>().editRecord(record, updated);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('삭제 확인'),
                  content: const Text('이 감정 기록을 삭제할까요?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<EmotionProvider>().deleteRecord(record);
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F4FD),
                  Color(0xFFF0F8FF),
                  Color(0xFFFFF0F5),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isWide ? 80 : 12,
                    right: isWide ? 80 : 12,
                    top: 8,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        emotionEmoji[record.emotion] ?? '',
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${record.date.year}년 ${record.date.month}월 ${record.date.day}일',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        record.diary,
                        style: const TextStyle(fontSize: 20, fontFamily: 'NanumPenScript'),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 
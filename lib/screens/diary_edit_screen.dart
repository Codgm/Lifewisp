import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emotion_record.dart';
import '../providers/emotion_provider.dart';

class DiaryEditScreen extends StatefulWidget {
  final DateTime? date;
  const DiaryEditScreen({Key? key, this.date}) : super(key: key);

  @override
  State<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends State<DiaryEditScreen> {
  late TextEditingController _controller;
  String? selectedEmotion;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<EmotionProvider>(context, listen: false);
    EmotionRecord? record;
    if (widget.date != null) {
      try {
        record = provider.records.firstWhere((r) => r.date.year == widget.date!.year && r.date.month == widget.date!.month && r.date.day == widget.date!.day);
      } catch (_) {}
    }
    _controller = TextEditingController(text: record?.diary ?? '');
    selectedEmotion = record?.emotion;
    selectedDate = widget.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('감정 일기 수정')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: '일기 내용을 입력하세요'),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedEmotion,
              hint: const Text('감정 선택'),
              items: ['happy', 'sad', 'angry', 'love', 'fear']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedEmotion = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (selectedEmotion != null && _controller.text.trim().isNotEmpty) {
                  final provider = Provider.of<EmotionProvider>(context, listen: false);
                  final newRecord = EmotionRecord(
                    date: selectedDate,
                    emotion: selectedEmotion!,
                    diary: _controller.text.trim(),
                  );
                  provider.editRecord(
                    provider.records.firstWhere((r) => r.date.year == selectedDate.year && r.date.month == selectedDate.month && r.date.day == selectedDate.day),
                    newRecord,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('수정하기'),
            ),
          ],
        ),
      ),
    );
  }
} 
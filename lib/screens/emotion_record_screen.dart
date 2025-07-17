import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/emotion_utils.dart';
import '../models/emotion_record.dart';
import '../providers/emotion_provider.dart';
import '../widgets/rabbit_emoticon.dart';

class EmotionRecordScreen extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialEmotion;
  final String? initialDiary;
  final bool isEdit;
  const EmotionRecordScreen({Key? key, this.initialDate, this.initialEmotion, this.initialDiary, this.isEdit = false}) : super(key: key);

  @override
  State<EmotionRecordScreen> createState() => _EmotionRecordScreenState();
}

class _EmotionRecordScreenState extends State<EmotionRecordScreen> {
  late DateTime selectedDate;
  String? selectedEmotion;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    selectedEmotion = widget.initialEmotion;
    _controller = TextEditingController(text: widget.initialDiary ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? '감정 기록 수정' : '감정 기록'),
        backgroundColor: Colors.pink[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 날짜 선택
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, color: Colors.pink),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 감정 선택
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: emotionEmoji.entries.map((e) {
                  final isSelected = selectedEmotion == e.key;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedEmotion = e.key;
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: RabbitEmoticon(
                          emotion: _mapStringToRabbitEmotion(e.key),
                          size: 28,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            // 일기 입력
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '오늘의 감정과 하루를 기록해보세요',
                filled: true,
                fillColor: Colors.pink[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 18, fontFamily: 'NanumPenScript'),
            ),
            const SizedBox(height: 32),
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedEmotion != null && _controller.text.trim().isNotEmpty) {
                    final record = EmotionRecord(
                      date: selectedDate,
                      emotion: selectedEmotion!,
                      diary: _controller.text.trim(),
                    );
                    if (widget.isEdit) {
                      Navigator.pop(context, record);
                    } else {
                      context.read<EmotionProvider>().addRecord(record);
                      Navigator.pop(context);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('감정과 일기를 모두 입력해 주세요.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(widget.isEdit ? '수정하기' : '저장하기', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

RabbitEmotion _mapStringToRabbitEmotion(String key) {
  switch (key) {
    case 'happy':
    case '행복':
    case '😊':
      return RabbitEmotion.happy;
    case 'sad':
    case '슬픔':
    case '😢':
      return RabbitEmotion.sad;
    case 'angry':
    case '분노':
    case '😤':
      return RabbitEmotion.angry;
    case 'excited':
    case '흥분':
    case '🤩':
      return RabbitEmotion.excited;
    case 'calm':
    case '평온':
    case '😌':
      return RabbitEmotion.calm;
    case 'anxious':
    case '불안':
    case '😰':
      return RabbitEmotion.anxious;
    case 'love':
    case '사랑':
    case '🥰':
      return RabbitEmotion.love;
    case 'tired':
    case '피곤':
    case '😴':
      return RabbitEmotion.tired;
    case 'despair':
    case '절망':
    case '😭':
      return RabbitEmotion.despair;
    default:
      return RabbitEmotion.happy;
  }
} 
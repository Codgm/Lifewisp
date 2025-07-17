import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../utils/emotion_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/rabbit_emoticon.dart';

import 'diary_detail_screen.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({Key? key}) : super(key: key);

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  String? filterEmotion;
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final records = context.watch<EmotionProvider>().records;
    // 감정별 필터 적용
    final filtered = records.where((r) {
      final matchEmotion = filterEmotion == null || r.emotion == filterEmotion;
      final matchText = searchText.isEmpty || r.diary.contains(searchText);
      return matchEmotion && matchText;
    }).toList();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('일기 리스트', style: GoogleFonts.jua()),
        centerTitle: true,
        backgroundColor: Colors.amber[100],
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      // 감정별 필터 Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('전체'),
                              selected: filterEmotion == null,
                              onSelected: (_) => setState(() => filterEmotion = null),
                            ),
                            ...emotionEmoji.entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(e.value, style: const TextStyle(fontSize: 20)),
                                selected: filterEmotion == e.key,
                                selectedColor: emotionColor[e.key]?.withOpacity(0.5),
                                onSelected: (_) => setState(() => filterEmotion = e.key),
                              ),
                            )),
                          ],
                        ),
                      ),
                      // 검색창
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '일기 내용 검색',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.amber[50],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          onChanged: (v) => setState(() => searchText = v),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 리스트
                      SizedBox(
                        height: 320,
                        child: filtered.isEmpty
                            ? const Center(child: Text('일기 기록이 없습니다.', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final diary = filtered[index];
                                  final color = emotionColor[diary.emotion] ?? Colors.amber[100]!;
                                  final emoji = emotionEmoji[diary.emotion] ?? '';
                                  return Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    color: color.withOpacity(0.18),
                                    elevation: 3,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: color,
                                        radius: 22,
                                        child: RabbitEmoticon(
                                          emotion: _mapStringToRabbitEmotion(diary.emotion),
                                          size: 18,
                                        ),
                                      ),
                                      title: Text(diary.diary, style: GoogleFonts.jua(fontSize: 18)),
                                      subtitle: Text(
                                        '${diary.date.year}-${diary.date.month.toString().padLeft(2, '0')}-${diary.date.day.toString().padLeft(2, '0')}',
                                        style: GoogleFonts.jua(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal[300]),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DiaryDetailScreen(record: diary),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 감정 기록 추가 화면 이동(더미)
        },
        icon: const Icon(Icons.add),
        label: const Text('감정 기록'),
        backgroundColor: Colors.amber[200],
        foregroundColor: Colors.teal[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
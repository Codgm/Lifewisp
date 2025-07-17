import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({Key? key}) : super(key: key);

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  int selectedTheme = 0;

  final List<Map<String, dynamic>> themes = [
    {
      'name': '모던 퍼플',
      'gradient': [Color(0xFFE6E6FA), Color(0xFFDDA0DD)],
      'accent': Color(0xFF8A2BE2),
    },
    {
      'name': '소프트 핑크',
      'gradient': [Color(0xFFFFC0CB), Color(0xFFFFB6C1)],
      'accent': Color(0xFFFF69B4),
    },
    {
      'name': '민트 그린',
      'gradient': [Color(0xFFE0FFE0), Color(0xFF98FB98)],
      'accent': Color(0xFF20B2AA),
    },
    {
      'name': '선셋 오렌지',
      'gradient': [Color(0xFFFFE4B5), Color(0xFFFFDAB9)],
      'accent': Color(0xFFFF6347),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final mainEmotion = '😊';
    final summary = '내 감정을 인정하는 건 나를 존중하는 일이다.';
    final keywords = ['#자존감', '#성장', '#감정일기'];
    final selectedThemeData = themes[selectedTheme];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        title: Text('나만의 감정 카드 ✨',
            style: GoogleFonts.jua(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748)
            )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF2D3748)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 미리보기 카드
              Center(
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: selectedThemeData['gradient'],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: selectedThemeData['accent'].withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 이모지 컨테이너
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(mainEmotion, style: const TextStyle(fontSize: 40)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 감정 요약
                        Text(
                          summary,
                          style: GoogleFonts.jua(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3748),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),

                        // 키워드 태그
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: keywords.map((keyword) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selectedThemeData['accent'].withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              keyword,
                              style: GoogleFonts.jua(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: selectedThemeData['accent'],
                              ),
                            ),
                          )).toList(),
                        ),

                        const SizedBox(height: 16),

                        // 앱 로고/이름
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: selectedThemeData['accent'],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'LifeWisp',
                              style: GoogleFonts.jua(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selectedThemeData['accent'],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 테마 선택 섹션
              Text(
                '테마 선택',
                style: GoogleFonts.jua(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),

              // 테마 선택 그리드
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final isSelected = selectedTheme == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTheme = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: theme['gradient'],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme['accent']
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme['accent'].withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          theme['name'],
                          style: GoogleFonts.jua(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // 액션 버튼들
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [selectedThemeData['accent'], selectedThemeData['accent'].withOpacity(0.8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: selectedThemeData['accent'].withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.download_done, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text('갤러리에 저장됐어요! 📸',
                                      style: GoogleFonts.jua(
                                        fontWeight: FontWeight.w500,
                                      )
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF38B2AC),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_alt, color: Colors.white),
                        label: Text(
                          '저장',
                          style: GoogleFonts.jua(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: selectedThemeData['accent'].withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // 공유 기능
                          _showShareOptions(context);
                        },
                        icon: Icon(Icons.share, color: selectedThemeData['accent']),
                        label: Text(
                          '공유',
                          style: GoogleFonts.jua(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedThemeData['accent'],
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '공유하기',
              style: GoogleFonts.jua(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.message,
                  label: '카카오톡',
                  color: const Color(0xFFFFE812),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('카카오톡으로 공유했어요! 💛',
                            style: GoogleFonts.jua(fontWeight: FontWeight.w500)
                        ),
                        backgroundColor: const Color(0xFFFFE812),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.camera_alt,
                  label: '인스타그램',
                  color: const Color(0xFFE4405F),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('인스타그램으로 공유했어요! 💜',
                            style: GoogleFonts.jua(fontWeight: FontWeight.w500)
                        ),
                        backgroundColor: const Color(0xFFE4405F),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.copy,
                  label: '링크 복사',
                  color: const Color(0xFF667EEA),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('링크가 복사되었어요! 🔗',
                            style: GoogleFonts.jua(fontWeight: FontWeight.w500)
                        ),
                        backgroundColor: const Color(0xFF667EEA),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.jua(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}
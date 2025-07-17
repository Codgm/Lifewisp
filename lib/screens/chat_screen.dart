import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Map<String, String>> messages = [
    {'role': 'ai', 'text': '안녕! 오늘 하루는 어땠어? 😊\n솔직한 마음을 들려줘! 나는 네 감정을 이해하는 친구야 💕'},
  ];
  final controller = TextEditingController();
  bool isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    String dateStr = '${today.year}년 ${today.month}월 ${today.day}일';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isWide = screenWidth > 600;
          final isTablet = screenWidth > 768;
          final isDesktop = screenWidth > 1024;

          // 반응형 패딩 계산
          double horizontalPadding = 12;
          if (isWide) horizontalPadding = 24;
          if (isTablet) horizontalPadding = 60;
          if (isDesktop) horizontalPadding = 120;

          // 반응형 폰트 크기 계산
          double titleFontSize = 16;
          double bodyFontSize = 15;
          double dateFontSize = 14;
          double hintFontSize = 14;

          if (isTablet) {
            titleFontSize = 18;
            bodyFontSize = 16;
            dateFontSize = 15;
            hintFontSize = 15;
          }
          if (isDesktop) {
            titleFontSize = 20;
            bodyFontSize = 17;
            dateFontSize = 16;
            hintFontSize = 16;
          }

          // 메시지 리스트 높이 계산
          double messageListHeight = screenHeight * 0.45;
          if (messageListHeight < 300) messageListHeight = 300;
          if (messageListHeight > 500) messageListHeight = 500;

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
              child: Column(
                children: [
                  // 커스텀 앱바
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        // 뒤로가기 버튼
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                            onPressed: () => Navigator.pop(context),
                            color: const Color(0xFF6B73FF),
                          ),
                        ),
                        const Spacer(),
                        // 제목
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '🌸',
                                style: TextStyle(fontSize: titleFontSize),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '감정 대화',
                                style: GoogleFonts.notoSans(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // 설정 버튼
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.more_horiz_rounded, size: 18),
                            onPressed: () {},
                            color: const Color(0xFF6B73FF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 날짜 표시
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B73FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF6B73FF).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '📅',
                                style: TextStyle(fontSize: dateFontSize),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dateStr,
                                style: GoogleFonts.notoSans(
                                  fontSize: dateFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B73FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // 메시지 리스트
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              itemCount: messages.length,
                              itemBuilder: (context, idx) {
                                final msg = messages[idx];
                                final isAI = msg['role'] == 'ai';

                                // 반응형 아바타 및 메시지 크기
                                double avatarSize = 40;
                                double messagePadding = 16;
                                if (isTablet) {
                                  avatarSize = 45;
                                  messagePadding = 18;
                                }
                                if (isDesktop) {
                                  avatarSize = 50;
                                  messagePadding = 20;
                                }

                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 300 + (idx * 100)),
                                  curve: Curves.easeOutBack,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isAI) ...[
                                        // AI 아바타
                                        Container(
                                          width: avatarSize,
                                          height: avatarSize,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF6B73FF), Color(0xFF9333EA)],
                                            ),
                                            borderRadius: BorderRadius.circular(avatarSize / 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF6B73FF).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '🤖',
                                              style: TextStyle(fontSize: avatarSize * 0.45),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // AI 메시지
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(messagePadding),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.9),
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(4),
                                                topRight: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight: Radius.circular(20),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              msg['text']!,
                                              style: GoogleFonts.notoSans(
                                                fontSize: bodyFontSize,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF2D3748),
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        // 사용자 메시지
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(messagePadding),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF6B73FF), Color(0xFF9333EA)],
                                              ),
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(4),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight: Radius.circular(20),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF6B73FF).withOpacity(0.3),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              msg['text']!,
                                              style: GoogleFonts.notoSans(
                                                fontSize: bodyFontSize,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // 사용자 아바타
                                        Container(
                                          width: avatarSize,
                                          height: avatarSize,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B).withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(avatarSize / 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFF59E0B).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '😊',
                                              style: TextStyle(fontSize: avatarSize * 0.45),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 로딩 인디케이터
                  if (isLoading)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF6B73FF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '🤖 AI가 분석하고 있어요...',
                            style: GoogleFonts.notoSans(
                              fontSize: dateFontSize,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B73FF),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 입력 영역
                  Container(
                    margin: EdgeInsets.all(horizontalPadding),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isDesktop ? 600 : double.infinity,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            child: TextField(
                              controller: controller,
                              onChanged: (_) => setState(() {}),
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: '오늘의 감정을 자유롭게 표현해보세요... 💭',
                                hintStyle: GoogleFonts.notoSans(
                                  fontSize: hintFontSize,
                                  color: Colors.grey[500],
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              style: GoogleFonts.notoSans(
                                fontSize: bodyFontSize,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                        ),
                        // 전송 버튼
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: Opacity(
                            opacity: controller.text.trim().isEmpty || isLoading ? 0.5 : 1.0,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6B73FF), Color(0xFF9333EA)],
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.send_rounded, color: Colors.white),
                                iconSize: 28,
                                onPressed: controller.text.trim().isEmpty || isLoading
                                    ? null
                                    : () async {
                                  final text = controller.text.trim();
                                  if (text.isEmpty) return;
                                  setState(() {
                                    messages.add({'role': 'user', 'text': text});
                                    controller.clear();
                                    isLoading = true;
                                  });
                                  await Future.delayed(const Duration(seconds: 2));
                                  setState(() {
                                    isLoading = false;
                                  });
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      contentPadding: const EdgeInsets.all(24),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF6B73FF), Color(0xFF9333EA)],
                                              ),
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            child: const Center(
                                              child: Text('✨', style: TextStyle(fontSize: 24)),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '감정 분석 완료!',
                                            style: GoogleFonts.notoSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2D3748),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'AI가 당신의 감정을 깊이 분석했어요!\n결과를 확인해보세요 💕',
                                            style: GoogleFonts.notoSans(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              height: 1.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context, '/result');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF6B73FF),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                '결과 보러가기 🚀',
                                                style: GoogleFonts.notoSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                splashRadius: 24,
                                padding: const EdgeInsets.all(0),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
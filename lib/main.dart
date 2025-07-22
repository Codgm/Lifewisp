import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/emotion_record.dart';
import 'providers/emotion_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/result_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/character_screen.dart';
import 'screens/reflection_screen.dart';
import 'screens/share_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/diary_list_screen.dart';
import 'screens/diary_detail_screen.dart';
import 'screens/analysis_screen.dart';
import 'utils/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmotionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Lifewisp',
        theme: appTheme, // utils/theme.dart의 테마를 전체에 적용
        debugShowCheckedModeBanner: false,
        home: const AppInitializer(),
        routes: {
          '/splash': (_) => SplashScreen(),
          '/onboarding': (_) => OnboardingScreen(),
          '/chat': (_) => const ChatScreen(),
          '/result': (_) => const ResultScreen(),
          '/calendar': (_) => const CalendarScreen(),
          '/character': (_) => const CharacterScreen(),
          '/reflection': (_) => const ReflectionScreen(),
          '/analysis': (_) => const AnalysisScreen(),
          '/share': (_) => const ShareScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignUpScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final emotionProvider = Provider.of<EmotionProvider>(context, listen: false);
    await emotionProvider.loadRecords();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SplashScreen();
    }
    return MainNavigation();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    DashboardScreen(),
    CalendarScreen(),
    CharacterScreen(),
    ReflectionScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '대시보드'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_emotions), label: '캐릭터'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: '회고'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('대시보드')),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/chat'),
            child: Text('채팅 화면'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/calendar'),
            child: Text('캘린더 화면'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/character'),
            child: Text('캐릭터 화면'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/reflection'),
            child: Text('회고 화면'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/share'),
            child: Text('공유 화면'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            child: Text('프로필 화면'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/result'),
            child: Text('결과 화면'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text('로그인 화면'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            child: Text('회원가입 화면'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/splash'),
            child: Text('스플래시 화면'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DiaryListScreen()),
            ),
            child: Text('일기 리스트'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DiaryDetailScreen(
                  record: EmotionRecord(
                    date: DateTime.now(),
                    emotion: 'happy',
                    diary: '더미 일기입니다.',
                  ),
                ),
              ),
            ),
            child: Text('일기 상세'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AnalysisScreen()),
            ),
            child: Text('분석 화면'),
          ),
          ElevatedButton(
            onPressed: () {
              // 감정 상세 테스트 버튼 제거
            },
            child: Text('감정 상세'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OnboardingScreen()),
            ),
            child: Text('온보딩 화면'),
          ),
        ],
      ),
    );
  }
}

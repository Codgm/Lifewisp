import 'package:flutter/material.dart';
import 'package:lifewisp/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'providers/emotion_provider.dart';
import 'providers/user_provider.dart';
import 'providers/subscription_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/result_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/share_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/advanced_analysis_screen.dart'; // 새로 추가
import 'utils/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'widgets/common_app_bar.dart';
import 'screens/emotion_record_screen.dart';
import 'screens/subscription_screen.dart';

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
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            title: 'Lifewisp',
            theme: appTheme,
            darkTheme: lifewispDarkTheme,
            themeMode: userProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AppInitializer(),
            routes: {
              '/splash': (_) => SplashScreen(),
              '/onboarding': (_) => OnboardingScreen(),
              '/chat': (_) => const ChatScreen(),
              '/ai_chat': (_) => const ChatScreen(), // AI 채팅용 (추후 분리 가능)
              '/result': (context) {
                final args = ModalRoute.of(context)!.settings.arguments;
                if (args == null || args is! Map<String, dynamic>) {
                  return Scaffold(
                    appBar: CommonAppBar(title: '감정 기록 결과'),
                    body: Center(child: Text('잘못된 접근입니다.')),
                  );
                }
                return ResultScreen(
                  emotion: args['emotion'] as String,
                  diary: args['diary'] as String,
                  date: args['date'] as DateTime,
                );
              },
              '/calendar': (_) => const CalendarScreen(),
              '/profile': (_) => ProfileScreen(),
              '/settings': (_) => SettingsScreen(),
              '/reflection': (_) => const AdvancedAnalysisScreen(),
              '/analysis': (_) => const AnalysisScreen(), // 기본 분석
              '/advanced_analysis': (_) => const AdvancedAnalysisScreen(), // AI 고급 분석
              '/share': (_) => const ShareScreen(),
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignUpScreen(),
              '/dashboard': (_) => DashboardScreen(),
              '/emotion_record': (_) => EmotionRecordScreen(), // 감정 기록
              '/subscription': (_) => SubscriptionScreen(), // 구독 화면 (구현 필요)
            },
          );
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
  AppInitState _currentState = AppInitState.splash;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final emotionProvider = Provider.of<EmotionProvider>(context, listen: false);
    await emotionProvider.loadRecords();

    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    await subscriptionProvider.initialize();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initialize();
    
    // 스플래시 화면 표시
    setState(() {
      _currentState = AppInitState.splash;
    });

    _showOnboarding = true;

    if (userProvider.isLoggedIn) {
      setState(() {
        _currentState = AppInitState.main;
      });
    } else {
      setState(() {
        _currentState = AppInitState.onboarding;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case AppInitState.splash:
        return SplashScreen();

      case AppInitState.onboarding:
        return OnboardingScreen();

      case AppInitState.main:
        final isLoggedIn = Provider.of<UserProvider>(context).isLoggedIn;
        if (!isLoggedIn) {
          return LoginScreen();
        }
        return MainNavigation();
    }
  }
}

enum AppInitState {
  splash,
  onboarding,
  main,
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
    AnalysisScreen(), // 기본 분석 화면
    ProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddPressed() {
    // 이제 스마트 FAB가 처리함
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        onAddPressed: _onAddPressed, // 사용되지 않지만 호환성을 위해 유지
      ),
    );
  }
}

// 구독 화면 (임시 구현)
class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: '프리미엄 구독', emoji: '✨'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎯', style: TextStyle(fontSize: 64)),
            SizedBox(height: 24),
            Text(
              'Lifewisp Premium',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'AI 기능으로 더 깊은 감정 분석을 경험해보세요',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _buildFeatureItem('🤖 AI 감정 분석 채팅'),
                  _buildFeatureItem('📊 고급 패턴 분석'),
                  _buildFeatureItem('💡 개인화된 AI 회고'),
                  _buildFeatureItem('🎯 맞춤형 성장 목표'),
                  _buildFeatureItem('📈 무제한 감정 기록'),
                ],
              ),
            ),
            SizedBox(height: 40),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 구독 로직 구현
                  final subscription = Provider.of<SubscriptionProvider>(context, listen: false);
                  subscription.upgradeToPremium();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('프리미엄으로 업그레이드되었습니다! 🎉')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '프리미엄 시작하기',
                  style: TextStyle(
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
  }
  Widget _buildFeatureItem(String feature) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Text(feature, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}


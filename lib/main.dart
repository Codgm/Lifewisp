import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lifewisp/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:lifewisp/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/emotion_provider.dart';
import 'providers/user_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/goal_provider.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  await NotificationService().initialize();
  
  // .env 파일 로드 시도
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('.env 파일 로드 중 오류 발생: $e');
    if (kIsWeb) {
      print('웹 환경에서는 .env 파일 로드에 제한이 있을 수 있습니다.');
      // 웹 환경에서 기본값 설정 또는 대체 로직 구현
    }
  }
  
  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    print('Firebase 초기화 오류: $error');
    // 웹 플랫폼에서 발생할 수 있는 오류를 더 자세히 처리
    if (kIsWeb) {
      print('웹 플랫폼에서 Firebase 초기화 중 오류가 발생했습니다. Firebase 설정을 확인하세요.');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmotionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(),
          update: (context, authProvider, userProvider) {
            // AuthProvider가 변경될 때마다 UserProvider 초기화
            if (userProvider != null) {
              userProvider.initialize(authProvider: authProvider);
            }
            return userProvider ?? UserProvider();
          },
        ),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            title: 'Lifewisp',
            navigatorKey: NavigationService.navigatorKey,
            theme: getAppTheme(context, isDark: false),
            darkTheme: getAppTheme(context, isDark: true),
            themeMode: userProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AppInitializer(),
            routes: {
              '/splash': (_) => SplashScreen(),
              '/onboarding': (_) => OnboardingScreen(),
              '/chat': (_) => const ChatScreen(),
              '/ai_chat': (_) => const ChatScreen(),
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initialize(authProvider: authProvider);
    
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

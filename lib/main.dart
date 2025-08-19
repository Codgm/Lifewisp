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
import 'screens/advanced_analysis_screen.dart';
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
    }
  }
  
  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    print('Firebase 초기화 오류: $error');
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
        // AuthProvider를 최상위에 배치
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // UserProvider는 AuthProvider에 의존
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(),
          update: (context, authProvider, userProvider) {
            userProvider ??= UserProvider();
            userProvider.initialize(authProvider: authProvider);
            return userProvider;
          },
        ),
        
        // SubscriptionProvider는 AuthProvider에 의존
        ChangeNotifierProxyProvider<AuthProvider, SubscriptionProvider>(
          create: (context) => SubscriptionProvider(),
          update: (context, authProvider, subscriptionProvider) {
            subscriptionProvider ??= SubscriptionProvider();
            // 사용자가 로그인되어 있고 사용자 ID가 있으면 초기화
            if (authProvider.isAuthenticated && authProvider.currentUser?.userId != null) {
              subscriptionProvider.initializeUser(authProvider.currentUser!.userId);
            } else {
              subscriptionProvider.clearForUserChange();
            }
            return subscriptionProvider;
          },
        ),
        
        // EmotionProvider는 AuthProvider에 의존
        ChangeNotifierProxyProvider<AuthProvider, EmotionProvider>(
          create: (context) => EmotionProvider(),
          update: (context, authProvider, emotionProvider) {
            emotionProvider ??= EmotionProvider();
            emotionProvider.initialize(authProvider);
            return emotionProvider;
          },
        ),
        
        // GoalProvider는 AuthProvider에 의존
        ChangeNotifierProxyProvider<AuthProvider, GoalProvider>(
          create: (context) => GoalProvider(),
          update: (context, authProvider, goalProvider) {
            goalProvider ??= GoalProvider();
            // 사용자가 로그인되어 있고 사용자 ID가 있으면 초기화
            if (authProvider.isAuthenticated && authProvider.currentUser?.userId != null) {
              goalProvider.initializeUser(authProvider.currentUser!.userId);
            } else {
              goalProvider.clearGoalsForUserChange();
            }
            return goalProvider;
          },
        ),
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
              '/analysis': (_) => const AnalysisScreen(),
              '/advanced_analysis': (_) => const AdvancedAnalysisScreen(),
              '/share': (_) => const ShareScreen(),
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignUpScreen(),
              '/dashboard': (_) => DashboardScreen(),
              '/emotion_record': (_) => EmotionRecordScreen(),
              '/subscription': (_) => SubscriptionScreen(),
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
    try {
      // 1. AuthProvider 초기화 (가장 먼저)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();
      
      // 2. UserProvider 초기화
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.initialize(authProvider: authProvider);
      
      // 3. 사용자가 로그인되어 있으면 다른 Provider들도 초기화
      if (authProvider.isAuthenticated && authProvider.currentUser?.userId != null) {
        final userId = authProvider.currentUser!.userId;
        
        // SubscriptionProvider 초기화
        final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
        await subscriptionProvider.initializeUser(userId);
        
        // EmotionProvider 초기화
        final emotionProvider = Provider.of<EmotionProvider>(context, listen: false);
        await emotionProvider.initialize(authProvider);
        
        // GoalProvider 초기화
        final goalProvider = Provider.of<GoalProvider>(context, listen: false);
        await goalProvider.initializeUser(userId);
      }

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
    } catch (e) {
      print('앱 초기화 오류: $e');
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
    AnalysisScreen(),
    ProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddPressed() {
    // 스마트 FAB에서 처리
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        onAddPressed: _onAddPressed,
      ),
    );
  }
}
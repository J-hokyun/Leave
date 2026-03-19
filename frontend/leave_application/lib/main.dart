import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:leave_application/presentation/calender_page.dart';
import 'package:leave_application/presentation/home_page.dart';
import 'package:leave_application/presentation/password_confirm_page.dart';
import 'package:leave_application/presentation/profile_page.dart';
import 'package:leave_application/presentation/login_page.dart';
import 'package:leave_application/presentation/join_page.dart';
import 'package:leave_application/ad/ad_manager.dart';
import 'package:leave_application/ad/att_service.dart';

import 'package:leave_application/presentation/password_change_page.dart';
import 'package:leave_application/presentation/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 전역에서 접근 가능한 키
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: rootNavigatorKey,

  initialLocation: '/splash',

  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/join', builder: (context, state) => const JoinPage()),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalenderPage(),
    ),
    GoRoute(
      path: '/valid',
      builder: (context, state) => const PasswordConfirmPage(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/profile/password',
      builder: (context, state) => const PasswordChangePage(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ko_KR', null);

  AdManager().loadInterstitialAd();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 렌더링이 완료된 후 ATT 팝업을 띄웁니다.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ATTService.requestATT();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Leave',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
      locale: const Locale('ko', 'KR'),
    );
  }
}

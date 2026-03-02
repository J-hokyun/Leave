import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:leave_application/presentation/calender_page.dart';
import 'package:leave_application/presentation/home_page.dart';
import 'package:leave_application/presentation/password_confirm_page.dart';
import 'package:leave_application/presentation/profile_page.dart';
import 'package:leave_application/presentation/login_page.dart';
import 'package:leave_application/presentation/join_page.dart';
import 'package:leave_application/presentation/password_change_page.dart';
import 'package:leave_application/presentation/splash_page.dart';

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
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  // 한국어 로컬 데이터 초기화 (ko_KR)
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Leave Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

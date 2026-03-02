import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final storage = const FlutterSecureStorage();
  bool _isVisible = false; // 애니메이션 상태 변수

  @override
  void initState() {
    super.initState();
    _startAnimation(); // 애니메이션 시작
    _checkAuth(); // 인증 체크
  }

  // 로고를 부드럽게 나타나게 하는 함수
  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  void _checkAuth() async {
    // 애니메이션을 감상할 수 있도록 최소 2초 대기
    await Future.delayed(const Duration(seconds: 2));
    final token = await storage.read(key: 'ACCESS_TOKEN');

    if (!mounted) return;

    if (token != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0, // 0에서 1로 변화
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeIn, // 부드러운 가속도 효과
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/leave_logo.png',
                width: 300,
                height: 300,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.beach_access,
                    size: 80,
                    color: Colors.blue, // 흰 배경이니 파란색 아이콘으로 변경
                  );
                },
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                color: Color(0x00007aff),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

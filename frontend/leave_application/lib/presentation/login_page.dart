import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:leave_application/data/api/auth_api.dart';
import 'package:dio/dio.dart';
import 'package:leave_application/presentation/common/alert_utils.dart';

var logger = Logger(
  printer: PrettyPrinter(), // 로그를 보기 좋게 박스 형태로 출력해줌
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthApi _authApi = AuthApi();
  final storage = const FlutterSecureStorage();
  final Color primaryColor = const Color(0xFF007AFF);
  final Color inputFillColor = const Color(0xFFEDF2FF);
  final Color errorColor = Colors.red;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordObscure = true;
  @override
  void dispose() {
    // 2. 컨트롤러 해제 (메모리 누수 방지)
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final response = await _authApi.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (response.statusCode == 200) {
        final String token = response.data['accessToken'];
        await storage.write(key: 'ACCESS_TOKEN', value: token);
        logger.d("로그인 성공");

        if (!mounted) return;
        context.go("/home");
      }
    } catch (e) {
      String errorMessage = "오류가 발생했습니다. 다시 시도하여 주세요.";

      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }

      logger.d("로그인 실패 : $errorMessage");
      if (!mounted) return;
      AlertUtils.showError(context, errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar에 타이틀 배치
      appBar: AppBar(
        title: const Text(
          '로그인',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007AFF),
          ),
        ),
        centerTitle: true, // 중앙 정렬
        // backgroundColor: Colors.white,
        elevation: 0,
      ),
      // 2. 스크롤 없이 화면에 고정하기 위해 Padding 사용
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              '휴가를 기록하세요',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007AFF),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '당신의 휴가를 기록하고, 남은 휴가를 파악해보세요',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 50),

            // 이메일 영역
            _buildInputLabel('이메일'),
            _buildTextField(
              controller: _emailController,
              hintText: 'example@example.com',
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 25),

            _buildInputLabel('비밀번호'),
            _buildTextField(
              controller: _passwordController,
              isObscure: _isPasswordObscure,
              onChanged: (_) => setState(() {}),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _isPasswordObscure = !_isPasswordObscure),
                color: Colors.black45,
              ),
            ),

            // Align(
            //   alignment: Alignment.centerRight,
            //   child: TextButton(
            //     onPressed: () {},
            //     child: const Text(
            //       '비밀번호 찾기',
            //       style: TextStyle(
            //         color: Color(0xFF007AFF),
            //         fontSize: 13,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 30),

            // 로그인 버튼
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  // const Text(
                  //   '소셜 로그인',
                  //   style: TextStyle(
                  //     color: Colors.black45,
                  //     fontSize: 13,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 15),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     _socialIcon('G'),
                  //     const SizedBox(width: 20),
                  //     _socialIcon('F'),
                  //   ],
                  // ),
                  // const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      context.push('/join');
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.w600,
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
  }

  Widget _socialIcon(String label) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4851FF),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    String? hintText,
    bool isObscure = false,
    Widget? suffixIcon,
    TextEditingController? controller,
    Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: isObscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.3)),
        filled: true,
        fillColor: inputFillColor,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

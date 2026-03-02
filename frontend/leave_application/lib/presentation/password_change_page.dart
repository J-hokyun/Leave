import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leave_application/data/api/user_api.dart';
import 'package:dio/dio.dart';
import 'package:leave_application/presentation/common/alert_utils.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(), // 로그를 보기 좋게 박스 형태로 출력해줌
);

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final UserApi _userApi = UserApi();

  // 디자인 상수 (통일성 유지)
  final Color primaryColor = const Color(0xFF007AFF);
  final Color inputFillColor = const Color(0xFFEDF2FF);
  final Color errorColor = Colors.red;

  bool _isPasswordObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // [로직] 비밀번호 8자 이상 체크
  Map<String, dynamic> _getPasswordStatus() {
    String p = _passwordController.text;
    if (p.isEmpty) {
      return {"text": "", "color": Colors.transparent, "isValid": false};
    }
    // 1. 길이 체크 (8자 이상)
    if (p.length < 8) {
      return {"text": "8자리 이상이어야 합니다.", "color": errorColor, "isValid": false};
    }

    // 영문, 숫자, 특수문자 포함 여부 체크
    bool hasLetters = p.contains(RegExp(r'[a-zA-Z]'));
    bool hasNumbers = p.contains(RegExp(r'[0-9]'));
    bool hasSpecial = p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasLetters || !hasNumbers || !hasSpecial) {
      return {
        "text": "영문, 숫자, 특수문자를 모두 포함해야 합니다.",
        "color": errorColor,
        "isValid": false,
      };
    }

    // 모든 조건 통과
    return {"text": "", "color": primaryColor, "isValid": true};
  }

  // [로직] 비밀번호 일치 체크
  Map<String, dynamic> _getConfirmStatus() {
    String p1 = _passwordController.text;
    String p2 = _confirmController.text;
    if (p2.isEmpty) {
      return {"text": "", "color": Colors.transparent, "isValid": false};
    }
    if (p1 != p2) {
      return {
        "text": "비밀번호가 일치하지 않습니다.",
        "color": errorColor,
        "isValid": false,
      };
    }
    return {"text": "비밀번호가 일치합니다.", "color": primaryColor, "isValid": true};
  }

  Future<void> _changePassword() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final response = await _userApi.changePassword(
        password: _passwordController.text,
        passwordConfirm: _confirmController.text,
      );
      if (response.statusCode == 200) {
        logger.d("비밀번호 변경 완료");

        if (!mounted) return;

        await AlertUtils.showAlert(context, "비밀번호 변경에 성공하였습니다.");
        if (mounted) {
          context.go("/profile");
        }
      }
    } catch (e) {
      String errorMessage = "오류가 발생했습니다. 다시 시도하여 주세요.";
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }

      logger.d("회원가입 실패 : $errorMessage");
      if (!mounted) return;
      AlertUtils.showError(context, errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordStatus = _getPasswordStatus();
    final confirmStatus = _getConfirmStatus();

    bool isFormValid =
        passwordStatus['isValid'] == true && confirmStatus['isValid'] == true;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007AFF),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // 새 비밀번호 입력
            _buildInputLabel('새 비밀번호'),
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
              ),
            ),
            _buildStatusText(passwordStatus),

            const SizedBox(height: 25),

            // 비밀번호 확인 입력
            _buildInputLabel('비밀번호 확인'),
            _buildTextField(
              controller: _confirmController,
              isObscure: _isConfirmObscure,
              onChanged: (_) => setState(() {}),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _isConfirmObscure = !_isConfirmObscure),
              ),
            ),
            _buildStatusText(confirmStatus),

            const SizedBox(height: 50),

            // 변경 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isFormValid ? _changePassword : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '변경완료',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
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

  Widget _buildStatusText(Map<String, dynamic> status) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          status['text'],
          style: TextStyle(
            color: status['color'],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    bool isObscure = false,
    Widget? suffixIcon,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: isObscure,
      decoration: InputDecoration(
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

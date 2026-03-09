import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leave_application/data/api/user_api.dart';
import 'package:leave_application/data/api/auth_api.dart';
import 'package:leave_application/presentation/common/footer.dart';
import 'package:dio/dio.dart';
import 'package:leave_application/presentation/common/alert_utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserApi _userApi = UserApi();
  final AuthApi _authApi = AuthApi();

  // 가이드라인 상수
  final Color primaryColor = const Color(0xFF007AFF);
  final Color inputFillColor = const Color(0xFFE8EFFF); // 서브컬러와 통일

  // 텍스트 스타일 가이드
  final TextStyle titleStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF007AFF),
  );
  final TextStyle contentStyle = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // 데이터 상태
  String _email = "";
  int _leaveCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // 1. 유저 정보 호출
  Future<void> _fetchUserProfile() async {
    try {
      final response = await _userApi.getUserProfile();
      if (response.statusCode == 200) {
        setState(() {
          _email = response.data['email'];
          _leaveCount = response.data['count'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("프로필 로딩 에러: $e");
      setState(() => _isLoading = false);
    }
  }

  // 로그아웃
  Future<void> _fetchLogout() async {
    try {
      final response = await _authApi.logout();
      if (response.statusCode == 200) {
        await AlertUtils.showAlert(context, "로그아웃 되었습니다.");
        context.go("/login");
      }
    } catch (e) {
      debugPrint("프로필 로딩 에러: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('나의 정보', style: titleStyle),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // 이메일 정보 (수정 불가)
                  _buildLabel('이메일'),
                  _buildInfoBox(text: _email),
                  const SizedBox(height: 25),

                  // 비밀번호 변경
                  _buildLabel('비밀번호 변경'),
                  _buildInfoBox(
                    text: '********',
                    actionIcon: _buildActionIcon(
                      Icons.edit_outlined,
                      onTap: () => context.push('/profile/password'),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 연차 갯수
                  _buildLabel('연차 갯수'),
                  _buildInfoBox(
                    text: '$_leaveCount 개',
                    actionIcon: _buildActionIcon(
                      Icons.edit_outlined,
                      onTap: _showCountEditDialog, // 위에서 만든 함수 호출
                    ),
                  ),

                  const SizedBox(height: 40),
                  _buildLogoutButton(),
                ],
              ),
            ),
      bottomNavigationBar: const CustomFooter(currentIndex: '/profile'),
    );
  }

  // 라벨 스타일 (제목 2 가이드 적용 가능)
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 로그아웃버튼
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _fetchLogout,
      child: Container(
        width: double.infinity,
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "로그아웃",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.red, // 텍스트 빨간색
              ),
            ),
            // 기존 _buildActionIcon 스타일을 유지하되 색상만 변경
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 20,
                color: Colors.red, // 아이콘 빨간색
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 텍스트 필드와 통일감을 주는 정보 표시 박스
  Widget _buildInfoBox({required String text, Widget? actionIcon}) {
    return Container(
      width: double.infinity,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: contentStyle),
          if (actionIcon != null) actionIcon,
        ],
      ),
    );
  }

  // 보내주신 아이콘 버튼 스타일 적용
  Widget _buildActionIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white, // 배경 박스가 서브컬러이므로 아이콘 배경은 흰색으로 대비
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF4357FF)),
      ),
    );
  }

  void _showCountEditDialog() {
    final TextEditingController countController = TextEditingController(
      text: _leaveCount.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('연차 갯수 수정', style: titleStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '12 ~ 99 사이의 숫자를 입력해주세요.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final int? enteredCount = int.tryParse(countController.text);

                if (enteredCount == null ||
                    enteredCount < 12 ||
                    enteredCount > 99) {
                  AlertUtils.showError(context, '12에서 99 사이의 숫자만 가능합니다.');
                  return;
                }

                try {
                  final response = await _userApi.changeCount(
                    count: enteredCount,
                  );

                  if (!mounted) return;

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    if (Navigator.canPop(dialogContext)) {
                      Navigator.pop(dialogContext);
                    }

                    setState(() {
                      _leaveCount = enteredCount;
                    });

                    if (!mounted) return;
                    AlertUtils.showAlert(context, '연차 갯수가 성공적으로 수정되었습니다.');
                  }
                } catch (e) {
                  if (!mounted) return;

                  String errorMsg = "수정에 실패했습니다.";
                  if (e is DioException && e.response?.data is Map) {
                    errorMsg = (e.response?.data as Map)['message'] ?? errorMsg;
                  }

                  AlertUtils.showError(context, errorMsg);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('저장', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

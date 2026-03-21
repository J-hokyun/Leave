import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomFooter extends StatelessWidget {
  final String currentIndex; // 현재 활성화된 페이지 구분용

  const CustomFooter({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 30, 20, 30), // 좌우 하단 여백으로 떠 있는 효과
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF), // 배경 진한 파랑
        borderRadius: BorderRadius.circular(35), // 완전 둥근 형태
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 홈 버튼
          _buildIconButton(
            context,
            icon: Icons.home_outlined,
            isActive: currentIndex == '/home',
            onTap: () => context.go('/home'),
          ),
          // 달력 버튼
          _buildIconButton(
            context,
            icon: Icons.calendar_month_outlined,
            isActive: currentIndex == '/calendar',
            onTap: () => context.go('/calendar'),
          ),
          // 마이페이지 버튼 (예시)
          _buildIconButton(
            context,
            icon: Icons.person_outline,
            isActive:
                currentIndex == '/valid' || currentIndex.startsWith('/profile'),
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 32,
        // 현재 페이지인 경우 검정색(이미지 기준), 아니면 흰색
        color: isActive ? Colors.black : Colors.white,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class CustomFooter extends StatelessWidget {
//   final String currentIndex; // 현재 활성화된 페이지 구분용

//   const CustomFooter({super.key, required this.currentIndex});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 30, 20, 30), // 좌우 하단 여백으로 떠 있는 효과
//       height: 50,
//       decoration: BoxDecoration(
//         color: const Color(0xFF007AFF), // 배경 진한 파랑
//         borderRadius: BorderRadius.circular(35), // 완전 둥근 형태
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           // 홈 버튼
//           _buildIconButton(
//             context,
//             icon: Icons.home_outlined,
//             isActive: currentIndex == '/home',
//             onTap: () => context.go('/home'),
//           ),
//           // 달력 버튼
//           _buildIconButton(
//             context,
//             icon: Icons.calendar_month_outlined,
//             isActive: currentIndex == '/calendar',
//             onTap: () => context.go('/calendar'),
//           ),
//           // 마이페이지 버튼 (예시)
//           _buildIconButton(
//             context,
//             icon: Icons.person_outline,
//             isActive:
//                 currentIndex == '/valid' || currentIndex.startsWith('/profile'),
//             onTap: () => context.go('/profile'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIconButton(
//     BuildContext context, {
//     required IconData icon,
//     required bool isActive,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Icon(
//         icon,
//         size: 32,
//         // 현재 페이지인 경우 검정색(이미지 기준), 아니면 흰색
//         color: isActive ? Colors.black : Colors.white,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomFooter extends StatelessWidget {
  final String currentIndex;

  const CustomFooter({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30), // 하단 여백 최적화
      height: 65, // 아이콘 크기에 맞춰 높이 소폭 조정
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF), // 메인 프라이머리 블루
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 홈: 구글 스타일 집 모양
          _buildIconButton(
            context,
            icon: Icons.home_rounded, // 구글 대시보드/홈 스타일
            isActive: currentIndex == '/home',
            onTap: () => context.go('/home'),
          ),
          _buildIconButton(
            context,
            icon: Icons.view_list_rounded,
            isActive: currentIndex == '/yearly' || currentIndex == '/yearly',
            onTap: () => context.go('/yearly'),
          ),
          _buildIconButton(
            context,
            icon: Icons.calendar_today_rounded,
            isActive:
                currentIndex == '/calendar' || currentIndex == '/calendar',
            onTap: () => context.go('/calendar'),
          ),
          _buildIconButton(
            context,
            icon: Icons.account_circle_rounded,
            isActive:
                currentIndex.startsWith('/profile') || currentIndex == '/valid',
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
      behavior: HitTestBehavior.opaque, // 터치 영역 확장
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            // 활성화 시 부드러운 하늘색(E8EFFF 계열) 혹은 흰색 강조
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

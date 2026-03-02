import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================================
  // PRIMARY COLORS (주요 색상)
  // ============================================================================

  /// 브랜드 액센트 컬러 - 좋아요, 활성 탭 등에 사용
  static const Color primary = Color(0xFFD72600);

  /// 주요 텍스트 색상 - 제목, 사용자명 등
  static const Color primaryText = Color(0xFF281D1B);

  // ============================================================================
  // BACKGROUND COLORS (배경 색상)
  // ============================================================================

  /// 라이트 테마 메인 배경색
  static const Color backgroundLight = Color(0xFFFFFBFA);

  /// 다크 테마 메인 배경색
  static const Color backgroundDark = Color(0xFFF7F5F4);

  /// 카드, 입력 필드 등의 배경색
  static const Color surfaceBackground = Color(0x0A000000);

  // ============================================================================
  // TEXT COLORS (텍스트 색상)
  // ============================================================================

  /// 보조 텍스트 색상 - 시간, 부가 정보 등
  static const Color secondaryText = Color(0x9E2E1814);

  /// 다크 테마용 주요 텍스트
  /// Figma: #494949
  static const Color darkPrimaryText = Color(0xFF494949);

  /// 희미한 텍스트 - 플레이스홀더, 비활성 상태
  static const Color mutedText = Color(0x80494949);

  // ============================================================================
  // NEUTRAL COLORS (중성 색상)
  // ============================================================================

  /// 비활성 상태 색상
  static const Color neutral = Color(0xFF6B6B6A);

  /// 스트로크, 구분선 색상
  static const Color stroke = Color(0x336E5049);

  // ============================================================================
  // FUNCTIONAL COLORS (기능적 색상)
  // ============================================================================

  /// 검색 필드, 카드 배경 등에 사용되는 서피스 색상
  static const Color surfaceTint = Color(0x177E3425);

  // ============================================================================
  // DARK THEME SPECIFIC (다크 테마 전용)
  // ============================================================================

  /// 다크 테마용 희미한 배경
  static const Color darkSurface = Color(0x4D494949);
}

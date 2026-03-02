import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // ============================================================================
  // 폰트 패밀리 정의
  // ============================================================================

  /// 메인 브랜드 폰트 - Outfit
  /// 모든 UI 텍스트에 사용하여 일관성 확보
  static const String fontFamily = 'Outfit';

  // ============================================================================
  // HEADINGS (제목)
  // ============================================================================

  /// 대형 제목 (28px) - 로그인, 주요 페이지 제목
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.21,
    letterSpacing: -0.56, // -2% of 28px
  );

  /// 중형 제목 (22px) - 프로필 이름, 서브 헤딩
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.30,
    letterSpacing: -0.22, // -1% of 22px
  );

  /// 소형 제목 (17px) - 네비게이션 제목
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.26,
  );

  // ============================================================================
  // BODY TEXT (본문 텍스트)
  // ============================================================================

  /// 메인 바디 텍스트 (17px) - 일반적인 읽기 텍스트
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// 중간 바디 텍스트 (15px) - 포스트 내용, 사용자명
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// 작은 바디 텍스트 (13px) - 설명, 부가 정보
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.21,
  );

  // ============================================================================
  // LABELS (라벨)
  // ============================================================================

  /// 대형 라벨 (17px) - 버튼 텍스트, 입력 필드
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// 중간 라벨 (15px) - 사용자명, 중요한 정보
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// 작은 라벨 (11px) - 탭 라벨, 작은 버튼
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  // ============================================================================
  // CAPTIONS (캡션)
  // ============================================================================

  /// 일반 캡션 (12px) - 시간 정보, 메타데이터
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.26,
  );

  /// 상태바 텍스트 (17px) - 시스템 UI
  static const TextStyle statusBar = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.21,
  );

  // ============================================================================
  // SPECIAL USE CASES (특수 용도)
  // ============================================================================

  /// 검색 플레이스홀더 텍스트
  static const TextStyle searchPlaceholder = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// 입력 필드 텍스트
  static const TextStyle inputField = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );
}

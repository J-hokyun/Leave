import 'package:flutter/material.dart';
import 'package:leave_application/core/colors/app_colors_extension.dart';
import '../typography/app_text_theme_extension.dart';

/// Mini SNS 앱의 통합 테마 시스템
class AppTheme {
  AppTheme._();

  /// 라이트 테마 설정
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // 기본 컬러 스킴
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColorsExtension.light.primary,
      brightness: Brightness.light,
    ),

    // 앱 바 테마
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsExtension.light.background,
      elevation: 0,
      titleTextStyle: AppTextThemeExtension.light.heading3,
      iconTheme: IconThemeData(color: AppColorsExtension.light.primaryText),
    ),

    // 입력 필드 테마
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsExtension.light.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorsExtension.light.stroke),
      ),
      hintStyle: AppTextThemeExtension.light.searchPlaceholder,
    ),

    // 카드 테마
    cardTheme: CardThemeData(
      color: AppColorsExtension.light.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // 확장 테마 등록
    extensions: [AppColorsExtension.light, AppTextThemeExtension.light],
  );

  /// 다크 테마 설정
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // 기본 컬러 스킴
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColorsExtension.dark.primary,
      brightness: Brightness.dark,
    ),

    // 앱 바 테마
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsExtension.dark.background,
      elevation: 0,
      titleTextStyle: AppTextThemeExtension.dark.heading3,
      iconTheme: IconThemeData(color: AppColorsExtension.dark.primaryText),
    ),

    // 입력 필드 테마
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsExtension.dark.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorsExtension.dark.stroke),
      ),
      hintStyle: AppTextThemeExtension.dark.searchPlaceholder,
    ),

    // 카드 테마
    cardTheme: CardThemeData(
      color: AppColorsExtension.dark.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // 확장 테마 등록
    extensions: [AppColorsExtension.dark, AppTextThemeExtension.dark],
  );
}

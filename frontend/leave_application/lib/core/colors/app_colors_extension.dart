import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primary,
    required this.primaryText,
    required this.background,
    required this.surface,
    required this.secondaryText,
    required this.mutedText,
    required this.neutral,
    required this.stroke,
    required this.surfaceTint,
  });

  final Color primary;
  final Color primaryText;
  final Color background;
  final Color surface;
  final Color secondaryText;
  final Color mutedText;
  final Color neutral;
  final Color stroke;
  final Color surfaceTint;

  /// 라이트 테마용 색상
  static const light = AppColorsExtension(
    primary: AppColors.primary,
    primaryText: AppColors.primaryText,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceBackground,
    secondaryText: AppColors.secondaryText,
    mutedText: AppColors.mutedText,
    neutral: AppColors.neutral,
    stroke: AppColors.stroke,
    surfaceTint: AppColors.surfaceTint,
  );

  /// 다크 테마용 색상
  static const dark = AppColorsExtension(
    primary: AppColors.primary,
    primaryText: AppColors.darkPrimaryText,
    background: AppColors.backgroundDark,
    surface: AppColors.darkSurface,
    secondaryText: AppColors.secondaryText,
    mutedText: AppColors.mutedText,
    neutral: AppColors.neutral,
    stroke: AppColors.stroke,
    surfaceTint: AppColors.surfaceTint,
  );

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryText,
    Color? background,
    Color? surface,
    Color? secondaryText,
    Color? mutedText,
    Color? neutral,
    Color? stroke,
    Color? surfaceTint,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryText: primaryText ?? this.primaryText,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      neutral: neutral ?? this.neutral,
      stroke: stroke ?? this.stroke,
      surfaceTint: surfaceTint ?? this.surfaceTint,
    );
  }

  @override
  AppColorsExtension lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
    );
  }
}

/// BuildContext 확장 - 간편한 색상 접근
extension AppColorsContext on BuildContext {
  /// 현재 테마의 앱 색상에 접근
  /// context.appColors.primary
  AppColorsExtension get appColors {
    return Theme.of(this).extension<AppColorsExtension>() ??
        AppColorsExtension.light;
  }
}

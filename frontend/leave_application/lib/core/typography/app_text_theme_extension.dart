import 'package:flutter/material.dart';
import 'package:leave_application/core/colors/app_colors.dart';
import 'package:leave_application/core/typography/app_text_styles.dart';

@immutable
class AppTextThemeExtension extends ThemeExtension<AppTextThemeExtension> {
  const AppTextThemeExtension({
    required this.heading1,
    required this.heading2,
    required this.heading3,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.caption,
    required this.statusBar,
    required this.searchPlaceholder,
    required this.inputField,
  });

  final TextStyle heading1;
  final TextStyle heading2;
  final TextStyle heading3;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;
  final TextStyle caption;
  final TextStyle statusBar;
  final TextStyle searchPlaceholder;
  final TextStyle inputField;

  /// 라이트 테마용 텍스트 스타일
  static final light = AppTextThemeExtension(
    heading1: AppTextStyles.heading1.copyWith(
      color: AppColors.darkPrimaryText, // 라이트 배경에는 다크 텍스트
    ),
    heading2: AppTextStyles.heading2.copyWith(color: AppColors.darkPrimaryText),
    heading3: AppTextStyles.heading3.copyWith(color: AppColors.primaryText),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryText),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText),
    bodySmall: AppTextStyles.bodySmall.copyWith(
      color: AppColors.darkPrimaryText,
    ),
    labelLarge: AppTextStyles.labelLarge.copyWith(
      color: AppColors.darkPrimaryText,
    ),
    labelMedium: AppTextStyles.labelMedium.copyWith(
      color: AppColors.primaryText,
    ),
    labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryText),
    caption: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
    statusBar: AppTextStyles.statusBar.copyWith(color: AppColors.primaryText),
    searchPlaceholder: AppTextStyles.searchPlaceholder.copyWith(
      color: AppColors.secondaryText,
    ),
    inputField: AppTextStyles.inputField.copyWith(color: AppColors.mutedText),
  );

  /// 다크 테마용 텍스트 스타일
  static final dark = AppTextThemeExtension(
    heading1: AppTextStyles.heading1.copyWith(color: AppColors.darkPrimaryText),
    heading2: AppTextStyles.heading2.copyWith(color: AppColors.darkPrimaryText),
    heading3: AppTextStyles.heading3.copyWith(color: AppColors.darkPrimaryText),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(
      color: AppColors.darkPrimaryText,
    ),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.darkPrimaryText,
    ),
    bodySmall: AppTextStyles.bodySmall.copyWith(
      color: AppColors.darkPrimaryText,
    ),
    labelLarge: AppTextStyles.labelLarge.copyWith(
      color: AppColors.darkPrimaryText,
    ),
    labelMedium: AppTextStyles.labelMedium.copyWith(
      color: AppColors.darkPrimaryText,
    ),
    labelSmall: AppTextStyles.labelSmall.copyWith(
      color: AppColors.darkPrimaryText,
    ),
    caption: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
    statusBar: AppTextStyles.statusBar.copyWith(
      color: AppColors.darkPrimaryText,
    ),
    searchPlaceholder: AppTextStyles.searchPlaceholder.copyWith(
      color: AppColors.secondaryText,
    ),
    inputField: AppTextStyles.inputField.copyWith(color: AppColors.mutedText),
  );

  @override
  AppTextThemeExtension copyWith({
    TextStyle? heading1,
    TextStyle? heading2,
    TextStyle? heading3,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    TextStyle? caption,
    TextStyle? statusBar,
    TextStyle? searchPlaceholder,
    TextStyle? inputField,
  }) {
    return AppTextThemeExtension(
      heading1: heading1 ?? this.heading1,
      heading2: heading2 ?? this.heading2,
      heading3: heading3 ?? this.heading3,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
      caption: caption ?? this.caption,
      statusBar: statusBar ?? this.statusBar,
      searchPlaceholder: searchPlaceholder ?? this.searchPlaceholder,
      inputField: inputField ?? this.inputField,
    );
  }

  @override
  AppTextThemeExtension lerp(
    covariant ThemeExtension<AppTextThemeExtension>? other,
    double t,
  ) {
    if (other is! AppTextThemeExtension) {
      return this;
    }
    return AppTextThemeExtension(
      heading1: TextStyle.lerp(heading1, other.heading1, t)!,
      heading2: TextStyle.lerp(heading2, other.heading2, t)!,
      heading3: TextStyle.lerp(heading3, other.heading3, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      statusBar: TextStyle.lerp(statusBar, other.statusBar, t)!,
      searchPlaceholder: TextStyle.lerp(
        searchPlaceholder,
        other.searchPlaceholder,
        t,
      )!,
      inputField: TextStyle.lerp(inputField, other.inputField, t)!,
    );
  }
}

/// BuildContext 확장 - 간편한 텍스트 스타일 접근
extension AppTextThemeContext on BuildContext {
  /// 현재 테마의 앱 텍스트 스타일에 접근
  AppTextThemeExtension get textStyles {
    return Theme.of(this).extension<AppTextThemeExtension>() ??
        AppTextThemeExtension.light;
  }
}

import 'package:flutter/material.dart';

import 'package:core_config/src/style/colors/colors_dark.dart';
import 'package:core_config/src/style/colors/colors_light.dart';

@immutable
class MyColors extends ThemeExtension<MyColors> {
  const MyColors({
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerLowest,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceBright,
    required this.surfaceDim,
    required this.surfaceTint,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixed,
    required this.onPrimaryFixedVariant,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixed,
    required this.onSecondaryFixedVariant,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.outline,
    required this.outlineVariant,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,

    // Custom UI colors
    required this.inputFill,
    required this.inputBorder,
    required this.hint,
    required this.saveButtonGradientEnd,
  });

  final Color background;
  final Color onBackground;

  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;

  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerLowest;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceBright;
  final Color surfaceDim;
  final Color surfaceTint;

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixed;
  final Color onPrimaryFixedVariant;

  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixed;
  final Color onSecondaryFixedVariant;

  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;

  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  final Color outline;
  final Color outlineVariant;

  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;

  // Custom UI colors
  final Color inputFill;
  final Color inputBorder;
  final Color hint;
  final Color saveButtonGradientEnd;

  @override
  MyColors copyWith({
    Color? background,
    Color? onBackground,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? surfaceContainer,
    Color? surfaceContainerLow,
    Color? surfaceContainerLowest,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? surfaceBright,
    Color? surfaceDim,
    Color? surfaceTint,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? primaryFixed,
    Color? primaryFixedDim,
    Color? onPrimaryFixed,
    Color? onPrimaryFixedVariant,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? secondaryFixed,
    Color? secondaryFixedDim,
    Color? onSecondaryFixed,
    Color? onSecondaryFixedVariant,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? tertiaryFixed,
    Color? tertiaryFixedDim,
    Color? onTertiaryFixed,
    Color? onTertiaryFixedVariant,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? outline,
    Color? outlineVariant,
    Color? inverseSurface,
    Color? inverseOnSurface,
    Color? inversePrimary,
    Color? inputFill,
    Color? inputBorder,
    Color? hint,
    Color? saveButtonGradientEnd,
  }) {
    return MyColors(
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      primaryFixedDim: primaryFixedDim ?? this.primaryFixedDim,
      onPrimaryFixed: onPrimaryFixed ?? this.onPrimaryFixed,
      onPrimaryFixedVariant:
          onPrimaryFixedVariant ?? this.onPrimaryFixedVariant,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      secondaryFixed: secondaryFixed ?? this.secondaryFixed,
      secondaryFixedDim: secondaryFixedDim ?? this.secondaryFixedDim,
      onSecondaryFixed: onSecondaryFixed ?? this.onSecondaryFixed,
      onSecondaryFixedVariant:
          onSecondaryFixedVariant ?? this.onSecondaryFixedVariant,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim ?? this.tertiaryFixedDim,
      onTertiaryFixed: onTertiaryFixed ?? this.onTertiaryFixed,
      onTertiaryFixedVariant:
          onTertiaryFixedVariant ?? this.onTertiaryFixedVariant,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      inverseOnSurface: inverseOnSurface ?? this.inverseOnSurface,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      hint: hint ?? this.hint,
      saveButtonGradientEnd:
          saveButtonGradientEnd ?? this.saveButtonGradientEnd,
    );
  }

  @override
  MyColors lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) {
      return this;
    }

    return MyColors(
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerLowest:
          Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerHighest: Color.lerp(
          surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      primaryFixedDim: Color.lerp(primaryFixedDim, other.primaryFixedDim, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      onPrimaryFixedVariant:
          Color.lerp(onPrimaryFixedVariant, other.onPrimaryFixedVariant, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      secondaryContainer:
          Color.lerp(secondaryContainer, other.secondaryContainer, t)!,
      onSecondaryContainer:
          Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t)!,
      secondaryFixed: Color.lerp(secondaryFixed, other.secondaryFixed, t)!,
      secondaryFixedDim:
          Color.lerp(secondaryFixedDim, other.secondaryFixedDim, t)!,
      onSecondaryFixed:
          Color.lerp(onSecondaryFixed, other.onSecondaryFixed, t)!,
      onSecondaryFixedVariant: Color.lerp(
          onSecondaryFixedVariant, other.onSecondaryFixedVariant, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      tertiaryContainer:
          Color.lerp(tertiaryContainer, other.tertiaryContainer, t)!,
      onTertiaryContainer:
          Color.lerp(onTertiaryContainer, other.onTertiaryContainer, t)!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
      tertiaryFixedDim:
          Color.lerp(tertiaryFixedDim, other.tertiaryFixedDim, t)!,
      onTertiaryFixed: Color.lerp(onTertiaryFixed, other.onTertiaryFixed, t)!,
      onTertiaryFixedVariant:
          Color.lerp(onTertiaryFixedVariant, other.onTertiaryFixedVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer:
          Color.lerp(onErrorContainer, other.onErrorContainer, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      inverseOnSurface:
          Color.lerp(inverseOnSurface, other.inverseOnSurface, t)!,
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      saveButtonGradientEnd:
          Color.lerp(saveButtonGradientEnd, other.saveButtonGradientEnd, t)!,
    );
  }

  static const MyColors dark = MyColors(
    background: ColorsDark.background,
    onBackground: ColorsDark.onBackground,
    surface: ColorsDark.surface,
    onSurface: ColorsDark.onSurface,
    surfaceVariant: ColorsDark.surfaceVariant,
    onSurfaceVariant: ColorsDark.onSurfaceVariant,
    surfaceContainer: ColorsDark.surfaceContainer,
    surfaceContainerLow: ColorsDark.surfaceContainerLow,
    surfaceContainerLowest: ColorsDark.surfaceContainerLowest,
    surfaceContainerHigh: ColorsDark.surfaceContainerHigh,
    surfaceContainerHighest: ColorsDark.surfaceContainerHighest,
    surfaceBright: ColorsDark.surfaceBright,
    surfaceDim: ColorsDark.surfaceDim,
    surfaceTint: ColorsDark.surfaceTint,
    primary: ColorsDark.primary,
    onPrimary: ColorsDark.onPrimary,
    primaryContainer: ColorsDark.primaryContainer,
    onPrimaryContainer: ColorsDark.onPrimaryContainer,
    primaryFixed: ColorsDark.primaryFixed,
    primaryFixedDim: ColorsDark.primaryFixedDim,
    onPrimaryFixed: ColorsDark.onPrimaryFixed,
    onPrimaryFixedVariant: ColorsDark.onPrimaryFixedVariant,
    secondary: ColorsDark.secondary,
    onSecondary: ColorsDark.onSecondary,
    secondaryContainer: ColorsDark.secondaryContainer,
    onSecondaryContainer: ColorsDark.onSecondaryContainer,
    secondaryFixed: ColorsDark.secondaryFixed,
    secondaryFixedDim: ColorsDark.secondaryFixedDim,
    onSecondaryFixed: ColorsDark.onSecondaryFixed,
    onSecondaryFixedVariant: ColorsDark.onSecondaryFixedVariant,
    tertiary: ColorsDark.tertiary,
    onTertiary: ColorsDark.onTertiary,
    tertiaryContainer: ColorsDark.tertiaryContainer,
    onTertiaryContainer: ColorsDark.onTertiaryContainer,
    tertiaryFixed: ColorsDark.tertiaryFixed,
    tertiaryFixedDim: ColorsDark.tertiaryFixedDim,
    onTertiaryFixed: ColorsDark.onTertiaryFixed,
    onTertiaryFixedVariant: ColorsDark.onTertiaryFixedVariant,
    error: ColorsDark.error,
    onError: ColorsDark.onError,
    errorContainer: ColorsDark.errorContainer,
    onErrorContainer: ColorsDark.onErrorContainer,
    outline: ColorsDark.outline,
    outlineVariant: ColorsDark.outlineVariant,
    inverseSurface: ColorsDark.inverseSurface,
    inverseOnSurface: ColorsDark.inverseOnSurface,
    inversePrimary: ColorsDark.inversePrimary,

    // Custom UI colors
    inputFill: ColorsDark.inputFill,
    inputBorder: ColorsDark.inputBorder,
    hint: ColorsDark.hint,
    saveButtonGradientEnd: ColorsDark.saveButtonGradientEnd,
  );

  static const MyColors light = MyColors(
    background: ColorsLight.background,
    onBackground: ColorsLight.onBackground,
    surface: ColorsLight.surface,
    onSurface: ColorsLight.onSurface,
    surfaceVariant: ColorsLight.surfaceVariant,
    onSurfaceVariant: ColorsLight.onSurfaceVariant,
    surfaceContainer: ColorsLight.surfaceContainer,
    surfaceContainerLow: ColorsLight.surfaceContainerLow,
    surfaceContainerLowest: ColorsLight.surfaceContainerLowest,
    surfaceContainerHigh: ColorsLight.surfaceContainerHigh,
    surfaceContainerHighest: ColorsLight.surfaceContainerHighest,
    surfaceBright: ColorsLight.surfaceBright,
    surfaceDim: ColorsLight.surfaceDim,
    surfaceTint: ColorsLight.surfaceTint,
    primary: ColorsLight.primary,
    onPrimary: ColorsLight.onPrimary,
    primaryContainer: ColorsLight.primaryContainer,
    onPrimaryContainer: ColorsLight.onPrimaryContainer,
    primaryFixed: ColorsLight.primaryFixed,
    primaryFixedDim: ColorsLight.primaryFixedDim,
    onPrimaryFixed: ColorsLight.onPrimaryFixed,
    onPrimaryFixedVariant: ColorsLight.onPrimaryFixedVariant,
    secondary: ColorsLight.secondary,
    onSecondary: ColorsLight.onSecondary,
    secondaryContainer: ColorsLight.secondaryContainer,
    onSecondaryContainer: ColorsLight.onSecondaryContainer,
    secondaryFixed: ColorsLight.secondaryFixed,
    secondaryFixedDim: ColorsLight.secondaryFixedDim,
    onSecondaryFixed: ColorsLight.onSecondaryFixed,
    onSecondaryFixedVariant: ColorsLight.onSecondaryFixedVariant,
    tertiary: ColorsLight.tertiary,
    onTertiary: ColorsLight.onTertiary,
    tertiaryContainer: ColorsLight.tertiaryContainer,
    onTertiaryContainer: ColorsLight.onTertiaryContainer,
    tertiaryFixed: ColorsLight.tertiaryFixed,
    tertiaryFixedDim: ColorsLight.tertiaryFixedDim,
    onTertiaryFixed: ColorsLight.onTertiaryFixed,
    onTertiaryFixedVariant: ColorsLight.onTertiaryFixedVariant,
    error: ColorsLight.error,
    onError: ColorsLight.onError,
    errorContainer: ColorsLight.errorContainer,
    onErrorContainer: ColorsLight.onErrorContainer,
    outline: ColorsLight.outline,
    outlineVariant: ColorsLight.outlineVariant,
    inverseSurface: ColorsLight.inverseSurface,
    inverseOnSurface: ColorsLight.inverseOnSurface,
    inversePrimary: ColorsLight.inversePrimary,

    // Custom UI colors
    inputFill: ColorsLight.inputFill,
    inputBorder: ColorsLight.inputBorder,
    hint: ColorsLight.hint,
    saveButtonGradientEnd: ColorsLight.saveButtonGradientEnd,
  );
}

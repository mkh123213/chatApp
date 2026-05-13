import 'package:flutter/material.dart';
import 'package:chat_material3/core/style/colors/colors_dark.dart';
import 'package:chat_material3/core/style/colors/colors_light.dart';
import 'package:chat_material3/core/style/fonts/font_family_helper.dart';
import 'package:chat_material3/core/style/theme/assets_extension.dart';
import 'package:chat_material3/core/style/theme/color_extension.dart';

ThemeData themeDark() {
  const colors = MyColors.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
    scaffoldBackgroundColor: colors.background,
    extensions: const <ThemeExtension<dynamic>>[
      MyColors.dark,
      MyAssets.dark,
    ],
    colorScheme: const ColorScheme.dark(
      primary: ColorsDark.primary,
      onPrimary: ColorsDark.onPrimary,
      primaryContainer: ColorsDark.primaryContainer,
      onPrimaryContainer: ColorsDark.onPrimaryContainer,
      secondary: ColorsDark.secondary,
      onSecondary: ColorsDark.onSecondary,
      secondaryContainer: ColorsDark.secondaryContainer,
      onSecondaryContainer: ColorsDark.onSecondaryContainer,
      tertiary: ColorsDark.tertiary,
      onTertiary: ColorsDark.onTertiary,
      tertiaryContainer: ColorsDark.tertiaryContainer,
      onTertiaryContainer: ColorsDark.onTertiaryContainer,
      error: ColorsDark.error,
      onError: ColorsDark.onError,
      errorContainer: ColorsDark.errorContainer,
      onErrorContainer: ColorsDark.onErrorContainer,
      surface: ColorsDark.surface,
      onSurface: ColorsDark.onSurface,
      surfaceContainerLowest: ColorsDark.surfaceContainerLowest,
      surfaceContainerLow: ColorsDark.surfaceContainerLow,
      surfaceContainer: ColorsDark.surfaceContainer,
      surfaceContainerHigh: ColorsDark.surfaceContainerHigh,
      surfaceContainerHighest: ColorsDark.surfaceContainerHighest,
      outline: ColorsDark.outline,
      outlineVariant: ColorsDark.outlineVariant,
      inverseSurface: ColorsDark.inverseSurface,
      onInverseSurface: ColorsDark.inverseOnSurface,
      inversePrimary: ColorsDark.inversePrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorsDark.surface,
      foregroundColor: ColorsDark.onSurface,
      surfaceTintColor: ColorsDark.surfaceTint,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: ColorsDark.onSurfaceVariant,
      ),
      actionsIconTheme: IconThemeData(
        color: ColorsDark.onSurfaceVariant,
      ),
      titleTextStyle: TextStyle(
        color: ColorsDark.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: colors.onSurfaceVariant,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: colors.onSurfaceVariant,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: colors.onSurfaceVariant,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    iconTheme: const IconThemeData(
      color: ColorsDark.onSurfaceVariant,
    ),
    cardTheme: CardThemeData(
      color: colors.surfaceContainer,
      surfaceTintColor: colors.surfaceTint,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colors.outlineVariant,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.inputFill,
      hintStyle: TextStyle(
        color: colors.hint,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
      ),
      labelStyle: TextStyle(
        color: colors.onSurfaceVariant,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
      ),
      prefixIconColor: colors.hint,
      suffixIconColor: colors.hint,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.inputBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.primaryContainer,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.error,
          width: 1.5,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: colors.surfaceContainerHighest,
        disabledForegroundColor: colors.onSurfaceVariant,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        textStyle: TextStyle(
          fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        textStyle: TextStyle(
          fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(
          color: colors.outline,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        textStyle: TextStyle(
          fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.surfaceContainer,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurfaceVariant,
      selectedLabelStyle: TextStyle(
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surfaceContainer,
      indicatorColor: colors.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colors.onPrimaryContainer);
        }
        return IconThemeData(color: colors.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: colors.onSurface,
            fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: colors.onSurfaceVariant,
          fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colors.outlineVariant,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.inverseSurface,
      contentTextStyle: TextStyle(
        color: colors.inverseOnSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

ThemeData themeLight() {
  const colors = MyColors.light;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
    scaffoldBackgroundColor: colors.background,
    extensions: const <ThemeExtension<dynamic>>[
      MyColors.light,
      MyAssets.light,
    ],
    colorScheme: const ColorScheme.light(
      primary: ColorsLight.primary,
      onPrimary: ColorsLight.onPrimary,
      primaryContainer: ColorsLight.primaryContainer,
      onPrimaryContainer: ColorsLight.onPrimaryContainer,
      secondary: ColorsLight.secondary,
      onSecondary: ColorsLight.onSecondary,
      secondaryContainer: ColorsLight.secondaryContainer,
      onSecondaryContainer: ColorsLight.onSecondaryContainer,
      tertiary: ColorsLight.tertiary,
      onTertiary: ColorsLight.onTertiary,
      tertiaryContainer: ColorsLight.tertiaryContainer,
      onTertiaryContainer: ColorsLight.onTertiaryContainer,
      error: ColorsLight.error,
      onError: ColorsLight.onError,
      errorContainer: ColorsLight.errorContainer,
      onErrorContainer: ColorsLight.onErrorContainer,
      surface: ColorsLight.surface,
      onSurface: ColorsLight.onSurface,
      surfaceContainerLowest: ColorsLight.surfaceContainerLowest,
      surfaceContainerLow: ColorsLight.surfaceContainerLow,
      surfaceContainer: ColorsLight.surfaceContainer,
      surfaceContainerHigh: ColorsLight.surfaceContainerHigh,
      surfaceContainerHighest: ColorsLight.surfaceContainerHighest,
      outline: ColorsLight.outline,
      outlineVariant: ColorsLight.outlineVariant,
      inverseSurface: ColorsLight.inverseSurface,
      onInverseSurface: ColorsLight.inverseOnSurface,
      inversePrimary: ColorsLight.inversePrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorsLight.surface,
      foregroundColor: ColorsLight.onSurface,
      surfaceTintColor: ColorsLight.surfaceTint,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: ColorsLight.onSurfaceVariant,
      ),
      actionsIconTheme: IconThemeData(
        color: ColorsLight.onSurfaceVariant,
      ),
      titleTextStyle: TextStyle(
        color: ColorsLight.primary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: colors.onSurfaceVariant,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: colors.onSurfaceVariant,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: colors.onSurfaceVariant,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    iconTheme: const IconThemeData(
      color: ColorsLight.onSurfaceVariant,
    ),
    cardTheme: CardThemeData(
      color: colors.surfaceContainerLowest,
      surfaceTintColor: colors.surfaceTint,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colors.outlineVariant,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.inputFill,
      hintStyle: TextStyle(
        color: colors.hint,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
      ),
      labelStyle: TextStyle(
        color: colors.onSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
      ),
      prefixIconColor: colors.onSurfaceVariant,
      suffixIconColor: colors.onSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.inputBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.error,
          width: 1.5,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        disabledBackgroundColor: colors.surfaceContainerHighest,
        disabledForegroundColor: colors.onSurfaceVariant,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        textStyle: TextStyle(
          fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        textStyle: TextStyle(
          fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        side: BorderSide(
          color: colors.outline,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        textStyle: TextStyle(
          fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.surfaceContainerLowest,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.onSurfaceVariant,
      selectedLabelStyle: TextStyle(
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surfaceContainerLowest,
      indicatorColor: colors.secondaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colors.primary);
        }
        return IconThemeData(color: colors.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: colors.primary,
            fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: colors.onSurfaceVariant,
          fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colors.outlineVariant,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.inverseSurface,
      contentTextStyle: TextStyle(
        color: colors.inverseOnSurface,
        fontFamily: FontFamilyHelper.geLocalozedFontFamily(),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

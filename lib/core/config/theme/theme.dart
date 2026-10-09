import 'package:flutter/material.dart';
import 'package:boker/core/utils/constants/app_constants.dart';

class ColorsManager {
  ColorsManager._();
  static const Color primaryColor = Color(0xFF5A24A2);
  static const Color secondaryColor = Color(0xFFF3CD11);
  static const Color lightSurface = Color(0xFFF5F6FA);
  static const Color darkSurface = Color(0xFF0D0F1A);
  static const Color blueLight = Color(0xffe9ecf5);
}

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() => const ColorScheme(
    brightness: Brightness.light,
    primary: ColorsManager.primaryColor,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDDE5FF),
    onPrimaryContainer: Color(0xFF1B2C63),
    secondary: ColorsManager.secondaryColor,
    onSecondary: Color(0xFF1C1C1C),
    secondaryContainer: Color(0xFFFFF8D6),
    onSecondaryContainer: Color(0xFF1C1C1C),
    tertiary: Color(0xFFFBEE6E),
    onTertiary: Color(0xFF2F2500),
    tertiaryContainer: Color(0xFFFFF3C0),
    onTertiaryContainer: Color(0xFF2C1F00),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: ColorsManager.lightSurface,
    onSurface: Color(0xFF10121A),
    onSurfaceVariant: Color(0xFF7C8193),
    outline: Color(0xFFCBD0DC),
    outlineVariant: Color(0xFFE6E9F2),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1E2230),
    inversePrimary: Color(0xFF9AA8DA),
    surfaceTint: ColorsManager.primaryColor,
    primaryFixed: Color(0xFF1E2E70),
    onPrimaryFixed: Color(0xFFFFFFFF),
    primaryFixedDim: ColorsManager.primaryColor,
    onPrimaryFixedVariant: Color(0xFFFFFFFF),
    secondaryFixed: Color(0xFFE2E6F2),
    onSecondaryFixed: Color(0xFF12141A),
    secondaryFixedDim: Color(0xFFC6CAD9),
    onSecondaryFixedVariant: Color(0xFF2E3447),
    tertiaryFixed: Color(0xFFFFE7B8),
    onTertiaryFixed: Color(0xFF2C1F00),
    tertiaryFixedDim: Color(0xFFF4B43F),
    onTertiaryFixedVariant: Color(0xFF4A360C),
    surfaceBright: Color(0xFFFDFDFF),
    surfaceDim: Color(0xFFDADDE6),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF1F3F8),
    surfaceContainer: Color(0xFFE9ECF2),
    surfaceContainerHigh: Color(0xFFE1E4EC),
    surfaceContainerHighest: Color(0xFFD6DAE4),
  );

  ThemeData light() => theme(lightScheme());

  static ColorScheme darkScheme() => const ColorScheme(
    brightness: Brightness.dark,
    primary: ColorsManager.primaryColor,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF1E2E70),
    onPrimaryContainer: Color(0xFFDCE5FF),
    secondary: ColorsManager.secondaryColor,
    onSecondary: Color(0xFF1C1C1C),
    secondaryContainer: Color(0xFF5C4D0A),
    onSecondaryContainer: Color(0xFFFFF7CC),
    tertiary: Color(0xFFFBEE6E),
    onTertiary: Color(0xFF2F2500),
    tertiaryContainer: Color(0xFF5C4210),
    onTertiaryContainer: Color(0xFFFFE7B8),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: ColorsManager.darkSurface,
    onSurface: Color(0xFFE5E7EF),
    onSurfaceVariant: Color(0xFFA8AEC4),
    outline: Color(0xFF41465A),
    outlineVariant: Color(0xFF2A2F42),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE5E7EF),
    inversePrimary: Color(0xFF9AA8DA),
    surfaceTint: ColorsManager.primaryColor,
    primaryFixed: Color(0xFF1E2E70),
    onPrimaryFixed: Color(0xFFFFFFFF),
    primaryFixedDim: ColorsManager.primaryColor,
    onPrimaryFixedVariant: Color(0xFFFFFFFF),
    secondaryFixed: Color(0xFF2A3147),
    onSecondaryFixed: Color(0xFFDCE2F5),
    secondaryFixedDim: Color(0xFF3A4258),
    onSecondaryFixedVariant: Color(0xFFE5E9F6),
    tertiaryFixed: Color(0xFF5C4210),
    onTertiaryFixed: Color(0xFFFFE7B8),
    tertiaryFixedDim: Color(0xFF815E18),
    onTertiaryFixedVariant: Color(0xFFFFEFD2),
    surfaceBright: Color(0xFF1A1D28),
    surfaceDim: Color(0xFF0A0C14),
    surfaceContainerLowest: Color(0xFF05060C),
    surfaceContainerLow: Color(0xFF10131D),
    surfaceContainer: Color(0xFF151826),
    surfaceContainerHigh: Color(0xFF1C2030),
    surfaceContainerHighest: Color(0xFF252A3B),
  );

  ThemeData dark() => theme(darkScheme());

  ThemeData theme(ColorScheme colorScheme) {
    final baseText = textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    final refinedText = baseText.copyWith(
      headlineLarge: baseText.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: Color(0xff14265C),
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: Color(0xff14265C),
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: Color(0xff14265C),
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: baseText.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400
      )
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: refinedText,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: refinedText.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        labelStyle: refinedText.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: refinedText.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 32,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: refinedText.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

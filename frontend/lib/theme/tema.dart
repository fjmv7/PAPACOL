import 'package:flutter/material.dart';

/// Paleta tomada del logo de PAPACOL y de las fotos del campo: verde de la
/// camisa y las hojas, café de la tierra, dorado de la cosecha y crema de la
/// papa. El verde con texto blanco da 6,6:1 (WCAG AA pide 4,5:1).
class Paleta {
  static const verdeCampo = Color(0xFF55622A);
  static const verdeSuave = Color(0xFFE2E8C6);
  static const tierra = Color(0xFF5A3A1E);
  static const marfil = Color(0xFFFBF6EA);
  static const cosecha = Color(0xFFD4922A);
  static const texto = Color(0xFF2E2414);
  static const textoSuave = Color(0xFF6E6553);
  static const borde = Color(0xFFE6DDC8);
  static const error = Color(0xFFB0412E);
}

const _esquemaClaro = ColorScheme(
  brightness: Brightness.light,
  primary: Paleta.verdeCampo,
  onPrimary: Colors.white,
  primaryContainer: Paleta.verdeSuave,
  onPrimaryContainer: Paleta.texto,
  secondary: Paleta.tierra,
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFF0E2CF),
  onSecondaryContainer: Color(0xFF3E2812),
  tertiary: Paleta.cosecha,
  onTertiary: Paleta.texto,
  tertiaryContainer: Color(0xFFF8E6C2),
  onTertiaryContainer: Color(0xFF5A3B08),
  error: Paleta.error,
  onError: Colors.white,
  surface: Paleta.marfil,
  onSurface: Paleta.texto,
  onSurfaceVariant: Paleta.textoSuave,
  outline: Color(0xFFC4B89C),
  outlineVariant: Paleta.borde,
  surfaceContainerLowest: Colors.white,
  surfaceContainerLow: Color(0xFFF7F1E2),
  surfaceContainer: Color(0xFFF2EBD9),
  surfaceContainerHigh: Color(0xFFEDEBD5),
  surfaceContainerHighest: Paleta.borde,
);

/// Modo "Verde & Oscuro" (Canva, pantalla de perfil).
const _esquemaOscuro = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFB9CC85),
  onPrimary: Color(0xFF26300A),
  primaryContainer: Color(0xFF3C4718),
  onPrimaryContainer: Paleta.verdeSuave,
  secondary: Color(0xFFDDB98F),
  onSecondary: Color(0xFF3E2A15),
  secondaryContainer: Color(0xFF4A3727),
  onSecondaryContainer: Color(0xFFF1E6D8),
  tertiary: Paleta.cosecha,
  onTertiary: Color(0xFF2A2000),
  tertiaryContainer: Color(0xFF5A4511),
  onTertiaryContainer: Color(0xFFFBEFCF),
  error: Color(0xFFE7A08F),
  onError: Color(0xFF3A0E06),
  surface: Color(0xFF17170F),
  onSurface: Color(0xFFEDE8DA),
  onSurfaceVariant: Color(0xFFB8AF98),
  outline: Color(0xFF5E5843),
  outlineVariant: Color(0xFF353222),
  surfaceContainerLowest: Color(0xFF1E1D13),
  surfaceContainerLow: Color(0xFF212016),
  surfaceContainer: Color(0xFF262418),
  surfaceContainerHigh: Color(0xFF2E2C1E),
  surfaceContainerHighest: Color(0xFF383524),
);

ThemeData temaClaro() => _construirTema(_esquemaClaro);
ThemeData temaOscuro() => _construirTema(_esquemaOscuro);

ThemeData _construirTema(ColorScheme cs) {
  final radio = BorderRadius.circular(14);
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: cs.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: radio, borderSide: BorderSide(color: cs.outlineVariant)),
      enabledBorder: OutlineInputBorder(
          borderRadius: radio, borderSide: BorderSide(color: cs.outlineVariant)),
      focusedBorder: OutlineInputBorder(
          borderRadius: radio, borderSide: BorderSide(color: cs.primary, width: 2)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: radio),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.primary),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: radio),
      ),
    ),
    cardTheme: CardThemeData(
      color: cs.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cs.outlineVariant),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: cs.outlineVariant),
      backgroundColor: cs.surfaceContainerLowest,
      selectedColor: cs.primary,
      labelStyle: TextStyle(color: cs.onSurface),
      secondaryLabelStyle: TextStyle(color: cs.onPrimary),
      checkmarkColor: cs.onPrimary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      indicatorColor: cs.primaryContainer,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(color: cs.outlineVariant, space: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

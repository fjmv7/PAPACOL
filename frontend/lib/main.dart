import 'package:flutter/material.dart';
import 'screens/catalogo_screen.dart';

void main() {
  runApp(const PapacolApp());
}

class PapacolApp extends StatelessWidget {
  const PapacolApp({super.key});

  static const Color verdeCampo = Color(0xFF276749);
  static const Color verdeClaro = Color(0xFFEAF4EC);
  static const Color cafeTierra = Color(0xFF765438);
  static const Color fondo = Color(0xFFF7F9F6);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAPACOL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: verdeCampo,
          primary: verdeCampo,
          secondary: cafeTierra,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: fondo,
        appBarTheme: const AppBarTheme(
          backgroundColor: fondo,
          foregroundColor: verdeCampo,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: verdeCampo,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFDCE5DC),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFDCE5DC),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: verdeCampo,
              width: 2,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: verdeCampo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: Color(0xFFE4EAE3),
            ),
          ),
        ),
      ),
      home: const CatalogoScreen(),
    );
  }
}

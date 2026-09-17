import 'package:flutter/material.dart';
import 'screens/catalogo_screen.dart';

void main() => runApp(const PapacolApp());

class PapacolApp extends StatelessWidget {
  const PapacolApp({super.key});

  static const Color verdeCampo = Color(0xFF4A7C3F);
  static const Color cafeTierra = Color(0xFF6B4A2F);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAPACOL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: verdeCampo, primary: verdeCampo, secondary: cafeTierra),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const CatalogoScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/bienvenida_screen.dart';
import 'screens/navegacion.dart';
import 'state/preferencias.dart';
import 'theme/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferencias.instancia.cargar();
  runApp(const PapacolApp());
}

class PapacolApp extends StatelessWidget {
  const PapacolApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Preferencias.instancia;
    return ListenableBuilder(
      listenable: prefs,
      builder: (context, _) => MaterialApp(
        title: 'PAPACOL',
        debugShowCheckedModeBanner: false,
        theme: temaClaro(),
        darkTheme: temaOscuro(),
        themeMode: prefs.modoOscuro ? ThemeMode.dark : ThemeMode.light,
        navigatorKey: navegadorRaiz,
        home: const PresentacionScreen(),
      ),
    );
  }
}

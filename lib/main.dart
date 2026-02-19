import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  // ✅ INICIALIZAÇÃO MÍNIMA - Todo o resto acontece no SplashScreen
  runApp(const NotaOKApp());
}

class NotaOKApp extends StatelessWidget {
  const NotaOKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotaOK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      // ✅ APP SEMPRE INICIA NO SPLASHSCREEN
      home: const SplashScreen(),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  // Configurar tratamento de erros
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    }
  };

  // Garantir inicialização do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 Iniciar o app DIRETAMENTE com o SplashScreen
  // O SplashScreen vai cuidar de TODA a inicialização
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          primary: const Color(0xFF6A1B9A),
          secondary: const Color(0xFFFF6F00),
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      // 🎯 INICIAR SEMPRE COM O SPLASHSCREEN
      // Ele vai cuidar de Firebase, Hive e Autenticação
      home: const SplashScreen(),
    );
  }
}

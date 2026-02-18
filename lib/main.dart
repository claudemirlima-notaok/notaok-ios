import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/hive_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/email_verification_screen.dart';
import 'splash_screen.dart';

void main() async {
  // Configurar tratamento de erros
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      debugPrint('Flutter Error: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    }
  };

  // Garantir inicialização do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🔥 PASSO 1: Inicializar Firebase UMA VEZ
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (kDebugMode) {
        debugPrint('✅ Firebase inicializado com sucesso!');
      }
    } else {
      if (kDebugMode) {
        debugPrint('✅ Firebase já estava inicializado');
      }
    }

    // 📦 PASSO 2: Inicializar Hive DEPOIS do Firebase
    await HiveService.init();
    if (kDebugMode) {
      debugPrint('✅ Hive inicializado com sucesso!');
    }

  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ Erro na inicialização: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // 🚀 PASSO 3: Iniciar o app DEPOIS de tudo estar pronto
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
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto verifica autenticação, mostra splash
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // Se tem usuário logado
          if (snapshot.hasData) {
            final user = snapshot.data;
            
            // Verificar se o email foi verificado
            if (user != null && !user.emailVerified && !user.isAnonymous) {
              return const EmailVerificationScreen();
            }
            
            // Email verificado ou login anônimo, vai para home
            return const HomeScreen();
          }

          // Não tem usuário, mostra login
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

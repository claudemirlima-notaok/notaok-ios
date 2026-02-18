import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/hive_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/email_verification_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 🔥 PASSO 1: Inicializar Firebase UMA VEZ
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('✅ Firebase inicializado com sucesso!');
      } else {
        debugPrint('✅ Firebase já estava inicializado');
      }

      // 📦 PASSO 2: Inicializar Hive DEPOIS do Firebase
      await HiveService.init();
      debugPrint('✅ Hive inicializado com sucesso!');

      // ✅ PASSO 3: Aguardar 1 segundo para garantir que tudo está pronto
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Erro na inicialização: $e');
      debugPrint('Stack trace: $stackTrace');
      
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se houve erro, mostra tela de erro
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF6A1B9A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Erro ao inicializar o app',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = '';
                    });
                    _initialize();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6A1B9A),
                  ),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Se ainda não inicializou, mostra splash screen
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF6A1B9A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou ícone do app
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  size: 64,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'NotaOK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Inicializando...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Inicialização completa! Verificar autenticação
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto verifica autenticação, mantém splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF6A1B9A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      size: 64,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          );
        }

        // Se tem usuário logado
        if (snapshot.hasData) {
          final user = snapshot.data;

          // Verificar se o email foi verificado
          if (user != null && !user.emailVerified && !user.isAnonymous) {
            return EmailVerificationScreen(
              email: user.email ?? '',
              userId: user.uid,
            );
          }

          // Email verificado ou login anônimo, vai para home
          return const HomeScreen();
        }

        // Não tem usuário, mostra login
        return const LoginScreen();
      },
    );
  }
}

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
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitializing) {
      debugPrint('⚠️ Inicialização já em andamento, ignorando...');
      return;
    }

    setState(() {
      _isInitializing = true;
      _errorMessage = '';
    });

    try {
      // 🔥 PASSO 1: Garantir que Firebase está inicializado (SEM tentar reinicializar)
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('✅ Firebase inicializado com sucesso!');
      } on FirebaseException catch (e) {
        if (e.code == 'duplicate-app') {
          debugPrint('✅ Firebase já estava inicializado - OK!');
        } else {
          rethrow;
        }
      }

      // 🚪 PASSO 2: Fazer logout forçado de forma segura
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          debugPrint('🚪 Usuário detectado: ${currentUser.email}, fazendo logout...');
          await FirebaseAuth.instance.signOut();
          debugPrint('✅ Logout forçado executado com sucesso');
        } else {
          debugPrint('✅ Nenhum usuário logado, prosseguindo...');
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao fazer logout (não crítico): $e');
      }

      // 📦 PASSO 3: Inicializar Hive
      await HiveService.init();
      debugPrint('✅ Hive inicializado com sucesso!');

      // ✅ PASSO 4: Aguardar 5 segundos para garantir que tudo está pronto (UX melhorada)
      await Future.delayed(const Duration(seconds: 5));

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isInitializing = false;
        });
        debugPrint('🎉 Inicialização completa! App pronto para uso.');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro na inicialização: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao inicializar o app. Por favor, feche o app completamente e abra novamente.';
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se houve erro, mostra tela de erro
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF6A1B9A),
        body: SafeArea(
          child: Center(
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isInitializing
                        ? null
                        : () {
                            if (mounted) {
                              setState(() {
                                _errorMessage = '';
                              });
                              _initialize();
                            }
                          },
                    icon: _isInitializing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6A1B9A),
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(_isInitializing ? 'Tentando...' : 'Fechar app e abrir novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6A1B9A),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Se ainda não inicializou, mostra splash screen
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF6A1B9A),
        body: SafeArea(
          child: Center(
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
        ),
      );
    }

    // ✅ Inicialização completa! Mostrar tela de login diretamente
    return const LoginScreen();
  }
}

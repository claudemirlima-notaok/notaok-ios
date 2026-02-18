import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'phone_verification_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String userId;
  final String? telefone;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.userId,
    this.telefone,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _timer;
  Timer? _checkTimer;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _startResendTimer();
    _startCheckingEmailVerification();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _successMessage = 'Email de verificação enviado com sucesso!';
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao enviar email: ${e.toString()}';
        _successMessage = null;
      });
    }
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _startCheckingEmailVerification() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user?.emailVerified ?? false) {
        timer.cancel();
        await _onEmailVerified();
      }
    });
  }

  Future<void> _onEmailVerified() async {
    try {
      // Atualizar Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .update({
        'emailVerificado': true,
        'dataVerificacaoEmail': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Se tem telefone, ir para verificação de telefone
        if (widget.telefone != null && widget.telefone!.isNotEmpty) {
          String telefoneFormatado = widget.telefone!.replaceAll(RegExp(r'[^0-9]'), '');
          if (!telefoneFormatado.startsWith('55')) {
            telefoneFormatado = '+55$telefoneFormatado';
          } else {
            telefoneFormatado = '+$telefoneFormatado';
          }
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PhoneVerificationScreen(
                phoneNumber: telefoneFormatado,
                userId: widget.userId,
              ),
            ),
          );
        } else {
          // Ir direto para home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verificado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao atualizar Firestore: $e');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _sendVerificationEmail();
      _startResendTimer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao reenviar email: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkManually() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user?.emailVerified ?? false) {
        await _onEmailVerified();
      } else {
        setState(() {
          _errorMessage = 'Email ainda não verificado. Verifique sua caixa de entrada.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao verificar: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Card branco com conteudo
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Ícone
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Título
                        Text(
                          'Verifique seu Email',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Mensagem
                        Text(
                          'Enviamos um link de verificação para:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          widget.email,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Instruções
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Como verificar:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '1. Abra seu email\n2. Clique no link de verificação\n3. Volte para o app\n4. Clique em "Já verifiquei"',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Mensagem de sucesso
                        if (_successMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _successMessage!,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Mensagem de erro
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        
                        // Botão Já Verifiquei
                        ElevatedButton(
                          onPressed: _isLoading ? null : _checkManually,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Já Verifiquei - Continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Reenviar email
                        TextButton(
                          onPressed: _canResend && !_isLoading ? _resendEmail : null,
                          child: Text(
                            _canResend
                                ? 'Reenviar Email'
                                : 'Reenviar em $_resendCountdown segundos',
                            style: TextStyle(
                              fontSize: 14,
                              color: _canResend ? Theme.of(context).primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Voltar para login
                        TextButton(
                          onPressed: () async {
                            try {
                              _timer?.cancel();
                              _checkTimer?.cancel();
                              await FirebaseAuth.instance.signOut();
                              if (mounted) {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            } catch (e) {
                              debugPrint('Erro ao voltar: $e');
                              if (mounted) {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            }
                          },
                          child: const Text('Voltar para Login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

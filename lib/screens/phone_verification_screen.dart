import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import '../services/auth_service.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String userId;

  const PhoneVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.userId,
  });

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _timer;
  String? _errorMessage;
  String? _verificationId;
  int? _resendToken;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _sendVerificationCode();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolucao automatica (Android)
          try {
            await FirebaseAuth.instance.currentUser?.updatePhoneNumber(credential);
            if (mounted) {
              await _onVerificationSuccess();
            }
          } catch (e) {
            debugPrint('Erro na verificacao automatica: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            if (e.code == 'invalid-phone-number') {
              _errorMessage = 'Numero de telefone invalido';
            } else if (e.code == 'too-many-requests') {
              _errorMessage = 'Muitas tentativas. Tente novamente mais tarde';
            } else {
              _errorMessage = 'Erro ao enviar SMS: ${e.message}';
            }
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Codigo SMS enviado com sucesso'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao enviar SMS: $e';
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

  Future<void> _verifyCode() async {
    String code = _controllers.map((c) => c.text).join();

    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Digite o codigo completo de 6 digitos';
      });
      return;
    }

    if (_verificationId == null) {
      setState(() {
        _errorMessage = 'Erro: codigo de verificacao nao enviado';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Criar credencial com o codigo
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      // Verificar o codigo linkando com o usuario atual
      await FirebaseAuth.instance.currentUser?.updatePhoneNumber(credential);
      
      // Sucesso
      await _onVerificationSuccess();
      
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'invalid-verification-code') {
          _errorMessage = 'Codigo invalido. Verifique e tente novamente';
        } else if (e.code == 'session-expired') {
          _errorMessage = 'Codigo expirado. Solicite um novo codigo';
        } else {
          _errorMessage = 'Erro na verificacao: ${e.message}';
        }
      });

      // Limpar os campos
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao verificar codigo: $e';
      });
    }
  }

  Future<void> _onVerificationSuccess() async {
    try {
      // Atualizar campo telefoneVerificado no Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .update({
        'telefoneVerificado': true,
        'dataVerificacaoTelefone': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Telefone verificado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar para Home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      debugPrint('Erro ao atualizar Firestore: $e');
      // Mesmo com erro no Firestore, permitir acesso
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _errorMessage = null;
    });
    
    _startResendTimer();
    await _sendVerificationCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Telefone'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Icone
              Icon(
                Icons.phone_android,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              
              const SizedBox(height: 24),
              
              // Titulo
              Text(
                'Verifique seu Telefone',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Mensagem
              Text(
                'Enviamos um codigo SMS de 6 digitos para:',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                widget.phoneNumber,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Campos de codigo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        
                        // Se preencheu todos, verificar automaticamente
                        if (index == 5 && value.isNotEmpty) {
                          _verifyCode();
                        }
                      },
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 24),
              
              // Mensagem de erro
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
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
              
              const SizedBox(height: 24),
              
              // Botao Verificar
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Verificar Codigo',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 24),
              
              // Reenviar codigo
              TextButton(
                onPressed: _canResend && !_isLoading ? _resendCode : null,
                child: Text(
                  _canResend
                      ? 'Reenviar Codigo SMS'
                      : 'Reenviar em $_resendCountdown segundos',
                  style: TextStyle(
                    fontSize: 14,
                    color: _canResend ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Voltar para login
              TextButton(
                onPressed: () async {
                  try {
                    _timer?.cancel();
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
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obter usuário atual
  User? get currentUser => _auth.currentUser;

  /// Enviar código SMS para o telefone
  Future<void> enviarCodigoSMS({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      // Formatar número para padrão internacional (+55...)
      String formattedPhone = _formatarTelefone(phoneNumber);
      
      debugPrint('📱 Enviando SMS para: $formattedPhone');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        
        // Callback quando código é enviado com sucesso
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ Verificação automática concluída (Android)');
          // No Android, pode ser verificado automaticamente
          await _auth.signInWithCredential(credential);
        },
        
        // Callback quando falha a verificação
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Erro na verificação: ${e.code} - ${e.message}');
          
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Número de telefone inválido. Verifique e tente novamente.';
              break;
            case 'too-many-requests':
              errorMessage = 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
              break;
            case 'quota-exceeded':
              errorMessage = 'Limite de SMS excedido. Tente novamente mais tarde.';
              break;
            case 'network-request-failed':
              errorMessage = 'Erro de conexão. Verifique sua internet.';
              break;
            default:
              errorMessage = 'Erro ao enviar SMS: ${e.message ?? 'Erro desconhecido'}';
          }
          
          onError(errorMessage);
        },
        
        // Callback quando código é enviado
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ Código SMS enviado! VerificationId: $verificationId');
          onCodeSent(verificationId);
        },
        
        // Callback quando tempo limite expira
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱️ Tempo limite de auto-verificação expirado');
        },
      );
    } catch (e) {
      debugPrint('❌ Erro inesperado ao enviar SMS: $e');
      onError('Erro ao enviar SMS. Tente novamente.');
    }
  }

  /// Verificar código SMS digitado pelo usuário
  Future<User?> verificarCodigoSMS({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      debugPrint('🔍 Verificando código SMS: $smsCode');

      // Criar credencial com verification ID e código SMS
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Fazer login com a credencial
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      debugPrint('✅ Login com telefone realizado com sucesso!');
      return userCredential.user;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro ao verificar código: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'invalid-verification-code':
          throw Exception('Código inválido. Verifique e tente novamente.');
        case 'invalid-verification-id':
          throw Exception('Sessão expirada. Solicite um novo código.');
        case 'session-expired':
          throw Exception('Código expirado. Solicite um novo código.');
        case 'too-many-requests':
          throw Exception('Muitas tentativas. Aguarde alguns minutos.');
        default:
          throw Exception('Erro ao verificar código: ${e.message ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      debugPrint('❌ Erro inesperado ao verificar código: $e');
      throw Exception('Erro ao verificar código. Tente novamente.');
    }
  }

  /// Salvar dados complementares do usuário no Firestore
  Future<void> salvarDadosComplementares({
    required String userId,
    required String nome,
    required String email,
    required String cpf,
    required String telefone,
    String? dataNascimento,
  }) async {
    try {
      debugPrint('💾 Salvando dados complementares do usuário: $userId');

      // Atualizar displayName no Firebase Auth
      await _auth.currentUser?.updateDisplayName(nome);
      await _auth.currentUser?.updateEmail(email);

      // Salvar dados completos no Firestore
      await _firestore.collection('usuarios').doc(userId).set({
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
        'dataNascimento': dataNascimento,
        'criadoEm': FieldValue.serverTimestamp(),
        'metodoLogin': 'telefone',
        'telefoneVerificado': true,
      }, SetOptions(merge: true));

      debugPrint('✅ Dados complementares salvos com sucesso!');
    } catch (e) {
      debugPrint('❌ Erro ao salvar dados complementares: $e');
      throw Exception('Erro ao salvar dados. Tente novamente.');
    }
  }

  /// Formatar telefone para padrão internacional (+55...)
  String _formatarTelefone(String phone) {
    // Remove caracteres não numéricos
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Se não começar com código do país, adiciona +55 (Brasil)
    if (!cleaned.startsWith('55')) {
      cleaned = '55$cleaned';
    }
    
    // Adiciona o +
    return '+$cleaned';
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      debugPrint('✅ Logout realizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao fazer logout: $e');
      throw Exception('Erro ao sair da conta.');
    }
  }
}

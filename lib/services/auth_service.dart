import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obter usuário atual
  User? get currentUser => _auth.currentUser;

  // Stream de mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Registrar novo usuário com tratamento de erros melhorado
  Future<UserCredential?> registrarComEmailESenha({
    required String email,
    required String senha,
    required String nomeCompleto,
  }) async {
    try {
      // Criar usuário
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Atualizar nome do usuário
      await userCredential.user?.updateDisplayName(nomeCompleto);
      
      // Enviar email de verificação
      await enviarEmailVerificacao();
      
      debugPrint('✅ Usuário registrado com sucesso: $email');
      return userCredential;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro no registro: ${e.code} - ${e.message}');
      
      // Lançar exceção com mensagem amigável em português
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Este email já está cadastrado. Faça login ou use outro email.');
        case 'weak-password':
          throw Exception('A senha é muito fraca. Use pelo menos 6 caracteres.');
        case 'invalid-email':
          throw Exception('O email informado é inválido. Verifique e tente novamente.');
        case 'operation-not-allowed':
          throw Exception('Cadastro com email/senha não está habilitado. Entre em contato com o suporte.');
        case 'network-request-failed':
          throw Exception('Erro de conexão. Verifique sua internet e tente novamente.');
        default:
          throw Exception('Erro ao criar conta: ${e.message ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      debugPrint('❌ Erro inesperado no registro: $e');
      throw Exception('Erro ao criar conta. Tente novamente mais tarde.');
    }
  }

  /// Login com email e senha
  Future<UserCredential?> loginComEmailESenha({
    required String email,
    required String senha,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      debugPrint('✅ Login realizado com sucesso: $email');
      return userCredential;
      
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro no login: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email não cadastrado. Verifique ou crie uma nova conta.');
        case 'wrong-password':
          throw Exception('Senha incorreta. Tente novamente ou recupere sua senha.');
        case 'invalid-email':
          throw Exception('O email informado é inválido.');
        case 'user-disabled':
          throw Exception('Esta conta foi desativada. Entre em contato com o suporte.');
        case 'too-many-requests':
          throw Exception('Muitas tentativas de login. Aguarde alguns minutos e tente novamente.');
        case 'network-request-failed':
          throw Exception('Erro de conexão. Verifique sua internet.');
        default:
          throw Exception('Erro ao fazer login: ${e.message ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      debugPrint('❌ Erro inesperado no login: $e');
      throw Exception('Erro ao fazer login. Tente novamente.');
    }
  }

  /// Enviar email de verificação com ActionCodeSettings personalizado
  Future<void> enviarEmailVerificacao() async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('Nenhum usuário logado.');
      }

      if (user.emailVerified) {
        debugPrint('✅ Email já verificado');
        return;
      }

      // Configurar ActionCodeSettings para email personalizado
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://notaok-4d791.firebaseapp.com/__/auth/action',
        handleCodeInApp: false,
        iOSBundleId: 'com.notaok.app',
        androidPackageName: 'com.notaok.app',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      await user.sendEmailVerification(actionCodeSettings);
      
      debugPrint('✅ Email de verificação enviado para: ${user.email}');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro ao enviar email de verificação: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'too-many-requests':
          throw Exception('Muitos emails enviados. Aguarde alguns minutos e tente novamente.');
        case 'invalid-email':
          throw Exception('Email inválido.');
        default:
          throw Exception('Erro ao enviar email: ${e.message ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      debugPrint('❌ Erro inesperado ao enviar email: $e');
      throw Exception('Erro ao enviar email de verificação.');
    }
  }

  /// Recarregar dados do usuário
  Future<void> recarregarUsuario() async {
    try {
      await _auth.currentUser?.reload();
      debugPrint('✅ Dados do usuário recarregados');
    } catch (e) {
      debugPrint('❌ Erro ao recarregar usuário: $e');
    }
  }

  /// Fazer logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      debugPrint('✅ Logout realizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao fazer logout: $e');
      throw Exception('Erro ao sair da conta.');
    }
  }

  /// Redefinir senha
  Future<void> redefinirSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Email de redefinição de senha enviado para: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro ao enviar email de redefinição: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email não cadastrado.');
        case 'invalid-email':
          throw Exception('Email inválido.');
        default:
          throw Exception('Erro ao enviar email: ${e.message ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      debugPrint('❌ Erro inesperado ao redefinir senha: $e');
      throw Exception('Erro ao enviar email de recuperação.');
    }
  }

  /// Deletar conta
  Future<void> deletarConta() async {
    try {
      await _auth.currentUser?.delete();
      debugPrint('✅ Conta deletada com sucesso');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro ao deletar conta: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'requires-recent-login':
          throw Exception('Por segurança, faça login novamente antes de deletar sua conta.');
        default:
          throw Exception('Erro ao deletar conta: ${e.message ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      debugPrint('❌ Erro inesperado ao deletar conta: $e');
      throw Exception('Erro ao deletar conta.');
    }
  }
}

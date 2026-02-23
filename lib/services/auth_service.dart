import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:mailer/mailer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/smtp_server.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Configurações SMTP Brevo

final String _brevoSmtpHost = dotenv.env['SMTP_HOST'] ?? 'smtp-relay.brevo.com';
final int _brevoSmtpPort = int.parse(dotenv.env['SMTP_PORT'] ?? '587');
final String _brevoSmtpLogin = dotenv.env['SMTP_USERNAME'] ?? '';
final String _brevoSmtpPassword = dotenv.env['SMTP_PASSWORD'] ?? '';
  final String _remetenteEmail = 'noreply@notaok.com.br';
  final String _remetenteNome = 'NotaOK';

  // URL do backend de validação (você pode usar Cloud Functions ou seu próprio servidor)
  final String _validationBaseUrl = 'https://notaok.com.br/verify';

  /// Gera token seguro de 32 caracteres
  String _gerarTokenSeguro() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Cadastrar usuário com validação por email

  String _gerarCodigoVerificacao() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<bool> validarCodigo(String userId, String codigo) async {
    try {
      final userDoc = await _firestore.collection('usuarios').doc(userId).get();
      if (!userDoc.exists) return false;
      
      final data = userDoc.data()!;
      final codigoArmazenado = data['codigo_verificacao'] as String?;
      final expiracao = data['codigo_expiracao'] as int?;
      
      if (codigoArmazenado == null || expiracao == null) return false;
      if (DateTime.now().millisecondsSinceEpoch > expiracao) return false;
      if (codigo != codigoArmazenado) return false;
      
      await _firestore.collection('usuarios').doc(userId).update({
        'email_verificado': true,
        'codigo_verificacao': FieldValue.delete(),
        'codigo_expiracao': FieldValue.delete(),
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> reenviarCodigo(String email) async {
    final querySnapshot = await _firestore.collection('usuarios').where('email', isEqualTo: email).limit(1).get();
    if (querySnapshot.docs.isEmpty) throw Exception('Usuário não encontrado');
    
    final userDoc = querySnapshot.docs.first;
    final userId = userDoc.id;
    final nome = userDoc.data()['nome'] as String;
    final codigo = _gerarCodigoVerificacao();
    final expiracao = DateTime.now().add(Duration(minutes: 1));
    
    await _firestore.collection('usuarios').doc(userId).update({
      'codigo_verificacao': codigo,
      'codigo_expiracao': expiracao.millisecondsSinceEpoch,
    });
    
    await _enviarEmailValidacao(email, nome, codigo, userId);
  }



  


  


  Future<User?> cadastrarComEmail({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      developer.log('🚀 [CADASTRO] Iniciando cadastro para: $email');

      // 1. Criar usuário no Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception('Erro ao criar usuário no Firebase Auth');
      }

      developer.log('✅ [CADASTRO] Usuário criado no Firebase: ${user.uid}');

      // 2. Gerar token de validação
      final codigo = _gerarCodigoVerificacao();
      developer.log('🔑 [TOKEN] Gerado: $codigo...');

      // 3. Salvar dados no Firestore
      await _firestore.collection('usuarios').doc(user.uid).set({
        'nome': nome,
        'email': email,
        'email_verificado': false,
        'codigo_verificacao': codigo,
        'codigo_expiracao': DateTime.now().add(Duration(minutes: 1)).millisecondsSinceEpoch,
        'data_cadastro': FieldValue.serverTimestamp(),
      });

      developer.log('💾 [FIRESTORE] Dados salvos para UID: ${user.uid}');

      // 4. Enviar email com link de validação
      await _enviarEmailValidacao(email, nome, codigo, user.uid);

      developer.log('✅ [CADASTRO] Processo completo para: $email');
      return user;

    } catch (e, stackTrace) {
      developer.log('❌ [ERRO CADASTRO] $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Envia email de validação via Brevo API REST
  Future<void> _enviarEmailValidacao(String email, String nome, String codigo, String userId) async {
    try {
      developer.log('📧 [EMAIL SMTP] Enviando código para: $email');
      
      // Configurar servidor SMTP Brevo
      final smtpServer = SmtpServer(
        _brevoSmtpHost,
        port: _brevoSmtpPort,
        username: _brevoSmtpLogin,
        password: _brevoSmtpPassword,
      );

      // Criar mensagem HTML com CÓDIGO
      final message = Message()
        ..from = Address(_remetenteEmail, _remetenteNome)
        ..recipients.add(email)
        ..subject = '🔐 Seu Código de Verificação - NotaOK'
        ..html = """
<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center; border-radius: 10px 10px 0 0;">
    <h1 style="color: white; margin: 0;">✨ Bem-vindo ao NotaOK, $nome!</h1>
  </div>
  
  <div style="padding: 40px; background: white;">
    <p style="font-size: 16px; color: #333;">Olá, <strong>$nome</strong>! 👋</p>
    
    <p style="font-size: 15px; color: #666; line-height: 1.6;">
      Para garantir a segurança da sua conta, use o código abaixo no aplicativo:
    </p>

    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; padding: 30px; margin: 30px 0;">
      <p style="color: white; font-size: 14px; margin: 0 0 10px 0; text-align: center;">Seu Código de Verificação</p>
      <div style="background: white; border-radius: 8px; padding: 20px; text-align: center;">
        <span style="font-size: 48px; font-weight: 800; color: #667eea; letter-spacing: 8px; font-family: monospace;">
          $codigo
        </span>
      </div>
    </div>

    <div style="background: #f8f9fa; border-radius: 12px; padding: 20px; margin: 30px 0;">
      <p style="font-size: 16px; color: #495057; margin: 0 0 15px 0; font-weight: 600;">📱 Como usar:</p>
      <ol style="margin: 0; padding-left: 20px; color: #6c757d; font-size: 15px; line-height: 1.8;">
        <li>Abra o aplicativo NotaOK</li>
        <li>Vá para a tela de verificação</li>
        <li>Digite o código acima</li>
        <li>Pronto! Sua conta estará ativada ✅</li>
      </ol>
    </div>

    <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; border-radius: 5px;">
      <p style="margin: 0; color: #856404; font-size: 14px;">
        ⏰ <strong>Atenção:</strong> Este código expira em 10 minutos.
      </p>
    </div>
  </div>

  <div style="background: #f8f9fa; padding: 20px; text-align: center; border-radius: 0 0 10px 10px;">
    <p style="margin: 0; color: #6c757d; font-size: 13px;">
      © 2026 NotaOK. Todos os direitos reservados.
    </p>
  </div>
</body>
</html>
""";

      // Enviar email
      final sendReport = await send(message, smtpServer);
      developer.log('✅ [EMAIL SMTP] Enviado! ID: \${sendReport.toString()}');

    } catch (e, stackTrace) {
      developer.log('❌ [ERRO EMAIL SMTP] $e', error: e, stackTrace: stackTrace);
    }
  }

  /// Valida o token e marca o email como verificado
  Future<bool> validarToken(String token, String userId) async {
    try {
      developer.log('🔍 [VALIDAÇÃO] Validando token para UID: $userId');

      final userDoc = await _firestore.collection('usuarios').doc(userId).get();
      
      if (!userDoc.exists) {
        developer.log('❌ [VALIDAÇÃO] Usuário não encontrado');
        return false;
      }

      final data = userDoc.data()!;
      final tokenArmazenado = data['token_validacao'] as String?;
      final expiracao = data['token_expiracao'] as int?;

      if (tokenArmazenado == null || expiracao == null) {
        developer.log('❌ [VALIDAÇÃO] Token ou expiração não encontrados');
        return false;
      }

      // Verifica se o token está expirado
      if (DateTime.now().millisecondsSinceEpoch > expiracao) {
        developer.log('⏰ [VALIDAÇÃO] Token expirado');
        return false;
      }

      // Verifica se o token corresponde
      if (token != tokenArmazenado) {
        developer.log('🔐 [VALIDAÇÃO] Token inválido');
        return false;
      }

      // Marca como verificado
      await _firestore.collection('usuarios').doc(userId).update({
        'email_verificado': true,
        'data_validacao': FieldValue.serverTimestamp(),
        'token_validacao': FieldValue.delete(), // Remove o token usado
        'codigo_expiracao': FieldValue.delete(),
      });

      developer.log('✅ [VALIDAÇÃO] Email verificado com sucesso!');
      return true;

    } catch (e, stackTrace) {
      developer.log('❌ [ERRO VALIDAÇÃO] $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Login do usuário
  Future<User?> loginComEmail(String email, String senha) async {
    try {
      developer.log('🔑 [LOGIN] Tentando login para: $email');

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      // Verificar se o email está verificado no Firestore

      User? user = userCredential.user;
      if (user == null) {
        throw Exception('Usuário não encontrado');
      }

      // Verifica se o email foi verificado no Firestore
      final userDoc = await _firestore.collection('usuarios').doc(user.uid).get();
    
    // ✅ Verificar se documento existe
    if (!userDoc.exists) {
      developer.log('⚠️ [LOGIN] Documento não existe - criando...');
      await _firestore.collection('usuarios').doc(user.uid).set({
        'email': email,
        'email_verificado': false,
        'data_cadastro': FieldValue.serverTimestamp(),
      });
      developer.log('❌ [LOGIN] Email não verificado - cadastro pendente');
      await _auth.signOut();
      throw Exception('VERIFICACAO_PENDENTE|' + email + '|' + user.uid);
    }
    
    // ✅ Verificar se documento existe
    if (!userDoc.exists) {
      developer.log('❌ [LOGIN] Documento do usuário não existe no Firestore');
      // Criar documento básico
      await _firestore.collection('usuarios').doc(user.uid).set({
        'email': email,
        'email_verificado': false,
        'data_cadastro': FieldValue.serverTimestamp(),
      });
      throw Exception('VERIFICACAO_PENDENTE|' + email + '|' + user.uid);
    }
      final data = userDoc.data();
      developer.log('📊 [LOGIN DEBUG] Dados do Firestore: $data');
      final emailVerificado = data?['email_verificado'] ?? false;
      developer.log('📊 [LOGIN DEBUG] email_verificado = $emailVerificado');

      if (!emailVerificado) {
        developer.log('⚠️ [LOGIN] Email não verificado');
        await _auth.signOut();
        throw Exception('VERIFICACAO_PENDENTE|' + email + '|' + user.uid);
      }

      developer.log('✅ [LOGIN] Login bem-sucedido para: $email');
      return user;

    } catch (e, stackTrace) {
      developer.log('❌ [ERRO LOGIN] $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Usuário atual
  User? get usuarioAtual => _auth.currentUser;

  /// Stream de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> recuperarSenha(String email) async {
    try {
      developer.log('📧 [RECUPERAR SENHA] Iniciando para: $email');
      
      // Gerar código de recuperação
      final codigo = _gerarCodigoVerificacao();
      
      // Salvar código no Firestore (usar email como ID temporário)
      await _firestore.collection('recuperacao_senha').doc(email).set({
        'codigo': codigo,
        'expiracao': DateTime.now().add(Duration(minutes: 1)).millisecondsSinceEpoch,
        'usado': false,
      });
      
      // Enviar email de recuperação
      final smtpServer = SmtpServer(
        _brevoSmtpHost,
        port: _brevoSmtpPort,
        username: _brevoSmtpLogin,
        password: _brevoSmtpPassword,
      );

      final message = Message()
        ..from = Address(_brevoSmtpLogin, _remetenteNome)
        ..recipients.add(email)
        ..subject = 'Recuperação de Senha - NotaOK'
        ..html = """
<html>
<body style="font-family: Arial, sans-serif; padding: 20px;">
  <h2>Recuperação de Senha</h2>
  <p>Você solicitou a recuperação de senha.</p>
  <p>Use o código abaixo para criar uma nova senha:</p>
  <div style="background: #f5f5f5; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px;">
    $codigo
  </div>
  <p>Este código é válido por 1 hora.</p>
</body>
</html>
""";

      await send(message, smtpServer);
      developer.log('✅ [RECUPERAR SENHA] Email enviado');
      
    } catch (e, stackTrace) {
      developer.log('❌ [ERRO RECUPERAR SENHA] $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

}

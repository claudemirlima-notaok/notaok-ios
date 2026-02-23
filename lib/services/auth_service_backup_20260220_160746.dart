import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Configurações SMTP Brevo
  final String _brevoSmtpHost = 'smtp-relay.brevo.com';
  final int _brevoSmtpPort = 587;
  final String _brevoSmtpLogin = 'a2d962001@smtp-brevo.com';
  final String _brevoSmtpPassword = 'xsmtpsib-69983f7a36b73d3b9607f26487449ef95ff9cd9caf22b1b7abe24683131994d0-YUfpwFZ4wG2rvrKY';
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
      final token = _gerarTokenSeguro();
      developer.log('🔑 [TOKEN] Gerado: ${token.substring(0, 8)}...');

      // 3. Salvar dados no Firestore
      await _firestore.collection('usuarios').doc(user.uid).set({
        'nome': nome,
        'email': email,
        'email_verificado': false,
        'token_validacao': token,
        'token_expiracao': DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
        'data_cadastro': FieldValue.serverTimestamp(),
      });

      developer.log('💾 [FIRESTORE] Dados salvos para UID: ${user.uid}');

      // 4. Enviar email com link de validação
      await _enviarEmailValidacao(email, nome, token, user.uid);

      developer.log('✅ [CADASTRO] Processo completo para: $email');
      return user;

    } catch (e, stackTrace) {
      developer.log('❌ [ERRO CADASTRO] $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Envia email de validação via Brevo API REST
  Future<void> _enviarEmailValidacao(String email, String nome, String token, String userId) async {
    try {
      developer.log('📧 [EMAIL] Preparando envio para: $email');

      // Link de validação
      final linkValidacao = '$_validationBaseUrl?token=$token&uid=$userId';
      developer.log('🔗 [LINK] $linkValidacao');

      // Template HTML profissional
      final htmlContent = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Confirme seu Email - NotaOK</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 20px;">
    <tr>
      <td align="center">
        <table width="600" border="0" cellspacing="0" cellpadding="0" style="background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 20px 60px rgba(0,0,0,0.3);">
          
          <!-- Header -->
          <tr>
            <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center;">
              <h1 style="color: white; margin: 0; font-size: 32px; font-weight: 700;">✨ Bem-vindo ao NotaOK!</h1>
            </td>
          </tr>
          
          <!-- Content -->
          <tr>
            <td style="padding: 40px 30px;">
              <p style="font-size: 18px; color: #333; margin-bottom: 20px;">Olá, <strong>$nome</strong>! 👋</p>
              
              <p style="font-size: 16px; color: #666; line-height: 1.6; margin-bottom: 30px;">
                Estamos felizes em tê-lo conosco! Para garantir a segurança da sua conta, 
                precisamos verificar seu endereço de email.
              </p>

              <p style="font-size: 16px; color: #666; line-height: 1.6; margin-bottom: 30px;">
                Clique no botão abaixo para confirmar seu email e começar a usar o NotaOK:
              </p>

              <!-- Botão -->
              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td align="center" style="padding: 20px 0;">
                    <a href="$linkValidacao" 
                       style="display: inline-block; 
                              padding: 18px 50px; 
                              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                              color: white; 
                              text-decoration: none; 
                              border-radius: 50px; 
                              font-size: 18px; 
                              font-weight: 600;
                              box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
                              transition: transform 0.3s;">
                      ✅ Confirmar Email
                    </a>
                  </td>
                </tr>
              </table>

              <!-- Link alternativo -->
              <p style="font-size: 14px; color: #999; text-align: center; margin-top: 30px; line-height: 1.6;">
                Se o botão não funcionar, copie e cole este link no navegador:<br>
                <a href="$linkValidacao" style="color: #667eea; word-break: break-all;">$linkValidacao</a>
              </p>

              <!-- Aviso de expiração -->
              <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin-top: 30px; border-radius: 8px;">
                <p style="margin: 0; color: #856404; font-size: 14px;">
                  ⏰ <strong>Atenção:</strong> Este link expira em 24 horas.
                </p>
              </div>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background: #f8f9fa; padding: 30px; text-align: center; border-top: 1px solid #e9ecef;">
              <p style="margin: 0 0 10px 0; color: #6c757d; font-size: 14px;">
                © 2026 NotaOK. Todos os direitos reservados.
              </p>
              <p style="margin: 0; color: #adb5bd; font-size: 12px;">
                Se você não se cadastrou no NotaOK, ignore este email.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';

      // Chamada API REST Brevo
      final response = await http.post(
        Uri.parse('https://api.brevo.com/v3/smtp/email'),
        headers: {
          'accept': 'application/json',
          'api-key': _brevoSmtpPassword, // Usando a senha SMTP como API key
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'sender': {
            'name': _remetenteNome,
            'email': _remetenteEmail,
          },
          'to': [
            {
              'email': email,
              'name': nome,
            }
          ],
          'subject': '✅ Confirme seu Email - NotaOK',
          'htmlContent': htmlContent,
        }),
      );

      developer.log('📊 [BREVO] Status Code: ${response.statusCode}');
      developer.log('📄 [BREVO] Response: ${response.body}');

      if (response.statusCode == 201) {
        developer.log('✅ [EMAIL] Enviado com sucesso para: $email');
      } else {
        throw Exception('Falha ao enviar email: ${response.statusCode} - ${response.body}');
      }

    } catch (e, stackTrace) {
      developer.log('❌ [ERRO EMAIL] $e', error: e, stackTrace: stackTrace);
      // Não falhamos o cadastro se o email falhar
      developer.log('⚠️ [AVISO] Usuário criado, mas email não foi enviado');
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
        'token_expiracao': FieldValue.delete(),
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

      User? user = userCredential.user;
      if (user == null) {
        throw Exception('Usuário não encontrado');
      }

      // Verifica se o email foi verificado no Firestore
      final userDoc = await _firestore.collection('usuarios').doc(user.uid).get();
      final emailVerificado = userDoc.data()?['email_verificado'] ?? false;

      if (!emailVerificado) {
        developer.log('⚠️ [LOGIN] Email não verificado');
        await _auth.signOut();
        throw Exception('Por favor, verifique seu email antes de fazer login.');
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
}

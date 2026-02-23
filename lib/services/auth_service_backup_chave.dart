import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

/// AuthService com Brevo APENAS (sem email Firebase)
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Brevo API Config
  static const String _brevoApiKey = 'xsmtpsib-69983f7a36b73d3b9607f26487449ef95ff9cd9caf22b1b7abe24683131994d0-YUfpwFZ4wG2rvrKY';
  static const String _brevoApiUrl = 'https://api.brevo.com/v3/smtp/email';

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gerar código de 6 dígitos
  String _gerarCodigoVerificacao() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Cadastro com Email/Senha + Brevo APENAS
  Future<Map<String, dynamic>> cadastrarComEmail({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    required String telefone,
    String? dataNascimento,
  }) async {
    try {
      // 1. Criar usuário no Firebase Auth (SEM verificação)
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final User? user = userCredential.user;
      if (user == null) throw Exception('Erro ao criar usuário');

      // 2. Atualizar displayName
      await user.updateDisplayName(nome);

      // 3. Gerar código de 6 dígitos
      final codigoVerificacao = _gerarCodigoVerificacao();

      // 4. Salvar código no Firestore (expira em 10 minutos)
      await _firestore.collection('codigos_verificacao').doc(email).set({
        'codigo': codigoVerificacao,
        'userId': user.uid,
        'criadoEm': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch,
      });

      // 5. Salvar dados do usuário no Firestore
      await _firestore.collection('usuarios').doc(user.uid).set({
        'userId': user.uid,
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
        'dataNascimento': dataNascimento,
        'emailVerificado': false,
        'telefoneVerificado': false,
        'metodoLogin': 'email',
        'criadoEm': FieldValue.serverTimestamp(),
        'totalAberturas': 1,
        'ultimaAbertura': FieldValue.serverTimestamp(),
        'primeiroUsoCompleto': false,
      });

      // 6. Enviar APENAS email Brevo (HTML profissional)
      await _enviarEmailVerificacaoBrevo(email, nome, codigoVerificacao);

      return {
        'email': email,
        'userId': user.uid,
        'mensagem': 'Código enviado para $email',
      };
    } on FirebaseAuthException catch (e) {
      throw _traduzirErroAuth(e);
    } catch (e) {
      throw Exception('Erro ao cadastrar: $e');
    }
  }

  /// Verificar código de 6 dígitos
  Future<bool> verificarCodigoEmail(String email, String codigo) async {
    try {
      final doc = await _firestore.collection('codigos_verificacao').doc(email).get();
      
      if (!doc.exists) {
        throw Exception('Código não encontrado');
      }

      final data = doc.data()!;
      final codigoSalvo = data['codigo'] as String;
      final expiresAt = data['expiresAt'] as int;

      // Verificar se expirou
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        throw Exception('Código expirado');
      }

      // Verificar se código está correto
      if (codigo != codigoSalvo) {
        throw Exception('Código incorreto');
      }

      // Marcar email como verificado
      final userId = data['userId'] as String;
      await _firestore.collection('usuarios').doc(userId).update({
        'emailVerificado': true,
      });

      // Deletar código usado
      await _firestore.collection('codigos_verificacao').doc(email).delete();

      return true;
    } catch (e) {
      throw Exception('Erro ao verificar código: $e');
    }
  }

  /// Login com Email/Senha + Incrementa contador
  Future<Map<String, dynamic>> loginComEmail({
    required String email,
    required String senha,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final User? user = userCredential.user;
      if (user == null) throw Exception('Erro ao fazer login');

      // Incrementa contador de aberturas
      await incrementarTotalAberturas(user.uid);

      return {'email': email, 'userId': user.uid};
    } on FirebaseAuthException catch (e) {
      throw _traduzirErroAuth(e);
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// Login com Google + Incrementa contador
  Future<Map<String, dynamic>> loginComGoogle({
    required String cpf,
    required String telefone,
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Login cancelado');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) throw Exception('Erro ao autenticar com Google');

      final docSnapshot = await _firestore.collection('usuarios').doc(user.uid).get();
      final bool isNewUser = !docSnapshot.exists;

      if (isNewUser) {
        await _firestore.collection('usuarios').doc(user.uid).set({
          'userId': user.uid,
          'nome': user.displayName ?? 'Usuário Google',
          'email': user.email ?? '',
          'cpf': cpf,
          'telefone': telefone,
          'emailVerificado': true,
          'telefoneVerificado': false,
          'metodoLogin': 'google',
          'criadoEm': FieldValue.serverTimestamp(),
          'totalAberturas': 1,
          'ultimaAbertura': FieldValue.serverTimestamp(),
          'primeiroUsoCompleto': false,
        });
      } else {
        await incrementarTotalAberturas(user.uid);
      }

      return {'email': user.email ?? '', 'userId': user.uid};
    } catch (e) {
      throw Exception('Erro ao fazer login com Google: $e');
    }
  }

  /// Reenviar código de verificação
  Future<void> reenviarCodigoVerificacao(String email, String nome) async {
    final codigoVerificacao = _gerarCodigoVerificacao();

    // Salvar novo código
    await _firestore.collection('codigos_verificacao').doc(email).set({
      'codigo': codigoVerificacao,
      'criadoEm': FieldValue.serverTimestamp(),
      'expiresAt': DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch,
    }, SetOptions(merge: true));

    // Enviar email
    await _enviarEmailVerificacaoBrevo(email, nome, codigoVerificacao);
  }

  /// Recuperar senha via Brevo
  Future<void> recuperarSenha(String email) async {
    try {
      final response = await http.post(
        Uri.parse(_brevoApiUrl),
        headers: {
          'api-key': _brevoApiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'sender': {'name': 'NotaOK', 'email': 'noreply@notaok.com'},
          'to': [{'email': email}],
          'subject': 'Recuperação de Senha - NotaOK',
          'htmlContent': '''
            <html>
              <body style="font-family: Arial, sans-serif; padding: 20px; background-color: #f5f5f5;">
                <div style="max-width: 600px; margin: 0 auto; background-color: white; 
                            border-radius: 8px; padding: 32px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                  <h2 style="color: #9C27B0; margin-bottom: 24px;">Recuperação de Senha</h2>
                  <p style="font-size: 16px; color: #333;">Você solicitou a recuperação de senha.</p>
                  <p style="font-size: 16px; color: #333;">Clique no botão abaixo para redefinir sua senha:</p>
                  <div style="text-align: center; margin: 32px 0;">
                    <a href="https://notaok.com/reset-password" 
                       style="background-color: #FF6F00; color: white; padding: 16px 32px; 
                              text-decoration: none; border-radius: 8px; display: inline-block;
                              font-size: 16px; font-weight: bold;">
                      Redefinir Senha
                    </a>
                  </div>
                  <p style="margin-top: 24px; color: #666; font-size: 14px;">
                    Se você não solicitou esta recuperação, ignore este e-mail.
                  </p>
                  <hr style="border: none; border-top: 1px solid #e0e0e0; margin: 24px 0;">
                  <p style="color: #999; font-size: 12px; text-align: center;">
                    Equipe NotaOK
                  </p>
                </div>
              </body>
            </html>
          ''',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao enviar email: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao enviar email de recuperação: $e');
    }
  }

  /// Recarregar dados do usuário
  Future<void> recarregarUsuario() async {
    await _auth.currentUser?.reload();
  }

  /// Logout
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Excluir conta
  Future<void> excluirConta() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('usuarios').doc(user.uid).delete();
      await user.delete();
    }
  }

  /// Incrementa contador de aberturas do app
  Future<void> incrementarTotalAberturas(String userId) async {
    try {
      await _firestore.collection('usuarios').doc(userId).update({
        'totalAberturas': FieldValue.increment(1),
        'ultimaAbertura': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao incrementar contador: $e');
      }
    }
  }

  /// Enviar email de verificação via Brevo (HTML PROFISSIONAL)
  Future<void> _enviarEmailVerificacaoBrevo(String email, String nome, String codigo) async {
    try {
      print('🔵 [BREVO] Iniciando envio de email...');
      print('   Email: $email');
      print('   Código: $codigo');

      if (kDebugMode) {
        debugPrint('🔵 [BREVO] Iniciando envio de email...');
        debugPrint('   Email: $email');
        debugPrint('   Nome: $nome');
        debugPrint('   Código: $codigo');
      }

      final response = await http.post(
        Uri.parse(_brevoApiUrl),
        headers: {
          'api-key': _brevoApiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'sender': {'name': 'NotaOK', 'email': 'noreply@notaok.com'},
          'to': [{'email': email, 'name': nome}],
          'subject': '🔐 Seu código de verificação - NotaOK',
          'htmlContent': '''
            <html>
              <body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #f5f5f5;">
                <div style="max-width: 600px; margin: 40px auto; background-color: white; 
                            border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                  
                  <!-- Header com gradiente -->
                  <div style="background: linear-gradient(135deg, #9C27B0 0%, #673AB7 100%); 
                              padding: 32px; text-align: center;">
                    <h1 style="color: white; margin: 0; font-size: 28px; font-weight: bold;">
                      Bem-vindo ao NotaOK!
                    </h1>
                  </div>
                  
                  <!-- Conteúdo -->
                  <div style="padding: 40px 32px;">
                    <p style="font-size: 18px; color: #333; margin-bottom: 16px;">
                      Olá, <strong>$nome</strong>!
                    </p>
                    
                    <p style="font-size: 16px; color: #666; margin-bottom: 32px;">
                      Use o código abaixo para verificar seu e-mail:
                    </p>
                    
                    <!-- Código de verificação -->
                    <div style="background: linear-gradient(135deg, #FF6F00 0%, #FF9800 100%); 
                                border-radius: 12px; padding: 24px; text-align: center; 
                                margin: 32px 0; box-shadow: 0 4px 12px rgba(255, 111, 0, 0.3);">
                      <div style="font-size: 48px; font-weight: bold; color: white; 
                                  letter-spacing: 8px; font-family: 'Courier New', monospace;">
                        $codigo
                      </div>
                    </div>
                    
                    <div style="background-color: #FFF3E0; border-left: 4px solid #FF9800; 
                                padding: 16px; border-radius: 4px; margin: 24px 0;">
                      <p style="margin: 0; color: #E65100; font-size: 14px;">
                        ⏰ <strong>Este código expira em 10 minutos.</strong>
                      </p>
                    </div>
                    
                    <p style="font-size: 14px; color: #999; margin-top: 32px;">
                      Se você não solicitou este código, ignore este e-mail.
                    </p>
                  </div>
                  
                  <!-- Footer -->
                  <div style="background-color: #f5f5f5; padding: 24px 32px; 
                              border-top: 1px solid #e0e0e0; text-align: center;">
                    <p style="margin: 0; color: #999; font-size: 12px;">
                      © 2025 NotaOK. Todos os direitos reservados.
                    </p>
                  </div>
                  
                </div>
              </body>
            </html>
          ''',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao enviar email: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [BREVO] ERRO ao enviar email: $e');
        debugPrint('❌ [BREVO] Stack trace: ${StackTrace.current}');
      }
      throw Exception('Erro ao enviar email de verificação: $e');

    }
  }

  /// Traduzir erros do Firebase Auth
  String _traduzirErroAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'weak-password':
        return 'Senha muito fraca.';
      case 'user-disabled':
        return 'Usuário desabilitado.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}

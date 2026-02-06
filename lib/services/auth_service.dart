import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import 'hive_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream de mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  User? get currentUser => _auth.currentUser;

  // Verifica se o usuário está logado
  bool get isLoggedIn => currentUser != null;

  // 1. CADASTRO POR EMAIL (com validação de email e CPF)
  Future<Usuario?> cadastrarComEmail({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    required String telefone,
    String? dataNascimento,
  }) async {
    try {
      // Valida CPF antes de cadastrar
      if (!Usuario.validarCPF(cpf)) {
        throw Exception('CPF inválido');
      }

      // Remove formatação do CPF
      final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');

      // Verifica se CPF já está cadastrado
      final cpfExiste = await _verificarCPFExistente(cpfLimpo);
      if (cpfExiste) {
        throw Exception('CPF já cadastrado');
      }

      // Cria usuário no Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Envia email de verificação
      await userCredential.user?.sendEmailVerification();

      // Cria objeto Usuario
      final usuario = Usuario(
        id: userCredential.user!.uid,
        nome: nome,
        email: email,
        cpf: cpfLimpo,
        telefone: telefone,
        dataNascimento: dataNascimento,
        tipoLogin: 'email',
        emailVerificado: false,
      );

      // Salva no Firestore
      await _salvarUsuarioFirestore(usuario);

      // Salva localmente no Hive
      await HiveService.salvarUsuario(usuario);

      if (kDebugMode) {
        debugPrint('✅ Usuário cadastrado com sucesso: ${usuario.email}');
        debugPrint('📧 Email de verificação enviado');
      }

      return usuario;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao cadastrar: ${e.code}');
      }
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email já está em uso');
        case 'weak-password':
          throw Exception('Senha muito fraca. Use no mínimo 6 caracteres');
        case 'invalid-email':
          throw Exception('Email inválido');
        default:
          throw Exception('Erro ao cadastrar: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao cadastrar: $e');
      }
      rethrow;
    }
  }

  // 2. LOGIN COM EMAIL
  Future<Usuario?> loginComEmail({
    required String email,
    required String senha,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Busca dados do usuário no Firestore
      final usuario = await _buscarUsuarioFirestore(userCredential.user!.uid);

      if (usuario != null) {
        // Salva localmente
        await HiveService.salvarUsuario(usuario);
      }

      if (kDebugMode) {
        debugPrint('✅ Login realizado com sucesso');
      }

      return usuario;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao fazer login: ${e.code}');
      }
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Usuário não encontrado');
        case 'wrong-password':
          throw Exception('Senha incorreta');
        case 'invalid-email':
          throw Exception('Email inválido');
        case 'user-disabled':
          throw Exception('Usuário desabilitado');
        default:
          throw Exception('Erro ao fazer login: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao fazer login: $e');
      }
      rethrow;
    }
  }

  // 3. LOGIN COM GOOGLE
  Future<Usuario?> loginComGoogle({
    required String cpf,
    required String telefone,
  }) async {
    try {
      // Valida CPF
      if (!Usuario.validarCPF(cpf)) {
        throw Exception('CPF inválido');
      }

      final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');

      // Faz login com Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Login com Google cancelado');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Verifica se é primeiro login
      Usuario? usuario = await _buscarUsuarioFirestore(userCredential.user!.uid);

      if (usuario == null) {
        // Primeiro login - criar perfil
        usuario = Usuario(
          id: userCredential.user!.uid,
          nome: userCredential.user!.displayName ?? 'Usuário Google',
          email: userCredential.user!.email ?? '',
          cpf: cpfLimpo,
          telefone: telefone,
          foto: userCredential.user!.photoURL,
          tipoLogin: 'google',
          emailVerificado: true,
        );

        await _salvarUsuarioFirestore(usuario);
      }

      // Salva localmente
      await HiveService.salvarUsuario(usuario);

      if (kDebugMode) {
        debugPrint('✅ Login com Google realizado com sucesso');
      }

      return usuario;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro no login com Google: $e');
      }
      rethrow;
    }
  }

  // 4. REENVIAR EMAIL DE VERIFICAÇÃO
  Future<void> reenviarEmailVerificacao() async {
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (kDebugMode) {
          debugPrint('📧 Email de verificação reenviado');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao reenviar email: $e');
      }
      rethrow;
    }
  }

  // 5. RECUPERAR SENHA
  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        debugPrint('📧 Email de recuperação enviado');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao recuperar senha: ${e.code}');
      }
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Usuário não encontrado');
        case 'invalid-email':
          throw Exception('Email inválido');
        default:
          throw Exception('Erro ao recuperar senha: ${e.message}');
      }
    }
  }

  // 6. LOGOUT
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await HiveService.limparUsuario();
      if (kDebugMode) {
        debugPrint('✅ Logout realizado com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao fazer logout: $e');
      }
      rethrow;
    }
  }

  // 7. ATUALIZAR DADOS DO USUÁRIO
  Future<void> atualizarUsuario(Usuario usuario) async {
    try {
      usuario.ultimaAtualizacao = DateTime.now();
      
      // Atualiza no Firestore
      await _salvarUsuarioFirestore(usuario);
      
      // Atualiza localmente
      await HiveService.salvarUsuario(usuario);

      if (kDebugMode) {
        debugPrint('✅ Usuário atualizado com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao atualizar usuário: $e');
      }
      rethrow;
    }
  }

  // MÉTODOS AUXILIARES PRIVADOS

  // Verifica se CPF já existe
  Future<bool> _verificarCPFExistente(String cpf) async {
    try {
      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('cpf', isEqualTo: cpf)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao verificar CPF: $e');
      }
      return false;
    }
  }

  // Salva usuário no Firestore
  Future<void> _salvarUsuarioFirestore(Usuario usuario) async {
    try {
      await _firestore
          .collection('usuarios')
          .doc(usuario.id)
          .set(usuario.toMap());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao salvar no Firestore: $e');
      }
      rethrow;
    }
  }

  // Busca usuário no Firestore
  Future<Usuario?> _buscarUsuarioFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return Usuario.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao buscar usuário: $e');
      }
      return null;
    }
  }

  // Busca usuário atual
  Future<Usuario?> buscarUsuarioAtual() async {
    if (!isLoggedIn) return null;
    
    // Tenta buscar localmente primeiro
    Usuario? usuario = HiveService.getUsuarioAtual();
    
    // Se não encontrar localmente, busca no Firestore
    if (usuario == null && currentUser != null) {
      usuario = await _buscarUsuarioFirestore(currentUser!.uid);
      if (usuario != null) {
        await HiveService.salvarUsuario(usuario);
      }
    }
    
    return usuario;
  }
}

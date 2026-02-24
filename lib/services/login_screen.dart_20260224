import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';
import 'email_verification_screen.dart';
import 'phone_verification_screen.dart';
import 'password_reset_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // 🧪 DADOS DE TESTE
    {
      _nomeController.text = 'Claudemir Lima';
      _cpfController.text = '154.667.848-42';
      _telefoneController.text = '(19) 98282-8291';
      _emailController.text = 'claudemir.lima@gmail.com';
      _senhaController.text = 'teste123';
    }
  }
  final _dataNascimentoController = TextEditingController();

  @override

  /// Trata mensagens de erro do Firebase Auth
  String _tratarErroLogin(dynamic e) {
    final erro = e.toString().toLowerCase();
    
    if (erro.contains('verifique seu email') || erro.contains('não verificado') || erro.contains('not verified')) {
      return '📧 Email não verificado. Verifique seu email antes de fazer login.';
    } else if (erro.contains('invalid-credential') || erro.contains('wrong-password')) {
      return '❌ Email ou senha incorretos';
    } else if (erro.contains('user-not-found')) {
      return '❌ Usuário não encontrado';
    } else if (erro.contains('invalid-email')) {
      return '❌ Email inválido';
    } else if (erro.contains('user-disabled')) {
      return '❌ Conta desativada';
    } else if (erro.contains('too-many-requests')) {
      return '❌ Muitas tentativas. Aguarde.';
    } else if (erro.contains('network')) {
      return '❌ Erro de conexão';
    } else {
      return '❌ Erro ao fazer login';
    }
  }

  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  TextInputFormatter cpfFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 11) return oldValue;
    
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  });

  TextInputFormatter telefoneFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 11) return oldValue;
    
    String formatted = '';
    if (text.isNotEmpty) {
      formatted = '(';
      for (int i = 0; i < text.length; i++) {
        if (i == 2) formatted += ') ';
        if (i == 7) formatted += '-';
        formatted += text[i];
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  });

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final usuario = await _authService.loginComEmail(
          _emailController.text.trim(),
          _senhaController.text,
        );

        if (usuario != null && mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        final usuario = await _authService.cadastrarComEmail(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text,
        );

        if (usuario != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(
                email: usuario.email ?? '',
                userId: usuario.uid,
              ),
            ),
          );
        }
      }
    } catch (e) {
      
      // ✅ Verificar se email precisa ser validado
      final erroStr = e.toString();
      if (erroStr.contains('VERIFICACAO_PENDENTE')) {
        final partes = erroStr.split('|');
        final email = partes.length > 1 ? partes[1] : _emailController.text.trim();
        final uid = partes.length > 2 ? partes[2] : '';
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(
                email: email,
                userId: uid,
              ),
            ),
          );
        }
        return;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tratarErroLogin(e)),
            backgroundColor: Colors.red,
          ),
        );
        
        // Redirecionar para tela de verificação de email
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(
              '/email-verification',
              arguments: {'email': _emailController.text.trim()},
            );
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _mostrarDialogRecuperarSenha() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite um email válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
    
    try {
      await _authService.recuperarSenha(email);
      
      if (!mounted) return;
      Navigator.of(context).pop();
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PasswordResetScreen(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _mostrarDialogRecuperarSenha_OLD() async {
    final emailController = TextEditingController(text: _emailController.text.trim());
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Senha'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, digite um email válido'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              try {
                await _authService.recuperarSenha(email);
                
                if (!mounted) return;
                
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PasswordResetScreen(email: email),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao enviar email: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }


  Future<void> _loginComGoogle() async {
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Fazer login com Google PRIMEIRO
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // Usuário cancelou
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 2️⃣ Autenticar no Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Falha na autenticação com Google');
      }

      // 3️⃣ ✅ CORRIGIDO: Verificar se usuário JÁ TEM dados antes de pedir
      final userDoc = await _firestore.collection('usuarios').doc(userCredential.user!.uid).get();
      
      if (userDoc.exists && userDoc.data()?['cpf'] != null) {
        // ✅ Usuário já tem dados - ir direto para home
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        return;
      }
      
      // 4️⃣ ❌ Primeira vez - pedir CPF e telefone AGORA
      setState(() => _isLoading = false);
      
      final cpfTelefone = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) => _DadosComplementaresDialog(),
      );
      
      if (cpfTelefone == null) {
        // Usuário cancelou - fazer logout
        await FirebaseAuth.instance.signOut();
        return;
      }

      setState(() => _isLoading = true);

      // 5️⃣ Salvar dados no Firestore
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': userCredential.user!.displayName ?? googleUser.displayName ?? 'Usuário Google',
        'email': userCredential.user!.email ?? googleUser.email,
        'cpf': cpfTelefone['cpf']!,
        'telefone': cpfTelefone['telefone']!,
        'criadoEm': FieldValue.serverTimestamp(),
        'emailVerificado': true,
        'metodoLogin': 'google',
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro no login com Google: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginComApple() async {
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Solicita credenciais do Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2️⃣ Cria credencial OAuth para Firebase
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3️⃣ Autentica no Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Falha na autenticação com Apple');
      }

      setState(() => _isLoading = false);

      // 4️⃣ ✅ NOVO: Pedir CPF e telefone (igual Google!)
      
      // 4️⃣ ✅ CORRIGIDO: Verificar se usuário JÁ TEM dados antes de pedir
      final userDoc = await _firestore.collection('usuarios').doc(userCredential.user!.uid).get();
      
      if (userDoc.exists && userDoc.data()?['cpf'] != null) {
        // ✅ Usuário já tem dados - ir direto para home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        return;
      }
      
      // ❌ Primeira vez - pedir CPF e telefone
      if (mounted) {
        final cpfTelefone = await showDialog<Map<String, String>>(
          context: context,
          builder: (context) => _DadosComplementaresDialog(),
        );

        if (cpfTelefone == null) {
          // Usuário cancelou - fazer logout
          await FirebaseAuth.instance.signOut();
          return;
        }

        setState(() => _isLoading = true);

        // 5️⃣ Salvar dados complementares no Firestore
        await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
          'nome': userCredential.user!.displayName ?? 
                  '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim(),
          'email': userCredential.user!.email ?? 'apple_user@notaok.com',
          'cpf': cpfTelefone['cpf']!,
          'telefone': cpfTelefone['telefone']!,
          'criadoEm': FieldValue.serverTimestamp(),
          'emailVerificado': true,
          'metodoLogin': 'apple',
        }, SetOptions(merge: true));

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro no login com Apple: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loginComTelefone() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PhoneVerificationScreen(phoneNumber: "+5511999999999"),
      ),
    );
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
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/logos/logo_notaok_final.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'NotaOK',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Comprou? Tá OK!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildToggleButton('Login', _isLogin),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildToggleButton('Cadastro', !_isLogin),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          if (!_isLogin) ...[
                            _buildTextField(
                              controller: _nomeController,
                              label: 'Nome Completo',
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite seu nome';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _cpfController,
                              label: 'CPF',
                              icon: Icons.badge,
                              keyboardType: TextInputType.number,
                              inputFormatters: [cpfFormatter],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite seu CPF';
                                }
                                if (!Usuario.validarCPF(value)) {
                                  return 'CPF inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _telefoneController,
                              label: 'Telefone',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [telefoneFormatter],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite seu telefone';
                                }
                                final telefone = value.replaceAll(RegExp(r'[^0-9]'), '');
                                if (telefone.length != 11) {
                                  return 'Telefone inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite seu email';
                              }
                              if (!value.contains('@')) {
                                return 'Email inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _senhaController,
                            label: 'Senha',
                            icon: Icons.lock,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite sua senha';
                              }
                              if (value.length < 6) {
                                return 'Senha deve ter no mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
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
                                : Text(
                                    _isLogin ? 'Entrar' : 'Cadastrar',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),

                          if (_isLogin) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _mostrarDialogRecuperarSenha,
                              child: const Text('Esqueci minha senha'),
                            ),
                          ],

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('OU'),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                          ),

                          _buildSocialButton(
                            label: 'Continuar com Telefone',
                            icon: Icons.phone_android,
                            color: const Color(0xFF34C759),
                            onPressed: _loginComTelefone,
                          ),
                          const SizedBox(height: 12),

                          _buildSocialButton(
                            label: 'Continuar com Google',
                            icon: Icons.g_mobiledata,
                            color: const Color(0xFF4285F4),
                            onPressed: _loginComGoogle,
                          ),
                          const SizedBox(height: 12),
                          _buildSocialButton(
                            label: 'Continuar com Apple',
                            icon: Icons.apple,
                            color: Colors.black,
                            onPressed: _loginComApple,
                          ),
                        ],
                      ),
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

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: _toggleMode,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: const TextStyle(color: Colors.black87),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}

class _DadosComplementaresDialog extends StatefulWidget {
  @override
  State<_DadosComplementaresDialog> createState() => _DadosComplementaresDialogState();
}

class _DadosComplementaresDialogState extends State<_DadosComplementaresDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dados Obrigatórios'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Para completar seu cadastro, precisamos de algumas informações:'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cpfController,
              decoration: const InputDecoration(
                labelText: 'CPF',
                hintText: '000.000.000-00',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite seu CPF';
                }
                if (!Usuario.validarCPF(value)) {
                  return 'CPF inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                hintText: '(00) 00000-0000',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite seu telefone';
                }
                final telefone = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (telefone.length != 11) {
                  return 'Telefone inválido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'cpf': _cpfController.text,
                'telefone': _telefoneController.text,
              });
            }
          },
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}

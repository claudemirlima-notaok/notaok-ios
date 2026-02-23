  // ✅ FLUXO CORRETO: CPF/Telefone ANTES da validação Apple
  Future<void> _loginComApple() async {
    // 1️⃣ PRIMEIRO: Pedir CPF e Telefone (ANTES de validar Apple)
    final cpfTelefone = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false, // Não pode cancelar clicando fora
      builder: (context) => _DadosComplementaresDialog(
        titulo: 'Login com Apple',
        mensagem: 'Para continuar com Apple, precisamos de:',
      ),
    );

    if (cpfTelefone == null) {
      // Usuário cancelou - não prossegue
      return;
    }

    // 2️⃣ AGORA: Validar com Apple (depois de ter CPF/Telefone)
    setState(() => _isLoading = true);

    try {
      // Solicita credenciais do Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Cria credencial OAuth para Firebase
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Autentica no Firebase
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Falha na autenticação com Apple');
      }

      // 3️⃣ Verificar se usuário já existe no Firestore
      final userDoc = await _firestore.collection('usuarios').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        // Usuário já existe - atualizar apenas ultima abertura
        await _firestore.collection('usuarios').doc(userCredential.user!.uid).update({
          'ultimaAbertura': FieldValue.serverTimestamp(),
          'totalAberturas': FieldValue.increment(1),
        });
      } else {
        // Usuário novo - salvar dados completos
        await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
          'userId': userCredential.user!.uid,
          'nome': userCredential.user!.displayName ?? 
                  '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim(),
          'email': userCredential.user!.email ?? appleCredential.email ?? 'apple_user@notaok.com',
          'cpf': cpfTelefone['cpf']!,
          'telefone': cpfTelefone['telefone']!,
          'emailVerificado': true,
          'telefoneVerificado': false,
          'metodoLogin': 'apple',
          'criadoEm': FieldValue.serverTimestamp(),
          'totalAberturas': 1,
          'ultimaAbertura': FieldValue.serverTimestamp(),
          'primeiroUsoCompleto': false,
        });
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }

    } catch (e) {
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

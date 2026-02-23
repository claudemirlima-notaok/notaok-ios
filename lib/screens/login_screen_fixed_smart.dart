  // ✅ LOGIN COM GOOGLE - INTELIGENTE (só pede CPF/Tel se não tiver)
  Future<void> _loginComGoogle() async {
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Autenticação Google PRIMEIRO
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // Usuário cancelou
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user == null) {
        throw Exception('Erro ao autenticar com Google');
      }

      // 2️⃣ Verificar se usuário JÁ TEM dados no Firestore
      final docSnapshot = await _firestore.collection('usuarios').doc(user.uid).get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        final cpf = userData['cpf'] as String?;
        final telefone = userData['telefone'] as String?;

        // 🎯 SE JÁ TEM CPF E TELEFONE → ENTRA DIRETO!
        if (cpf != null && cpf.isNotEmpty && telefone != null && telefone.isNotEmpty) {
          // Apenas incrementa contador
          await _firestore.collection('usuarios').doc(user.uid).update({
            'ultimaAbertura': FieldValue.serverTimestamp(),
            'totalAberturas': FieldValue.increment(1),
          });

          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
          return; // ✅ ACABOU AQUI!
        }
      }

      // 3️⃣ SE CHEGOU AQUI: NÃO TEM DADOS → PEDIR CPF/TELEFONE
      setState(() => _isLoading = false);

      if (mounted) {
        final cpfTelefone = await showDialog<Map<String, String>>(
          context: context,
          barrierDismissible: false,
          builder: (context) => _DadosComplementaresDialog(
            titulo: 'Complete seu cadastro',
            mensagem: 'Para continuar, precisamos de:',
          ),
        );

        if (cpfTelefone == null) {
          // Usuário cancelou - fazer logout
          await FirebaseAuth.instance.signOut();
          await _googleSignIn.signOut();
          return;
        }

        setState(() => _isLoading = true);

        // 4️⃣ Salvar dados no Firestore
        await _firestore.collection('usuarios').doc(user.uid).set({
          'userId': user.uid,
          'nome': user.displayName ?? 'Usuário Google',
          'email': user.email ?? '',
          'cpf': cpfTelefone['cpf']!,
          'telefone': cpfTelefone['telefone']!,
          'emailVerificado': true,
          'telefoneVerificado': false,
          'metodoLogin': 'google',
          'criadoEm': FieldValue.serverTimestamp(),
          'totalAberturas': 1,
          'ultimaAbertura': FieldValue.serverTimestamp(),
          'primeiroUsoCompleto': false,
        });

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString()}'),
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

  // ✅ LOGIN COM APPLE - INTELIGENTE (só pede CPF/Tel se não tiver)
  Future<void> _loginComApple() async {
    setState(() => _isLoading = true);

    try {
      // 1️⃣ Autenticação Apple PRIMEIRO
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Falha na autenticação com Apple');
      }

      final user = userCredential.user!;

      // 2️⃣ Verificar se usuário JÁ TEM dados no Firestore
      final docSnapshot = await _firestore.collection('usuarios').doc(user.uid).get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        final cpf = userData['cpf'] as String?;
        final telefone = userData['telefone'] as String?;

        // 🎯 SE JÁ TEM CPF E TELEFONE → ENTRA DIRETO!
        if (cpf != null && cpf.isNotEmpty && telefone != null && telefone.isNotEmpty) {
          // Apenas incrementa contador
          await _firestore.collection('usuarios').doc(user.uid).update({
            'ultimaAbertura': FieldValue.serverTimestamp(),
            'totalAberturas': FieldValue.increment(1),
          });

          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
          return; // ✅ ACABOU AQUI!
        }
      }

      // 3️⃣ SE CHEGOU AQUI: NÃO TEM DADOS → PEDIR CPF/TELEFONE
      setState(() => _isLoading = false);

      if (mounted) {
        final cpfTelefone = await showDialog<Map<String, String>>(
          context: context,
          barrierDismissible: false,
          builder: (context) => _DadosComplementaresDialog(
            titulo: 'Complete seu cadastro',
            mensagem: 'Para continuar com Apple, precisamos de:',
          ),
        );

        if (cpfTelefone == null) {
          // Usuário cancelou - fazer logout
          await FirebaseAuth.instance.signOut();
          return;
        }

        setState(() => _isLoading = true);

        // 4️⃣ Salvar dados no Firestore
        await _firestore.collection('usuarios').doc(user.uid).set({
          'userId': user.uid,
          'nome': user.displayName ?? 
                  '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim(),
          'email': user.email ?? appleCredential.email ?? 'apple_user@notaok.com',
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

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
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

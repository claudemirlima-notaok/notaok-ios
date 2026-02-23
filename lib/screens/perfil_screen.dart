import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _versaoApp = '';
  bool _isLoading = true;
  
  // ✅ Dados reais do usuário
  String _nomeUsuario = 'Carregando...';
  String _emailUsuario = '';
  String? _cpfUsuario;
  String? _telefoneUsuario;
  String? _fotoUrl;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);

    try {
      // Carrega versão do app
      final packageInfo = await PackageInfo.fromPlatform();
      _versaoApp = '${packageInfo.version} (${packageInfo.buildNumber})';

      // ✅ Carrega dados reais do Firebase
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        _emailUsuario = user.email ?? '';
        _fotoUrl = user.photoURL;
        
        // Nome do Firebase Auth (Google/Apple)
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _nomeUsuario = user.displayName!;
        }

        // Buscar dados adicionais no Firestore
        try {
          final doc = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .get();

          if (doc.exists) {
            final data = doc.data()!;
            
            // Priorizar nome do Firestore
            if (data['nome'] != null && data['nome'].toString().isNotEmpty) {
              _nomeUsuario = data['nome'];
            }
            
            _cpfUsuario = data['cpf'];
            _telefoneUsuario = data['telefone'];
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao buscar dados do Firestore: $e');
        }

        // Se ainda não tem nome, usar email
        if (_nomeUsuario == 'Carregando...' || _nomeUsuario.isEmpty) {
          _nomeUsuario = _emailUsuario.split('@')[0];
        }
      } else {
        // Usuário não logado (modo visitante)
        _nomeUsuario = 'Visitante';
        _emailUsuario = 'Modo visitante';
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados: $e');
      _versaoApp = '1.0.0';
      _nomeUsuario = 'Usuário';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    final isVisitante = user == null || user.isAnonymous;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar com gradiente e foto
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Foto do perfil
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: _fotoUrl != null ? NetworkImage(_fotoUrl!) : null,
                        child: _fotoUrl == null
                            ? Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      // Nome real do usuário
                      Text(
                        _nomeUsuario,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Email real do usuário
                      Text(
                        _emailUsuario,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Modo Visitante (se aplicável)
                  if (isVisitante) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Modo Visitante - Faça login para salvar seus dados',
                              style: TextStyle(color: Colors.orange[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fazerLogin,
                      icon: const Icon(Icons.login),
                      label: const Text('Fazer Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Seção: Meus Dados
                  _buildSectionTitle('Meus Dados'),
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Dados Pessoais',
                    subtitle: _cpfUsuario != null 
                        ? 'CPF: $_cpfUsuario'
                        : 'Nome, CPF, telefone',
                    onTap: () {
                      _mostrarDadosPessoais();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Endereços',
                    subtitle: '0 endereço(s)',
                    onTap: () {
                      _mostrarEmBreve('Gerenciamento de endereços');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Seção: Configurações
                  _buildSectionTitle('Configurações'),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Notificações',
                    subtitle: 'Alertas de garantias',
                    onTap: () {
                      _mostrarEmBreve('Configurações de notificações');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.lock,
                    title: 'Segurança e Privacidade',
                    subtitle: 'Senha, dados pessoais',
                    onTap: () {
                      _mostrarEmBreve('Configurações de segurança');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Seção: Suporte
                  _buildSectionTitle('Suporte'),
                  _buildMenuItem(
                    icon: Icons.chat_bubble,
                    title: 'Fale com o NotaOK',
                    subtitle: 'Envie suas dúvidas',
                    onTap: () {
                      _abrirFaleConosco();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info,
                    title: 'Sobre Nós',
                    subtitle: 'Conheça o NotaOK',
                    onTap: () {
                      _mostrarSobreNos();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.star,
                    title: 'Avaliar App',
                    subtitle: 'Deixe sua avaliação',
                    onTap: () {
                      _mostrarEmBreve('Avaliação do app');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.share,
                    title: 'Compartilhar App',
                    subtitle: 'Convide seus amigos',
                    onTap: () {
                      _mostrarEmBreve('Compartilhamento');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Seção: Informações
                  _buildSectionTitle('Informações'),
                  _buildMenuItem(
                    icon: Icons.description,
                    title: 'Termos de Uso',
                    onTap: () {
                      _mostrarEmBreve('Termos de uso');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.privacy_tip,
                    title: 'Política de Privacidade',
                    onTap: () {
                      _mostrarEmBreve('Política de privacidade');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Versão do App',
                    subtitle: _versaoApp,
                    trailing: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // Botão Sair (se logado)
                  if (!isVisitante) ...[
                    OutlinedButton.icon(
                      onPressed: _fazerLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair da Conta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _mostrarDadosPessoais() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dados Pessoais'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDadoItem('Nome', _nomeUsuario),
              _buildDadoItem('Email', _emailUsuario),
              if (_cpfUsuario != null) _buildDadoItem('CPF', _cpfUsuario!),
              if (_telefoneUsuario != null) _buildDadoItem('Telefone', _telefoneUsuario!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDadoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _mostrarEmBreve(String funcionalidade) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$funcionalidade em breve!'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _fazerLogin() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _fazerLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await AuthService().logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao sair: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _abrirFaleConosco() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fale com o NotaOK'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Entre em contato conosco:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('contato@notaok.com.br'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('WhatsApp'),
              subtitle: const Text('(11) 99999-9999'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _mostrarSobreNos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Color(0xFF9C27B0)),
            SizedBox(width: 12),
            Text('NotaOK'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Comprou? Tá OK!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'O NotaOK é seu assistente pessoal para gerenciar garantias, '
                'notas fiscais e comprovantes de compra.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Funcionalidades:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Controle de garantias com notificações'),
              const Text('• Scanner de QR Code de notas fiscais'),
              const Text('• Arquivamento digital de documentos'),
              const Text('• Sistema de avaliações de compras'),
              const Text('• OCR de comprovantes de cartão'),
              const SizedBox(height: 16),
              Text(
                'Versão: $_versaoApp',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

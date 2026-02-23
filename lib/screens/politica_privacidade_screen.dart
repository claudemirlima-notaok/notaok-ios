import 'package:flutter/material.dart';

class PoliticaPrivacidadeScreen extends StatelessWidget {
  const PoliticaPrivacidadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Política de Privacidade - NotaOK',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última atualização: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Informações Coletadas',
              'O NotaOK coleta:\n\n'
              '• Dados de cadastro (nome, email, telefone)\n'
              '• Informações de notas fiscais escaneadas\n'
              '• Fotos de comprovantes (armazenadas localmente)\n'
              '• Dados de produtos cadastrados\n'
              '• Informações de uso do aplicativo',
            ),
            _buildSection(
              '2. Como Usamos Seus Dados',
              'Utilizamos suas informações para:\n\n'
              '• Gerenciar suas garantias e notas fiscais\n'
              '• Enviar notificações de vencimento\n'
              '• Melhorar a experiência do usuário\n'
              '• Fornecer suporte técnico\n'
              '• Analisar estatísticas de uso (anônimas)',
            ),
            _buildSection(
              '3. Armazenamento e Segurança',
              'Seus dados são armazenados:\n\n'
              '• Firebase Cloud Firestore (dados estruturados)\n'
              '• Firebase Storage (imagens de comprovantes)\n'
              '• Armazenamento local do dispositivo (cache)\n\n'
              'Utilizamos criptografia e medidas de segurança do Firebase.',
            ),
            _buildSection(
              '4. Compartilhamento de Dados',
              'Não compartilhamos seus dados pessoais com terceiros, exceto:\n\n'
              '• Quando exigido por lei\n'
              '• Com seu consentimento explícito\n'
              '• Serviços essenciais (Firebase/Google)',
            ),
            _buildSection(
              '5. Seus Direitos',
              'Você tem direito a:\n\n'
              '• Acessar seus dados\n'
              '• Corrigir informações incorretas\n'
              '• Solicitar exclusão da conta\n'
              '• Exportar seus dados\n'
              '• Revogar consentimentos',
            ),
            _buildSection(
              '6. Cookies e Tecnologias',
              'Utilizamos:\n\n'
              '• Firebase Analytics (análise de uso)\n'
              '• Armazenamento local (cache do app)\n'
              '• Notificações push (lembretes)',
            ),
            _buildSection(
              '7. Requisitos Técnicos',
              'Para funcionar corretamente, o NotaOK requer:\n\n'
              '• iOS 16.0 ou superior\n'
              '• Permissões de câmera (scanner)\n'
              '• Permissões de galeria (comprovantes)\n'
              '• Conexão com Internet (sincronização)',
            ),
            _buildSection(
              '8. Contato',
              'Para exercer seus direitos ou tirar dúvidas:\n\n'
              'Email: privacidade@notaok.com.br\n'
              'Responderemos em até 48 horas úteis.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

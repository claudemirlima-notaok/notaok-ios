import 'package:flutter/material.dart';

class TermosUsoScreen extends StatelessWidget {
  const TermosUsoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Uso'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Termos de Uso - NotaOK',
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
              '1. Requisitos do Sistema',
              'Para utilizar o NotaOK, você precisa:\n\n'
              '• Dispositivo iOS com versão 16.0 ou superior\n'
              '• Conexão com a Internet (recomendado)\n'
              '• Permissões de câmera para scanner QR Code\n'
              '• Permissões de galeria para upload de comprovantes\n\n'
              'O app pode não funcionar corretamente em versões anteriores do iOS.',
            ),
            _buildSection(
              '2. Aceitação dos Termos',
              'Ao usar o NotaOK, você concorda com estes Termos de Uso e com nossa Política de Privacidade.',
            ),
            _buildSection(
              '3. Uso do Aplicativo',
              'O NotaOK é um gerenciador de garantias e notas fiscais. Você pode:\n\n'
              '• Escanear QR Codes de notas fiscais\n'
              '• Fazer OCR de comprovantes\n'
              '• Gerenciar produtos com garantia\n'
              '• Receber notificações de vencimento\n\n'
              'Você é responsável pela veracidade das informações cadastradas.',
            ),
            _buildSection(
              '4. Privacidade de Dados',
              'Seus dados são armazenados de forma segura no Firebase. '
              'Não compartilhamos suas informações com terceiros sem seu consentimento.\n\n'
              'Consulte nossa Política de Privacidade para mais detalhes.',
            ),
            _buildSection(
              '5. Limitações de Responsabilidade',
              'O NotaOK não se responsabiliza por:\n\n'
              '• Erros no processamento de QR Codes ou OCR\n'
              '• Perda de dados por falha do dispositivo\n'
              '• Vencimento de garantias não notificadas por problemas técnicos\n\n'
              'O app é fornecido "como está", sem garantias.',
            ),
            _buildSection(
              '6. Modificações',
              'Podemos atualizar estes termos a qualquer momento. '
              'Notificaremos sobre mudanças significativas através do app.',
            ),
            _buildSection(
              '7. Contato',
              'Para dúvidas ou suporte:\n'
              'Email: suporte@notaok.com.br',
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

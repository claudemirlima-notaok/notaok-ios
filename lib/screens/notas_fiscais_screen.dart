import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/nota_fiscal.dart';
import 'package:intl/intl.dart';
import 'cadastro_nota_fiscal_screen.dart';
import 'cadastro_produto_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'edicao_nota_fiscal_screen.dart';

class NotasFiscaisScreen extends StatefulWidget {
  const NotasFiscaisScreen({super.key});

  @override
  State<NotasFiscaisScreen> createState() => _NotasFiscaisScreenState();
}

class _NotasFiscaisScreenState extends State<NotasFiscaisScreen> {
  List<NotaFiscal> _notas = [];

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  void _carregarNotas() {
    setState(() {
      _notas = HiveService.getTodasNotasFiscais();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Notas Fiscais',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logos/logo_notaok_final.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _notas.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notas.length,
              itemBuilder: (context, index) {
                return _buildNotaCard(_notas[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastroNotaFiscalScreen(),
            ),
          );
          if (result == true) {
            _carregarNotas();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Nota'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma nota fiscal arquivada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escaneie o QR Code de uma NF-e',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotaCard(NotaFiscal nota) {
    final formatoData = DateFormat('dd/MM/yyyy');
    final formatoValor = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _mostrarDetalhesNota(nota),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (nota.nomeEmitente != null)
                          Text(
                            nota.nomeEmitente!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          const Text(
                            'Estabelecimento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'NF-e ${nota.numeroNota ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão de edição (apenas para notas manuais)
                      if (nota.origem == 'manual')
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EdicaoNotaFiscalScreen(notaFiscal: nota),
                              ),
                            );
                            if (result == true) {
                              _carregarNotas();
                            }
                          },
                          tooltip: 'Editar nota',
                        ),
                      IconButton(
                        icon: Icon(
                          nota.imagemNotaPath != null 
                              ? Icons.photo 
                              : Icons.add_a_photo,
                          color: nota.imagemNotaPath != null
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[400],
                        ),
                        onPressed: () => _adicionarFotoNota(nota),
                        tooltip: nota.imagemNotaPath != null 
                            ? 'Ver foto' 
                            : 'Adicionar foto',
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data de Emissão',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatoData.format(nota.dataEmissao),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (nota.valorTotal != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Valor Total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatoValor.format(nota.valorTotal),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (nota.cnpjEmitente != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CNPJ: ${_formatarCNPJ(nota.cnpjEmitente!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatarCNPJ(String cnpj) {
    if (cnpj.length == 14) {
      return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12, 14)}';
    }
    return cnpj;
  }

  void _mostrarDetalhesNota(NotaFiscal nota) {
    final formatoData = DateFormat('dd/MM/yyyy');
    final formatoValor = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes da Nota Fiscal'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalheRow('Número:', nota.numeroNota ?? 'N/A'),
              _buildDetalheRow('Série:', nota.serie ?? 'N/A'),
              _buildDetalheRow('Data de Emissão:', formatoData.format(nota.dataEmissao)),
              if (nota.nomeEmitente != null)
                _buildDetalheRow('Emitente:', nota.nomeEmitente!),
              if (nota.cnpjEmitente != null)
                _buildDetalheRow('CNPJ:', _formatarCNPJ(nota.cnpjEmitente!)),
              if (nota.valorTotal != null)
                _buildDetalheRow('Valor Total:', formatoValor.format(nota.valorTotal)),
              const Divider(height: 24),
              Text(
                'Chave de Acesso:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nota.chaveAcesso,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          // Botão de edição (apenas para notas manuais)
          if (nota.origem == 'manual')
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EdicaoNotaFiscalScreen(notaFiscal: nota),
                  ),
                );
                if (result == true) {
                  _carregarNotas();
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Nota'),
            ),
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CadastroProdutoScreen(notaFiscal: nota),
                ),
              );
              if (result == true) {
                _carregarNotas();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Produto'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalheRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _adicionarFotoNota(NotaFiscal nota) async {
    // Se já tem foto, mostrar opção de visualizar ou trocar
    if (nota.imagemNotaPath != null && File(nota.imagemNotaPath!).existsSync()) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Foto da Nota'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: const Text('Imagem da Nota'),
                            backgroundColor: Colors.black,
                          ),
                          backgroundColor: Colors.black,
                          body: Center(
                            child: InteractiveViewer(
                              child: Image.file(File(nota.imagemNotaPath!)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(nota.imagemNotaPath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toque na imagem para ampliar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _capturarNovaFoto(nota);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Trocar Foto'),
            ),
          ],
        ),
      );
    } else {
      // Se não tem foto, capturar nova
      await _capturarNovaFoto(nota);
    }
  }

  Future<void> _capturarNovaFoto(NotaFiscal nota) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        nota.imagemNotaPath = image.path;
        await HiveService.atualizarNotaFiscal(nota);
        
        setState(() {
          _carregarNotas();
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Foto da nota adicionada!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

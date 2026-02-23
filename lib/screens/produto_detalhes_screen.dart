import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/avaliacao.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';
import 'package:intl/intl.dart';
import 'edicao_produto_screen.dart';

class ProdutoDetalhesScreen extends StatefulWidget {
  final Produto produto;

  const ProdutoDetalhesScreen({super.key, required this.produto});

  @override
  State<ProdutoDetalhesScreen> createState() => _ProdutoDetalhesScreenState();
}

class _ProdutoDetalhesScreenState extends State<ProdutoDetalhesScreen> {
  Avaliacao? _avaliacao;
  bool _temAvaliacao = false;
  NotaFiscal? _notaFiscal;

  @override
  void initState() {
    super.initState();
    _verificarAvaliacao();
    _carregarNotaFiscal();
  }

  void _carregarNotaFiscal() {
    if (widget.produto.notaFiscalId != null) {
      final nota = HiveService.getNotaFiscal(widget.produto.notaFiscalId!);
      setState(() {
        _notaFiscal = nota;
      });
    }
  }

  void _verificarAvaliacao() {
    final avaliacoes = HiveService.getTodasAvaliacoes();
    final avaliacaoProduto = avaliacoes.where((a) => a.produtoId == widget.produto.id).firstOrNull;
    setState(() {
      _avaliacao = avaliacaoProduto;
      _temAvaliacao = avaliacaoProduto != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatoData = DateFormat('dd/MM/yyyy');
    final formatoValor = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final diasRestantes = widget.produto.diasRestantesGarantia;

    Color statusColor;
    if (diasRestantes == 0) {
      statusColor = Colors.red;
    } else if (diasRestantes <= 30) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.verified_user_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text('NotaOK'),
          ],
        ),
        centerTitle: true,
        actions: [
          // Botão de edição APENAS para produtos manuais
          if (widget.produto.origem == 'manual')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EdicaoProdutoScreen(produto: widget.produto),
                  ),
                );
                if (result == true) {
                  setState(() {
                    // Recarregar dados
                  });
                }
              },
              tooltip: 'Editar Produto',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com ícone e nome
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.produto.nome,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.produto.categoria != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.produto.categoria!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Informações do produto
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status da garantia
                  Card(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            statusColor.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            diasRestantes == 0 ? 'Garantia Vencida' : 'Garantia Ativa',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (diasRestantes > 0) ...[
                            Text(
                              'Expira em $diasRestantes ${diasRestantes == 1 ? 'dia' : 'dias'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            formatoData.format(widget.produto.dataVencimentoGarantia),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informações detalhadas
                  _buildInfoSection('Informações do Produto', [
                    if (widget.produto.preco != null)
                      _buildInfoRow(Icons.attach_money, 'Preço', formatoValor.format(widget.produto.preco)),
                    _buildInfoRow(Icons.calendar_today, 'Data de Compra', formatoData.format(widget.produto.dataCompra)),
                    if (widget.produto.estabelecimento != null)
                      _buildInfoRow(Icons.store, 'Estabelecimento', widget.produto.estabelecimento!),
                    if (widget.produto.codigoBarras != null)
                      _buildInfoRow(Icons.qr_code, 'Código de Barras', widget.produto.codigoBarras!),
                    if (widget.produto.codigoProduto != null)
                      _buildInfoRow(Icons.tag, 'Código do Produto', widget.produto.codigoProduto!),
                  ]),

                  const SizedBox(height: 24),

                  // Informações da Nota Fiscal Vinculada
                  if (_notaFiscal != null) ...[
                    _buildNotaFiscalCard(),
                    const SizedBox(height: 24),
                  ],

                  // Botão de avaliar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _mostrarDialogoAvaliacao(),
                      icon: Icon(_temAvaliacao ? Icons.edit : Icons.star_rounded),
                      label: Text(_temAvaliacao ? 'Editar Avaliação' : 'Avaliar Compra'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  if (_temAvaliacao) ...[
                    const SizedBox(height: 16),
                    _buildAvaliacaoCard(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvaliacaoCard() {
    if (_avaliacao == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sua Avaliação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAvaliacaoRow('Loja', _avaliacao!.notaLoja),
            _buildAvaliacaoRow('Produto', _avaliacao!.notaProduto),
            _buildAvaliacaoRow('Vendedor', _avaliacao!.notaVendedor),
            _buildAvaliacaoRow('Atendimento', _avaliacao!.notaAtendimento),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Média Geral:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.star,
                    color: Colors.amber[700],
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _avaliacao!.mediaGeral.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (_avaliacao!.comentario != null && _avaliacao!.comentario!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Comentário:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _avaliacao!.comentario!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvaliacaoRow(String label, int nota) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < nota ? Icons.star : Icons.star_border,
                color: Colors.amber[700],
                size: 20,
              );
            }),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAvaliacao() {
    int notaLoja = _avaliacao?.notaLoja ?? 5;
    int notaProduto = _avaliacao?.notaProduto ?? 5;
    int notaVendedor = _avaliacao?.notaVendedor ?? 5;
    int notaAtendimento = _avaliacao?.notaAtendimento ?? 5;
    final comentarioController = TextEditingController(text: _avaliacao?.comentario ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(_temAvaliacao ? 'Editar Avaliação' : 'Avaliar Compra'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvaliacaoSlider(
                  'Loja',
                  notaLoja,
                  (value) => setDialogState(() => notaLoja = value),
                ),
                _buildAvaliacaoSlider(
                  'Produto',
                  notaProduto,
                  (value) => setDialogState(() => notaProduto = value),
                ),
                _buildAvaliacaoSlider(
                  'Vendedor',
                  notaVendedor,
                  (value) => setDialogState(() => notaVendedor = value),
                ),
                _buildAvaliacaoSlider(
                  'Atendimento',
                  notaAtendimento,
                  (value) => setDialogState(() => notaAtendimento = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: comentarioController,
                  decoration: const InputDecoration(
                    labelText: 'Comentário (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final avaliacao = Avaliacao(
                  id: _avaliacao?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  produtoId: widget.produto.id,
                  estabelecimento: widget.produto.estabelecimento,
                  cnpjEstabelecimento: widget.produto.cnpjEstabelecimento,
                  notaLoja: notaLoja,
                  notaProduto: notaProduto,
                  notaVendedor: notaVendedor,
                  notaAtendimento: notaAtendimento,
                  comentario: comentarioController.text.isEmpty ? null : comentarioController.text,
                  dataAvaliacao: DateTime.now(),
                );

                HiveService.adicionarAvaliacao(avaliacao);
                Navigator.pop(context);
                _verificarAvaliacao();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Avaliação salva com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvaliacaoSlider(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < value ? Icons.star : Icons.star_border,
                  color: Colors.amber[700],
                  size: 20,
                );
              }),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (newValue) => onChanged(newValue.toInt()),
        ),
      ],
    );
  }

  Widget _buildNotaFiscalCard() {
    final formatoData = DateFormat('dd/MM/yyyy');
    final formatoValor = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Nota Fiscal Vinculada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.store,
              'Estabelecimento',
              _notaFiscal!.nomeEmitente ?? 'N/A',
            ),
            _buildInfoRow(
              Icons.confirmation_number,
              'Número NF',
              _notaFiscal!.numeroNota ?? 'N/A',
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Data Emissão',
              formatoData.format(_notaFiscal!.dataEmissao),
            ),
            if (_notaFiscal!.valorTotal != null)
              _buildInfoRow(
                Icons.attach_money,
                'Valor Total',
                formatoValor.format(_notaFiscal!.valorTotal),
              ),
            if (_notaFiscal!.nomeVendedor != null)
              _buildInfoRow(
                Icons.person,
                'Vendedor',
                _notaFiscal!.nomeVendedor!,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';
import 'package:intl/intl.dart';

class SelecaoProdutosScreen extends StatefulWidget {
  final NotaFiscal notaFiscal;
  final List<Produto> produtos;

  const SelecaoProdutosScreen({
    super.key,
    required this.notaFiscal,
    required this.produtos,
  });

  @override
  State<SelecaoProdutosScreen> createState() => _SelecaoProdutosScreenState();
}

class _SelecaoProdutosScreenState extends State<SelecaoProdutosScreen> {
  final Map<String, bool> _produtosSelecionados = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicialmente, todos os produtos estão selecionados
    for (var produto in widget.produtos) {
      _produtosSelecionados[produto.id] = true;
    }
  }

  Future<void> _salvarProdutosSelecionados() async {
    final produtosSelecionados = widget.produtos
        .where((p) => _produtosSelecionados[p.id] == true)
        .toList();

    if (produtosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Selecione pelo menos um produto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Salvar nota fiscal
      await HiveService.adicionarNotaFiscal(widget.notaFiscal);

      // Salvar apenas produtos selecionados
      for (var produto in produtosSelecionados) {
        await HiveService.adicionarProduto(produto);
      }

      // Atualizar lista de produtos da nota
      widget.notaFiscal.produtosIds = produtosSelecionados.map((p) => p.id).toList();
      await HiveService.atualizarNotaFiscal(widget.notaFiscal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${produtosSelecionados.length} produtos adicionados com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoValor = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final produtosSelecionadosCount = _produtosSelecionados.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selecionar Produtos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
      ),
      body: Column(
        children: [
          // Card com informações da nota
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.notaFiscal.nomeEmitente ?? 'Estabelecimento',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'NF-e ${widget.notaFiscal.numeroNota ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Produtos selecionados:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '$produtosSelecionadosCount de ${widget.produtos.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de produtos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.produtos.length,
              itemBuilder: (context, index) {
                final produto = widget.produtos[index];
                final isSelected = _produtosSelecionados[produto.id] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        _produtosSelecionados[produto.id] = value ?? false;
                      });
                    },
                    title: Text(
                      produto.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (produto.categoria != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            produto.categoria!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        if (produto.preco != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            formatoValor.format(produto.preco),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Garantia até ${DateFormat('dd/MM/yyyy').format(produto.dataVencimentoGarantia)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    secondary: Container(
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
                        Icons.shopping_bag,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              },
            ),
          ),

          // Botão de salvar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _salvarProdutosSelecionados,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _isLoading 
                      ? 'Salvando...' 
                      : 'Salvar Produtos ($produtosSelecionadosCount)',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

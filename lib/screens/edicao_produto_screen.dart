import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/produto.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';
import 'package:intl/intl.dart';

class EdicaoProdutoScreen extends StatefulWidget {
  final Produto produto;

  const EdicaoProdutoScreen({super.key, required this.produto});

  @override
  State<EdicaoProdutoScreen> createState() => _EdicaoProdutoScreenState();
}

class _EdicaoProdutoScreenState extends State<EdicaoProdutoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _categoriaController;
  late TextEditingController _valorController;
  late TextEditingController _garantiaMesesController;
  late TextEditingController _codigoBarrasController;
  late TextEditingController _codigoProdutoController;
  late TextEditingController _estabelecimentoController;
  
  late DateTime _dataCompra;
  bool _isLoading = false;
  List<NotaFiscal> _notasDisponiveis = [];
  NotaFiscal? _notaSelecionada;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.produto.nome);
    _categoriaController = TextEditingController(text: widget.produto.categoria ?? '');
    _valorController = TextEditingController(text: widget.produto.preco?.toString() ?? '');
    _codigoBarrasController = TextEditingController(text: widget.produto.codigoBarras ?? '');
    _codigoProdutoController = TextEditingController(text: widget.produto.codigoProduto ?? '');
    _estabelecimentoController = TextEditingController(text: widget.produto.estabelecimento ?? '');
    _dataCompra = widget.produto.dataCompra;
    
    // Calcular meses de garantia
    final diferenca = widget.produto.dataVencimentoGarantia.difference(widget.produto.dataCompra);
    final meses = (diferenca.inDays / 30).round();
    _garantiaMesesController = TextEditingController(text: meses.toString());
    
    _carregarNotas();
  }

  void _carregarNotas() {
    setState(() {
      _notasDisponiveis = HiveService.getTodasNotasFiscais();
      if (widget.produto.notaFiscalId != null) {
        _notaSelecionada = _notasDisponiveis.firstWhere(
          (nota) => nota.id == widget.produto.notaFiscalId,
          orElse: () => _notasDisponiveis.first,
        );
      }
    });
  }

  void _atualizarEstabelecimento() {
    if (_notaSelecionada != null) {
      _estabelecimentoController.text = _notaSelecionada!.nomeEmitente ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _valorController.dispose();
    _garantiaMesesController.dispose();
    _codigoBarrasController.dispose();
    _codigoProdutoController.dispose();
    _estabelecimentoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataCompra,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _dataCompra) {
      setState(() {
        _dataCompra = picked;
      });
    }
  }

  Future<void> _salvarProduto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar se o valor do produto não é maior que o valor total da nota
    final valorProduto = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (valorProduto != null && _notaSelecionada != null && _notaSelecionada!.valorTotal != null) {
      if (valorProduto > _notaSelecionada!.valorTotal!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Valor do produto (R\$ ${valorProduto.toStringAsFixed(2)}) não pode ser maior que o valor total da nota (R\$ ${_notaSelecionada!.valorTotal!.toStringAsFixed(2)})',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final garantiaMeses = int.parse(_garantiaMesesController.text);
      final dataVencimentoGarantia = DateTime(
        _dataCompra.year,
        _dataCompra.month + garantiaMeses,
        _dataCompra.day,
      );

      // Atualizar produto
      widget.produto.nome = _nomeController.text.trim();
      widget.produto.categoria = _categoriaController.text.trim().isEmpty 
          ? null 
          : _categoriaController.text.trim();
      widget.produto.preco = double.tryParse(_valorController.text.replaceAll(',', '.'));
      widget.produto.dataCompra = _dataCompra;
      widget.produto.dataVencimentoGarantia = dataVencimentoGarantia;
      widget.produto.estabelecimento = _estabelecimentoController.text.trim().isEmpty
          ? _notaSelecionada?.nomeEmitente
          : _estabelecimentoController.text.trim();
      widget.produto.cnpjEstabelecimento = _notaSelecionada?.cnpjEmitente;
      widget.produto.notaFiscalId = _notaSelecionada?.id;
      widget.produto.codigoBarras = _codigoBarrasController.text.trim().isEmpty 
          ? null 
          : _codigoBarrasController.text.trim();
      widget.produto.codigoProduto = _codigoProdutoController.text.trim().isEmpty 
          ? null 
          : _codigoProdutoController.text.trim();

      await HiveService.atualizarProduto(widget.produto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Produto atualizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Produto',
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seleção de Nota Fiscal
            if (_notasDisponiveis.isNotEmpty) ...[
              Card(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Nota Fiscal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<NotaFiscal>(
                        initialValue: _notaSelecionada,
                        decoration: InputDecoration(
                          labelText: 'Nota Fiscal Vinculada',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _notasDisponiveis.map((nota) {
                          return DropdownMenuItem(
                            value: nota,
                            child: Text(
                              '${nota.nomeEmitente ?? 'N/A'} - NF ${nota.numeroNota ?? 'N/A'}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (nota) {
                          setState(() {
                            _notaSelecionada = nota;
                            _atualizarEstabelecimento();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Nome do Produto
            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Produto *',
                prefixIcon: const Icon(Icons.shopping_bag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Categoria
            TextFormField(
              controller: _categoriaController,
              decoration: InputDecoration(
                labelText: 'Categoria (opcional)',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Valor
            TextFormField(
              controller: _valorController,
              decoration: InputDecoration(
                labelText: 'Valor *',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Data de Compra
            InkWell(
              onTap: () => _selecionarData(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data de Compra *',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_dataCompra),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Garantia em Meses
            TextFormField(
              controller: _garantiaMesesController,
              decoration: InputDecoration(
                labelText: 'Garantia (meses) *',
                prefixIcon: const Icon(Icons.verified_user),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Código de Barras
            TextFormField(
              controller: _codigoBarrasController,
              decoration: InputDecoration(
                labelText: 'Código de Barras (opcional)',
                prefixIcon: const Icon(Icons.qr_code),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),

            // Código do Produto
            TextFormField(
              controller: _codigoProdutoController,
              decoration: InputDecoration(
                labelText: 'Código do Produto (opcional)',
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Estabelecimento
            TextFormField(
              controller: _estabelecimentoController,
              decoration: InputDecoration(
                labelText: 'Estabelecimento *',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Botão Salvar
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _salvarProduto,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Salvando...' : 'Salvar Alterações'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

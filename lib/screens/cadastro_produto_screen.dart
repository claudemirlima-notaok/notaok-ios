import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/produto.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CadastroProdutoScreen extends StatefulWidget {
  final NotaFiscal notaFiscal;
  
  const CadastroProdutoScreen({
    super.key,
    required this.notaFiscal,
  });

  @override
  State<CadastroProdutoScreen> createState() => _CadastroProdutoScreenState();
}

class _CadastroProdutoScreenState extends State<CadastroProdutoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _valorController = TextEditingController();
  final _garantiaMesesController = TextEditingController();
  final _codigoBarrasController = TextEditingController();
  final _codigoProdutoController = TextEditingController();
  
  DateTime _dataCompra = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Usar a data de emissão da nota como data de compra padrão
    _dataCompra = widget.notaFiscal.dataEmissao;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _valorController.dispose();
    _garantiaMesesController.dispose();
    _codigoBarrasController.dispose();
    _codigoProdutoController.dispose();
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

    setState(() {
      _isLoading = true;
    });

    try {
      final uuid = const Uuid();
      final garantiaMeses = int.parse(_garantiaMesesController.text);
      final dataVencimentoGarantia = DateTime(
        _dataCompra.year,
        _dataCompra.month + garantiaMeses,
        _dataCompra.day,
      );

      final produto = Produto(
        id: uuid.v4(),
        nome: _nomeController.text.trim(),
        dataCompra: _dataCompra,
        dataVencimentoGarantia: dataVencimentoGarantia,
        categoria: _categoriaController.text.trim().isEmpty 
            ? null 
            : _categoriaController.text.trim(),
        preco: double.tryParse(_valorController.text.replaceAll(',', '.')),
        estabelecimento: widget.notaFiscal.nomeEmitente,
        cnpjEstabelecimento: widget.notaFiscal.cnpjEmitente,
        notaFiscalId: widget.notaFiscal.id,
        codigoBarras: _codigoBarrasController.text.trim().isEmpty 
            ? null 
            : _codigoBarrasController.text.trim(),
        codigoProduto: _codigoProdutoController.text.trim().isEmpty 
            ? null 
            : _codigoProdutoController.text.trim(),
        origem: 'manual', // Marcando como cadastro manual
      );

      await HiveService.adicionarProduto(produto);

      // Atualizar a lista de produtos da nota fiscal
      final notasAtualizadas = widget.notaFiscal.produtosIds ?? [];
      if (!notasAtualizadas.contains(produto.id)) {
        notasAtualizadas.add(produto.id);
        widget.notaFiscal.produtosIds = notasAtualizadas;
        await HiveService.atualizarNotaFiscal(widget.notaFiscal);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Produto cadastrado com sucesso!'),
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
          'Cadastrar Produto',
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
            // Card com informações da Nota Fiscal
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
                        Expanded(
                          child: Text(
                            'Vinculado à Nota Fiscal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Estabelecimento:', widget.notaFiscal.nomeEmitente ?? 'N/A'),
                    _buildInfoRow('Nota:', widget.notaFiscal.numeroNota ?? 'N/A'),
                    _buildInfoRow('Data:', DateFormat('dd/MM/yyyy').format(widget.notaFiscal.dataEmissao)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
                hintText: 'Ex: Eletrônicos, Eletrodomésticos',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Valor
            TextFormField(
              controller: _valorController,
              decoration: InputDecoration(
                labelText: 'Valor (opcional)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: '0.00',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
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
                hintText: 'Ex: 12',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                final meses = int.tryParse(value);
                if (meses == null || meses <= 0) {
                  return 'Valor inválido';
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
              label: Text(_isLoading ? 'Salvando...' : 'Salvar Produto'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
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
}

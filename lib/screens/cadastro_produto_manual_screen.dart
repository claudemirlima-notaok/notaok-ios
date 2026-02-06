import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/produto.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'cadastro_nota_fiscal_screen.dart';

class CadastroProdutoManualScreen extends StatefulWidget {
  const CadastroProdutoManualScreen({super.key});

  @override
  State<CadastroProdutoManualScreen> createState() => _CadastroProdutoManualScreenState();
}

class _CadastroProdutoManualScreenState extends State<CadastroProdutoManualScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _valorController = TextEditingController();
  final _garantiaMesesController = TextEditingController();
  final _codigoBarrasController = TextEditingController();
  final _codigoProdutoController = TextEditingController();
  final _estabelecimentoController = TextEditingController();
  
  DateTime _dataCompra = DateTime.now();
  bool _isLoading = false;
  List<NotaFiscal> _notasDisponiveis = [];
  NotaFiscal? _notaSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  void _carregarNotas() {
    setState(() {
      _notasDisponiveis = HiveService.getTodasNotasFiscais();
    });
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

  Future<void> _navegarParaCadastroNota() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroNotaFiscalScreen(),
      ),
    );
    
    if (result == true) {
      _carregarNotas();
      if (_notasDisponiveis.isNotEmpty) {
        setState(() {
          _notaSelecionada = _notasDisponiveis.first;
          _atualizarEstabelecimento();
        });
      }
    }
  }

  void _atualizarEstabelecimento() {
    if (_notaSelecionada != null) {
      _estabelecimentoController.text = _notaSelecionada!.nomeEmitente ?? '';
    }
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
    if (_notaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Selecione uma nota fiscal'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar se o valor do produto não é maior que o valor total da nota
    final valorProduto = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (valorProduto != null && _notaSelecionada!.valorTotal != null) {
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
        estabelecimento: _estabelecimentoController.text.trim().isEmpty
            ? _notaSelecionada!.nomeEmitente
            : _estabelecimentoController.text.trim(),
        cnpjEstabelecimento: _notaSelecionada!.cnpjEmitente,
        notaFiscalId: _notaSelecionada!.id,
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
      final notasAtualizadas = _notaSelecionada!.produtosIds ?? [];
      if (!notasAtualizadas.contains(produto.id)) {
        notasAtualizadas.add(produto.id);
        _notaSelecionada!.produtosIds = notasAtualizadas;
        await HiveService.atualizarNotaFiscal(_notaSelecionada!);
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
          'Adicionar Produto',
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
      body: _notasDisponiveis.isEmpty
          ? _buildSemNotasState()
          : _buildFormulario(),
    );
  }

  Widget _buildSemNotasState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma Nota Fiscal Cadastrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Para adicionar um produto manualmente, você precisa cadastrar uma nota fiscal primeiro.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navegarParaCadastroNota,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Nota Fiscal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Seleção de Nota Fiscal
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
                          'Nota Fiscal (Obrigatório)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _navegarParaCadastroNota,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nova'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<NotaFiscal>(
                    initialValue: _notaSelecionada,
                    decoration: InputDecoration(
                      labelText: 'Selecione a Nota Fiscal',
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
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione uma nota fiscal';
                      }
                      return null;
                    },
                  ),
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
              labelText: 'Valor *',
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Campo obrigatório';
              }
              final valor = double.tryParse(value.replaceAll(',', '.'));
              if (valor == null || valor <= 0) {
                return 'Valor inválido';
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
              hintText: 'Preenchido automaticamente da nota',
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
    );
  }
}

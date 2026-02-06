import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/nota_fiscal.dart';
import '../services/hive_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CadastroNotaFiscalScreen extends StatefulWidget {
  const CadastroNotaFiscalScreen({super.key});

  @override
  State<CadastroNotaFiscalScreen> createState() => _CadastroNotaFiscalScreenState();
}

class _CadastroNotaFiscalScreenState extends State<CadastroNotaFiscalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeEmitenteController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _valorTotalController = TextEditingController();
  final _numeroNotaController = TextEditingController();
  final _serieController = TextEditingController();
  final _nomeVendedorController = TextEditingController();
  final _chaveAcessoController = TextEditingController();
  
  DateTime _dataEmissao = DateTime.now();
  String? _imagemNotaPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeEmitenteController.dispose();
    _cnpjController.dispose();
    _valorTotalController.dispose();
    _numeroNotaController.dispose();
    _serieController.dispose();
    _nomeVendedorController.dispose();
    _chaveAcessoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataEmissao,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _dataEmissao) {
      setState(() {
        _dataEmissao = picked;
      });
    }
  }

  Future<void> _capturarImagemNota() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagemNotaPath = image.path;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Imagem da nota capturada!'),
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
            content: Text('Erro ao capturar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _salvarNotaFiscal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uuid = const Uuid();
      
      // Gerar chave de acesso aleatória se não foi fornecida
      String chaveAcesso = _chaveAcessoController.text.trim();
      if (chaveAcesso.isEmpty) {
        // Gerar chave de acesso de 44 dígitos numéricos
        final random = uuid.v4().replaceAll('-', '') + uuid.v4().replaceAll('-', '');
        chaveAcesso = random.replaceAll(RegExp(r'[^0-9]'), '').padRight(44, '0').substring(0, 44);
      }

      final notaFiscal = NotaFiscal(
        id: uuid.v4(),
        chaveAcesso: chaveAcesso,
        numeroNota: _numeroNotaController.text.trim(),
        serie: _serieController.text.trim(),
        dataEmissao: _dataEmissao,
        nomeEmitente: _nomeEmitenteController.text.trim(),
        cnpjEmitente: _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        valorTotal: double.tryParse(_valorTotalController.text.replaceAll(',', '.')),
        dataCadastro: DateTime.now(),
        nomeVendedor: _nomeVendedorController.text.trim().isEmpty 
            ? null 
            : _nomeVendedorController.text.trim(),
        imagemNotaPath: _imagemNotaPath,
        origem: 'manual', // Marcando como cadastro manual
      );

      await HiveService.adicionarNotaFiscal(notaFiscal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Nota Fiscal cadastrada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Retorna true para indicar que salvou
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
          'Cadastrar Nota Fiscal',
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
            // Card de Imagem da Nota
            Card(
              child: InkWell(
                onTap: _capturarImagemNota,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[100],
                  ),
                  child: _imagemNotaPath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Adicionar foto da nota (opcional)',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.check_circle,
                                size: 64,
                                color: Colors.green,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _imagemNotaPath = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Estabelecimento
            TextFormField(
              controller: _nomeEmitenteController,
              decoration: InputDecoration(
                labelText: 'Nome do Estabelecimento *',
                prefixIcon: const Icon(Icons.store_rounded),
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

            // CNPJ
            TextFormField(
              controller: _cnpjController,
              decoration: InputDecoration(
                labelText: 'CNPJ *',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: '00.000.000/0000-00',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(14),
                _CNPJInputFormatter(),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                final cnpj = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (cnpj.length != 14) {
                  return 'CNPJ inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Valor Total
            TextFormField(
              controller: _valorTotalController,
              decoration: InputDecoration(
                labelText: 'Valor Total *',
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

            // Data de Emissão
            InkWell(
              onTap: () => _selecionarData(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data de Emissão *',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_dataEmissao),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Número da Nota
            TextFormField(
              controller: _numeroNotaController,
              decoration: InputDecoration(
                labelText: 'Número da Nota *',
                prefixIcon: const Icon(Icons.confirmation_number),
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

            // Série
            TextFormField(
              controller: _serieController,
              decoration: InputDecoration(
                labelText: 'Série *',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Ex: 1',
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

            // Nome do Vendedor
            TextFormField(
              controller: _nomeVendedorController,
              decoration: InputDecoration(
                labelText: 'Nome do Vendedor (opcional)',
                prefixIcon: const Icon(Icons.person_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Chave de Acesso (Opcional - gerado automaticamente se vazio)
            TextFormField(
              controller: _chaveAcessoController,
              decoration: InputDecoration(
                labelText: 'Chave de Acesso (opcional)',
                prefixIcon: const Icon(Icons.key),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Será gerada automaticamente',
              ),
              maxLength: 44,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 24),

            // Botão Salvar
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _salvarNotaFiscal,
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
              label: Text(_isLoading ? 'Salvando...' : 'Salvar Nota Fiscal'),
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

// Formatador de CNPJ
class _CNPJInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (text.length > 14) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 5) {
        formatted += '.';
      } else if (i == 8) {
        formatted += '/';
      } else if (i == 12) {
        formatted += '-';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

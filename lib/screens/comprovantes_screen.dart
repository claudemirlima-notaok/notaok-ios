import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/hive_service.dart';
import '../services/map_service.dart';
import '../models/comprovante.dart';
import 'package:intl/intl.dart';
import 'dart:io' show File;

class ComprovantesScreen extends StatefulWidget {
  const ComprovantesScreen({super.key});

  @override
  State<ComprovantesScreen> createState() => _ComprovantesScreenState();
}

class _ComprovantesScreenState extends State<ComprovantesScreen> {
  List<Comprovante> _comprovantes = [];

  @override
  void initState() {
    super.initState();
    _carregarComprovantes();
  }

  void _carregarComprovantes() {
    setState(() {
      _comprovantes = HiveService.getTodosComprovantes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Comprovantes',
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
      body: _comprovantes.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _comprovantes.length,
              itemBuilder: (context, index) {
                return _buildComprovanteCard(_comprovantes[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum comprovante registrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture um comprovante de cartão',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComprovanteCard(Comprovante comprovante) {
    final formatoData = DateFormat('dd/MM/yyyy HH:mm');
    final formatoValor = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _mostrarDetalhesComprovante(comprovante),
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
                      Icons.credit_card_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (comprovante.estabelecimento != null)
                          Text(
                            comprovante.estabelecimento!,
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
                        if (comprovante.produto != null)
                          Text(
                            comprovante.produto!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Valor',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comprovante.valor != null 
                                  ? formatoValor.format(comprovante.valor)
                                  : 'N/A',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        if (comprovante.dataTransacao != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Data',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatoData.format(comprovante.dataTransacao!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (comprovante.cartaoCredito != null || comprovante.bandeira != null) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (comprovante.bandeira != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  comprovante.bandeira!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          if (comprovante.cartaoCredito != null)
                            Text(
                              '**** ${comprovante.cartaoCredito}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                    // Badge de localização
                    if (comprovante.temLocalizacao) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      MapService.buildLocationBadge(
                        context: context,
                        comprovante: comprovante,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhesComprovante(Comprovante comprovante) {
    final formatoData = DateFormat('dd/MM/yyyy HH:mm');
    final formatoValor = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Comprovante'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mostrar imagem do comprovante se existir
              if (comprovante.imagemPath != null && comprovante.imagemPath!.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    // Mostrar imagem em tela cheia
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: const Text('Imagem do Comprovante'),
                            backgroundColor: Colors.black,
                          ),
                          backgroundColor: Colors.black,
                          body: Center(
                            child: InteractiveViewer(
                              child: _buildImage(comprovante.imagemPath!),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImage(comprovante.imagemPath!, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
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
                const Divider(height: 24),
              ],
              if (comprovante.estabelecimento != null)
                _buildDetalheRow('Estabelecimento:', comprovante.estabelecimento!),
              if (comprovante.produto != null)
                _buildDetalheRow('Descrição:', comprovante.produto!),
              if (comprovante.valor != null)
                _buildDetalheRow('Valor:', formatoValor.format(comprovante.valor)),
              if (comprovante.dataTransacao != null)
                _buildDetalheRow('Data/Hora:', formatoData.format(comprovante.dataTransacao!)),
              if (comprovante.bandeira != null)
                _buildDetalheRow('Bandeira:', comprovante.bandeira!),
              if (comprovante.cartaoCredito != null)
                _buildDetalheRow('Cartão:', '**** ${comprovante.cartaoCredito}'),
              if (comprovante.tipoTransacao != null)
                _buildDetalheRow('Tipo:', comprovante.tipoTransacao!),
              if (comprovante.cnpj != null)
                _buildDetalheRow('CNPJ:', comprovante.cnpjFormatado),
              if (comprovante.cidade != null || comprovante.estado != null)
                _buildDetalheRow('Cidade/UF:', comprovante.localizacaoFormatada),
              // Botão de mapa expandido
              if (comprovante.temLocalizacao) ...[
                const SizedBox(height: 12),
                Center(
                  child: MapService.buildMapButton(
                    context: context,
                    comprovante: comprovante,
                    compact: false,
                  ),
                ),
              ],
              if (comprovante.textoOCR != null && comprovante.textoOCR!.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  'Texto Extraído (OCR):',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    comprovante.textoOCR!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
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

  // Helper para exibir imagens de forma cross-platform
  Widget _buildImage(String path, {BoxFit fit = BoxFit.cover}) {
    if (kIsWeb) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text('Imagem não disponível', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text('Imagem não disponível', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      );
    }
  }
}

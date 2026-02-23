import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/nfe_service.dart';
import '../services/hive_service.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import 'selecao_produtos_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessing = false;
  bool flashEnabled = false;

  @override
  void reassemble() {
    super.reassemble();
    if (!kIsWeb && controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Escanear Documentos',
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
          IconButton(
            icon: Icon(flashEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {
                flashEnabled = !flashEnabled;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () async {
              await controller?.flipCamera();
            },
          ),
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
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: kIsWeb
                ? Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 100,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Scanner de QR Code\nnão disponível na Web',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Use a captura de comprovante abaixo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                        overlay: QrScannerOverlayShape(
                          borderColor: Theme.of(context).colorScheme.secondary,
                          borderRadius: 16,
                          borderLength: 40,
                          borderWidth: 10,
                          cutOutSize: MediaQuery.of(context).size.width * 0.7,
                        ),
                      ),
                      if (isProcessing)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          Expanded(
            flex: 2,
            child: Container(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Posicione o QR Code da NF-e',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ou capture um comprovante de cartão',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _capturarComprovante,
                    icon: Icon(kIsWeb ? Icons.upload_file : Icons.camera_alt),
                    label: Text(kIsWeb ? 'Enviar Comprovante' : 'Capturar Comprovante'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    if (!kIsWeb) {
      this.controller = controller;
      controller.scannedDataStream.listen((scanData) {
        if (!isProcessing && scanData.code != null) {
          _processarQRCode(scanData.code!);
        }
      });
    }
  }

  Future<void> _processarQRCode(String qrCode) async {
    setState(() {
      isProcessing = true;
    });

    try {
      if (!kIsWeb && controller != null) {
        await controller!.pauseCamera();
      }

      final notaFiscal = await NFeService.processarQRCodeNFe(qrCode);

      if (notaFiscal != null) {
        // Criar produtos de exemplo
        final produtos = NFeService.criarProdutosExemplo(notaFiscal);

        if (mounted) {
          // Navegar para tela de seleção de produtos
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelecaoProdutosScreen(
                notaFiscal: notaFiscal,
                produtos: produtos,
              ),
            ),
          );
        }
      } else {
        throw Exception('Erro ao processar QR Code');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
      if (!kIsWeb && controller != null) {
        await controller!.resumeCamera();
      }
    }
  }

  Future<void> _capturarComprovante() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Na Web, usar galeria ao invés de câmera
      final ImageSource source = kIsWeb ? ImageSource.gallery : ImageSource.camera;
      
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          isProcessing = true;
        });

        final comprovante = await OCRService.processarComprovanteCartao(image.path);

        if (comprovante != null) {
          await HiveService.adicionarComprovante(comprovante);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Comprovante processado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );

            // Mostrar diálogo com informações extraídas
            _mostrarDialogoComprovante(comprovante);
          }
        } else {
          throw Exception('Não foi possível processar o comprovante');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar comprovante: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _mostrarDialogoComprovante(comprovante) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comprovante Processado'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (comprovante.estabelecimento != null)
                _buildInfoRow('Estabelecimento:', comprovante.estabelecimento!),
              if (comprovante.valor != null)
                _buildInfoRow('Valor:', 'R\$ ${comprovante.valor!.toStringAsFixed(2)}'),
              if (comprovante.cartaoCredito != null)
                _buildInfoRow('Cartão:', '**** ${comprovante.cartaoCredito}'),
              if (comprovante.bandeira != null)
                _buildInfoRow('Bandeira:', comprovante.bandeira!),
              if (comprovante.produto != null)
                _buildInfoRow('Produto:', comprovante.produto!),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

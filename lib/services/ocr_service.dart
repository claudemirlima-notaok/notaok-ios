import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import '../models/comprovante.dart';

/// Serviço de OCR usando Tesseract - SIMPLIFICADO
class OCRService {
  
  /// Processa imagem de comprovante e retorna objeto Comprovante
  static Future<Comprovante?> processarComprovanteCartao(String imagePath) async {
    try {
      // Validar se arquivo existe
      final file = File(imagePath);
      if (!await file.exists()) {
        if (kDebugMode) {
          debugPrint('❌ Arquivo não encontrado: $imagePath');
        }
        throw Exception('Arquivo de imagem não encontrado');
      }

      // Validar tamanho do arquivo
      final fileSize = await file.length();
      if (fileSize == 0) {
        if (kDebugMode) {
          debugPrint('❌ Arquivo vazio: $imagePath');
        }
        throw Exception('Arquivo de imagem está vazio');
      }

      if (kDebugMode) {
        debugPrint('📸 Iniciando OCR Tesseract');
        debugPrint('📂 Arquivo: $imagePath');
        debugPrint('📏 Tamanho: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      }
      
      // Extrair texto da imagem usando Tesseract OCR (SIMPLIFICADO - SEM CONFIG)
      final String textoExtraido = await FlutterTesseractOcr.extractText(
        imagePath,
        language: 'por', // Português
        args: {
          "psm": "6", // Assume a single uniform block of text
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout ao processar imagem (30s)');
        },
      );
      
      if (kDebugMode) {
        debugPrint('✅ Texto extraído: ${textoExtraido.length} caracteres');
        if (textoExtraido.length > 200) {
          debugPrint('📄 Primeiras 200 chars:\n${textoExtraido.substring(0, 200)}...');
        } else {
          debugPrint('📄 Texto completo:\n$textoExtraido');
        }
      }
      
      if (textoExtraido.trim().isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ Nenhum texto foi extraído da imagem');
        }
        throw Exception('Não foi possível extrair texto da imagem. Tente tirar outra foto com melhor iluminação.');
      }

      // Processar texto extraído e criar objeto Comprovante
      final comprovante = _processarTextoComprovante(textoExtraido, imagePath);
      
      if (kDebugMode) {
        debugPrint('✅ Comprovante processado com sucesso');
      }
      
      return comprovante;
      
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('⏱️ Timeout ao processar imagem');
      }
      throw Exception('Tempo limite excedido ao processar imagem');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao processar comprovante: $e');
      }
      rethrow;
    }
  }

  /// Processa texto extraído e cria objeto Comprovante
  static Comprovante _processarTextoComprovante(String texto, String imagePath) {
    final linhas = texto.split('\n');
    
    String? estabelecimento = _extrairEstabelecimento(linhas);
    String? cnpj = _extrairCNPJ(texto);
    double? valor = _extrairValor(texto);
    DateTime? dataTransacao = _extrairData(texto);
    String? bandeira = _extrairBandeira(texto);
    String? cartaoCredito = _extrairUltimosDigitosCartao(texto);
    String? tipoTransacao = _extrairTipoTransacao(texto);
    Map<String, String?> localizacao = _extrairCidadeEstado(texto);

    if (kDebugMode) {
      debugPrint('🏪 Estabelecimento: $estabelecimento');
      debugPrint('🆔 CNPJ: $cnpj');
      debugPrint('💰 Valor: R\$ $valor');
      debugPrint('📅 Data: $dataTransacao');
      debugPrint('💳 Bandeira: $bandeira');
      debugPrint('🔢 Cartão: $cartaoCredito');
      debugPrint('📝 Tipo: $tipoTransacao');
      debugPrint('📍 Localização: ${localizacao['cidade']}/${localizacao['estado']}');
    }

    return Comprovante(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dataCadastro: DateTime.now(),
    )
      ..estabelecimento = estabelecimento
      ..cnpj = cnpj
      ..valor = valor
      ..dataTransacao = dataTransacao
      ..bandeira = bandeira
      ..cartaoCredito = cartaoCredito
      ..tipoTransacao = tipoTransacao
      ..cidade = localizacao['cidade']
      ..estado = localizacao['estado']
      ..imagemPath = imagePath
      ..textoOCR = texto;
  }

  static String? _extrairEstabelecimento(List<String> linhas) {
    for (int i = 0; i < linhas.length && i < 10; i++) {
      final linha = linhas[i].trim();
      
      if (i + 1 < linhas.length) {
        final proximaLinha = linhas[i + 1];
        if (proximaLinha.contains(RegExp(r'\d{2}\.\d{3}\.\d{3}'))) {
          if (linha.length > 3 && 
              !linha.toLowerCase().contains('laranjinha') &&
              !linha.toLowerCase().contains('larj') &&
              !linha.toLowerCase().contains('sitef')) {
            return linha;
          }
        }
      }
      
      if (linha.length > 5 && !linha.contains(RegExp(r'\d{2}\.\d{3}\.\d{3}'))) {
        if (!linha.toLowerCase().contains('laranjinha') &&
            !linha.toLowerCase().contains('larj') &&
            !linha.toLowerCase().contains('sitef') &&
            !linha.toLowerCase().contains('comprovante')) {
          return linha;
        }
      }
    }
    return null;
  }

  static String? _extrairCNPJ(String texto) {
    final regexCNPJ = RegExp(r'(\d{2}\.?\d{3}\.?\d{3}/?\d{4}-?\d{2})');
    final match = regexCNPJ.firstMatch(texto);
    if (match != null) {
      String cnpj = match.group(0)!;
      cnpj = cnpj.replaceAll(RegExp(r'[^\d]'), '');
      if (cnpj.length == 14) {
        return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12, 14)}';
      }
    }
    return null;
  }

  static double? _extrairValor(String texto) {
    final regexValor = RegExp(
      r'(?:R\$|VALOR|TOTAL|VLR)?\s*(\d{1,10})[,.](\d{2})',
      caseSensitive: false
    );
    
    final matches = regexValor.allMatches(texto);
    double? maiorValor;
    
    for (final match in matches) {
      final parteInteira = match.group(1);
      final parteDecimal = match.group(2);
      final valor = double.tryParse('$parteInteira.$parteDecimal');
      
      if (valor != null && (maiorValor == null || valor > maiorValor)) {
        maiorValor = valor;
      }
    }
    
    return maiorValor;
  }

  static DateTime? _extrairData(String texto) {
    final regexData = RegExp(
      r'(\d{2})/(\d{2})/(\d{2,4})\s+(\d{2}):(\d{2})(?::(\d{2}))?'
    );
    
    final match = regexData.firstMatch(texto);
    if (match != null) {
      try {
        final dia = int.parse(match.group(1)!);
        final mes = int.parse(match.group(2)!);
        var ano = int.parse(match.group(3)!);
        final hora = int.parse(match.group(4)!);
        final minuto = int.parse(match.group(5)!);
        final segundo = match.group(6) != null ? int.parse(match.group(6)!) : 0;
        
        if (ano < 100) {
          ano += 2000;
        }
        
        return DateTime(ano, mes, dia, hora, minuto, segundo);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static String? _extrairBandeira(String texto) {
    const bandeiras = [
      'MASTERCARD', 'VISA', 'ELO', 'AMEX', 'AMERICAN EXPRESS',
      'HIPERCARD', 'DINERS', 'DISCOVER'
    ];
    
    final textoUpper = texto.toUpperCase();
    for (final bandeira in bandeiras) {
      if (textoUpper.contains(bandeira)) {
        return bandeira == 'AMERICAN EXPRESS' ? 'AMEX' : bandeira;
      }
    }
    return null;
  }

  static String? _extrairUltimosDigitosCartao(String texto) {
    final regexCartao = RegExp(
      r'(?:X{4}|\*{4})\s?(?:X{4}|\*{4})\s?(?:X{4}|\*{4})\s?(\d{4})|(?:X{12}|\*{12})(\d{4})'
    );
    
    final match = regexCartao.firstMatch(texto);
    if (match != null) {
      final digitos = match.group(1) ?? match.group(2);
      return '**** $digitos';
    }
    return null;
  }

  static String? _extrairTipoTransacao(String texto) {
    final textoUpper = texto.toUpperCase();
    
    if (textoUpper.contains('DEBITO') || textoUpper.contains('DÉBITO')) {
      return 'DÉBITO';
    } else if (textoUpper.contains('CREDITO') || 
               textoUpper.contains('CRÉDITO') ||
               textoUpper.contains('A VISTA') ||
               textoUpper.contains('VENDA A CREDITO')) {
      return 'CRÉDITO';
    }
    return null;
  }

  static Map<String, String?> _extrairCidadeEstado(String texto) {
    final regexCidadeEstado = RegExp(
      r'([A-ZÁÀÂÃÉÈÊÍÏÓÔÕÖÚÇÑ][a-záàâãéèêíïóôõöúçñ\s]+)\s*[-/]?\s*([A-Z]{2})\b'
    );
    
    final match = regexCidadeEstado.firstMatch(texto);
    if (match != null) {
      final cidade = match.group(1)?.trim();
      final estado = match.group(2)?.toUpperCase();
      
      const estadosValidos = [
        'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
        'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
        'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
      ];
      
      if (estado != null && estadosValidos.contains(estado)) {
        return {'cidade': cidade, 'estado': estado};
      }
    }
    
    return {'cidade': null, 'estado': null};
  }
}

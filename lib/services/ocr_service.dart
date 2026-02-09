import '../models/comprovante.dart';

/// OCR Service simplificado - compatível com Firebase
/// Remove dependência do Google ML Kit para evitar conflitos
class OCRService {
  // Processar imagem e extrair texto (modo simplificado)
  static Future<String> extrairTextoImagem(String imagemPath) async {
    // TODO: Implementar OCR alternativo ou integração com serviço online
    // Por enquanto, retorna mensagem informativa
    return 'OCR temporariamente desabilitado - aguardando implementação alternativa';
  }

  // Analisar texto do comprovante e extrair informações
  static Future<Comprovante?> processarComprovanteCartao(String imagemPath) async {
    try {
      // Cria comprovante básico com imagem
      final comprovante = Comprovante(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        estabelecimento: 'Aguardando OCR',
        produto: 'Processamento manual necessário',
        valor: null,
        cartaoCredito: null,
        bandeira: null,
        dataTransacao: null,
        imagemPath: imagemPath,
        textoOCR: 'OCR temporariamente desabilitado',
        dataCadastro: DateTime.now(),
      );

      return comprovante;
    } catch (e) {
      return null;
    }
  }

  // Extrair dados específicos do texto do comprovante
  static Map<String, dynamic> _extrairDadosComprovante(String texto) {
    final dados = <String, dynamic>{};

    // Converter para maiúsculas para facilitar busca
    final textoUpper = texto.toUpperCase();
    final linhas = texto.split('\n');

    // Extrair estabelecimento (geralmente primeira linha relevante)
    dados['estabelecimento'] = _extrairEstabelecimento(linhas);

    // Extrair valor (padrão: R$ 00,00 ou 00.00)
    dados['valor'] = _extrairValor(texto);

    // Extrair cartão (últimos 4 dígitos)
    dados['cartao'] = _extrairCartao(texto);

    // Extrair bandeira (VISA, MASTER, ELO, etc)
    dados['bandeira'] = _extrairBandeira(textoUpper);

    // Extrair data
    dados['data'] = _extrairData(texto);

    // Extrair produto/descrição
    dados['produto'] = _extrairProduto(linhas);

    return dados;
  }

  static String? _extrairEstabelecimento(List<String> linhas) {
    // Pega as primeiras linhas não vazias
    for (var linha in linhas) {
      if (linha.trim().isNotEmpty && linha.length > 3) {
        return linha.trim();
      }
    }
    return null;
  }

  static double? _extrairValor(String texto) {
    // Padrões: R$ 123,45 ou 123.45 ou TOTAL: 123,45
    final regexes = [
      RegExp(r'R\$\s*(\d+[.,]\d{2})'),
      RegExp(r'TOTAL[:\s]*(\d+[.,]\d{2})'),
      RegExp(r'VALOR[:\s]*(\d+[.,]\d{2})'),
      RegExp(r'(\d+[.,]\d{2})\s*R\$'),
    ];

    for (var regex in regexes) {
      final match = regex.firstMatch(texto);
      if (match != null) {
        final valorStr = match.group(1)?.replaceAll(',', '.');
        return double.tryParse(valorStr ?? '');
      }
    }
    return null;
  }

  static String? _extrairCartao(String texto) {
    // Padrão: **** 1234 ou ****1234
    final regex = RegExp(r'\*+\s*(\d{4})');
    final match = regex.firstMatch(texto);
    return match?.group(1);
  }

  static String? _extrairBandeira(String textoUpper) {
    final bandeiras = ['VISA', 'MASTER', 'MASTERCARD', 'ELO', 'AMEX', 'AMERICAN EXPRESS', 'HIPERCARD'];
    
    for (var bandeira in bandeiras) {
      if (textoUpper.contains(bandeira)) {
        if (bandeira == 'MASTERCARD') return 'MASTER';
        if (bandeira == 'AMERICAN EXPRESS') return 'AMEX';
        return bandeira;
      }
    }
    return null;
  }

  static DateTime? _extrairData(String texto) {
    // Padrões: DD/MM/YYYY ou DD-MM-YYYY ou DD.MM.YYYY
    final regex = RegExp(r'(\d{2})[/\-.](\d{2})[/\-.](\d{4})');
    final match = regex.firstMatch(texto);
    
    if (match != null) {
      final dia = int.tryParse(match.group(1) ?? '');
      final mes = int.tryParse(match.group(2) ?? '');
      final ano = int.tryParse(match.group(3) ?? '');
      
      if (dia != null && mes != null && ano != null) {
        try {
          return DateTime(ano, mes, dia);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  static String? _extrairProduto(List<String> linhas) {
    // Procura por linhas que parecem descrições de produtos
    for (var linha in linhas) {
      final linhaTrim = linha.trim();
      if (linhaTrim.length > 5 && 
          linhaTrim.length < 100 && 
          !linhaTrim.contains('*') &&
          !linhaTrim.toUpperCase().contains('VISA') &&
          !linhaTrim.toUpperCase().contains('MASTER')) {
        return linhaTrim;
      }
    }
    return null;
  }

  // Limpar recursos
  static void dispose() {
    // Nada a fazer na versão simplificada
  }
}

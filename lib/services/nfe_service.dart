import '../models/nota_fiscal.dart';
import '../models/produto.dart';

class NFeService {
  // API da Receita Federal para consulta de NF-e
  static const String baseUrl = 'https://www.nfe.fazenda.gov.br/portal/consultaRecaptcha.aspx';
  
  // Serviço alternativo de consulta (SEFAZ)
  static const String sefazUrl = 'https://www.sefaz.rs.gov.br/nfce/consulta';

  // Consultar NF-e pela chave de acesso extraída do QR Code
  static Future<Map<String, dynamic>?> consultarNFePorChave(String chaveAcesso) async {
    try {
      // Validar formato da chave (44 dígitos)
      if (chaveAcesso.length != 44) {
        throw Exception('Chave de acesso inválida. Deve conter 44 dígitos.');
      }

      // Extrair informações da chave de acesso
      final dados = _extrairDadosChave(chaveAcesso);

      // Simular consulta (em produção, aqui seria feita a chamada real à API)
      // A API real requer CAPTCHA e autenticação complexa
      // Por isso, vamos extrair o máximo de informações da chave e do QR Code
      
      return dados;
    } catch (e) {
      return null;
    }
  }

  // Extrair informações básicas da chave de acesso da NF-e
  static Map<String, dynamic> _extrairDadosChave(String chave) {
    // Formato da chave: AAMMCCCNNNNNSSSSTTTTTTTTTTDDDDDD
    // AA = UF
    // MM = Ano/Mês de emissão
    // CCC = CNPJ do emitente (primeiros 3 dígitos)
    // NNNNN = Modelo
    // SSSS = Série
    // TTTTTTTTTT = Número da nota
    // DDDDDD = Código numérico + dígito verificador

    final uf = chave.substring(0, 2);
    final ano = '20${chave.substring(2, 4)}';
    final mes = chave.substring(4, 6);
    final cnpj = chave.substring(6, 20);
    final modelo = chave.substring(20, 22);
    final serie = chave.substring(22, 25);
    final numero = chave.substring(25, 34);

    return {
      'chave_acesso': chave,
      'uf': uf,
      'ano': ano,
      'mes': mes,
      'cnpj_emitente': cnpj,
      'modelo': modelo,
      'serie': serie,
      'numero_nota': numero,
      'data_emissao_estimada': '$ano-$mes-01',
    };
  }

  // Processar dados do QR Code da NF-e
  static Future<NotaFiscal?> processarQRCodeNFe(String qrCodeData) async {
    try {
      // O QR Code contém a URL com parâmetros
      final uri = Uri.parse(qrCodeData);
      final params = uri.queryParameters;

      // Extrair chave de acesso
      String? chaveAcesso = params['chNFe'] ?? params['p'];

      if (chaveAcesso == null || chaveAcesso.isEmpty) {
        // Tentar extrair da URL diretamente
        final regex = RegExp(r'\d{44}');
        final match = regex.firstMatch(qrCodeData);
        chaveAcesso = match?.group(0);
      }

      if (chaveAcesso == null) {
        throw Exception('Chave de acesso não encontrada no QR Code');
      }

      // Consultar dados da NF-e
      final dados = await consultarNFePorChave(chaveAcesso);

      if (dados == null) {
        throw Exception('Erro ao consultar nota fiscal');
      }

      // Criar objeto NotaFiscal
      final notaFiscal = NotaFiscal(
        id: chaveAcesso,
        chaveAcesso: chaveAcesso,
        numeroNota: dados['numero_nota'],
        serie: dados['serie'],
        dataEmissao: DateTime.tryParse(dados['data_emissao_estimada']) ?? DateTime.now(),
        cnpjEmitente: dados['cnpj_emitente'],
        dataCadastro: DateTime.now(),
        origem: 'scanner', // Marcando como scanner
      );

      return notaFiscal;
    } catch (e) {
      return null;
    }
  }

  // Criar produtos de exemplo a partir da nota fiscal
  // Em produção, isso viria dos dados XML da NF-e
  static List<Produto> criarProdutosExemplo(NotaFiscal notaFiscal) {
    final produtos = <Produto>[];
    
    // Produtos de exemplo (em produção, viriam do XML)
    final produtosExemplo = [
      {
        'nome': 'Smartphone Samsung Galaxy',
        'preco': 1899.90,
        'categoria': 'Eletrônicos',
        'mesesGarantia': 12,
        'codigoBarras': '7891234567890',
      },
      {
        'nome': 'Notebook Dell Inspiron',
        'preco': 3499.00,
        'categoria': 'Informática',
        'mesesGarantia': 12,
        'codigoBarras': '7891234567891',
      },
      {
        'nome': 'Smart TV LG 50"',
        'preco': 2299.00,
        'categoria': 'Eletrônicos',
        'mesesGarantia': 12,
        'codigoBarras': '7891234567892',
      },
    ];

    for (var i = 0; i < produtosExemplo.length; i++) {
      final prod = produtosExemplo[i];
      final meses = prod['mesesGarantia'] as int;
      
      produtos.add(Produto(
        id: '${notaFiscal.id}_prod_$i',
        nome: prod['nome'] as String,
        preco: prod['preco'] as double,
        categoria: prod['categoria'] as String,
        dataCompra: notaFiscal.dataEmissao,
        dataVencimentoGarantia: notaFiscal.dataEmissao.add(Duration(days: meses * 30)),
        notaFiscalId: notaFiscal.id,
        estabelecimento: notaFiscal.nomeEmitente,
        cnpjEstabelecimento: notaFiscal.cnpjEmitente,
        garantiaAtiva: true,
        codigoBarras: prod['codigoBarras'] as String, // OBRIGATÓRIO no QR Code
        origem: 'scanner', // Marcando como origem scanner
      ));
    }

    return produtos;
  }
}

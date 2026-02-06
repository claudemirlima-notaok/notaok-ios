import '../models/produto.dart';
import '../models/nota_fiscal.dart';
import '../models/comprovante.dart';
import '../models/avaliacao.dart';
import '../services/hive_service.dart';

class DadosExemplo {
  static Future<void> adicionarDadosExemplo() async {
    // Limpar dados existentes
    final produtos = HiveService.getTodosProdutos();
    for (var produto in produtos) {
      await HiveService.deletarProduto(produto.id);
    }

    final notas = HiveService.getTodasNotasFiscais();
    for (var nota in notas) {
      await HiveService.deletarNotaFiscal(nota.id);
    }

    // Criar nota fiscal de exemplo
    final notaFiscal = NotaFiscal(
      id: 'nfe_exemplo_001',
      chaveAcesso: '12345678901234567890123456789012345678901234',
      numeroNota: '000123',
      serie: '001',
      dataEmissao: DateTime.now().subtract(const Duration(days: 30)),
      nomeEmitente: 'Magazine Luiza S/A',
      cnpjEmitente: '47960950000121',
      valorTotal: 1899.90,
      dataCadastro: DateTime.now(),
      origem: 'scanner',
    );
    await HiveService.adicionarNotaFiscal(notaFiscal);

    // Criar produtos de exemplo
    final produtosExemplo = [
      Produto(
        id: 'prod_001',
        nome: 'Smartphone Samsung Galaxy S23',
        descricao: 'Smartphone com 128GB de armazenamento',
        preco: 1899.90,
        categoria: 'Eletrônicos',
        dataCompra: DateTime.now().subtract(const Duration(days: 30)),
        dataVencimentoGarantia: DateTime.now().add(const Duration(days: 335)), // 11 meses restantes
        notaFiscalId: notaFiscal.id,
        estabelecimento: 'Magazine Luiza',
        cnpjEstabelecimento: '47960950000121',
        garantiaAtiva: true,
        codigoBarras: '7891234567890',
        codigoProduto: 'SM-S911B',
        origem: 'scanner',
      ),
      Produto(
        id: 'prod_002',
        nome: 'Notebook Dell Inspiron 15',
        descricao: 'Notebook i5, 8GB RAM, 256GB SSD',
        preco: 3299.00,
        categoria: 'Informática',
        dataCompra: DateTime.now().subtract(const Duration(days: 90)),
        dataVencimentoGarantia: DateTime.now().add(const Duration(days: 275)), // 9 meses restantes
        notaFiscalId: notaFiscal.id,
        estabelecimento: 'Magazine Luiza',
        cnpjEstabelecimento: '47960950000121',
        garantiaAtiva: true,
        codigoBarras: '7891234567891',
        codigoProduto: 'I15-3520-A10P',
        origem: 'scanner',
      ),
      Produto(
        id: 'prod_003',
        nome: 'Smart TV LG 50" 4K',
        descricao: 'Smart TV LED 50 polegadas Ultra HD 4K',
        preco: 2199.00,
        categoria: 'Eletrônicos',
        dataCompra: DateTime.now().subtract(const Duration(days: 350)),
        dataVencimentoGarantia: DateTime.now().add(const Duration(days: 15)), // Expirando em breve!
        notaFiscalId: notaFiscal.id,
        estabelecimento: 'Magazine Luiza',
        cnpjEstabelecimento: '47960950000121',
        garantiaAtiva: true,
        codigoBarras: '7891234567892',
        codigoProduto: '50UP7750PSB',
        origem: 'scanner',
      ),
      Produto(
        id: 'prod_004',
        nome: 'Geladeira Brastemp Frost Free',
        descricao: 'Geladeira 400L com Frost Free',
        preco: 2599.00,
        categoria: 'Eletrodomésticos',
        dataCompra: DateTime.now().subtract(const Duration(days: 180)),
        dataVencimentoGarantia: DateTime.now().add(const Duration(days: 185)), // 6 meses restantes
        notaFiscalId: notaFiscal.id,
        estabelecimento: 'Magazine Luiza',
        cnpjEstabelecimento: '47960950000121',
        garantiaAtiva: true,
        codigoBarras: '7891234567893',
        codigoProduto: 'BRE59AB-006',
        origem: 'scanner',
      ),
    ];

    for (var produto in produtosExemplo) {
      await HiveService.adicionarProduto(produto);
    }

    // Adicionar avaliação para o primeiro produto
    final avaliacao = Avaliacao(
      id: 'aval_001',
      produtoId: produtosExemplo[0].id,
      estabelecimento: 'Magazine Luiza',
      cnpjEstabelecimento: '47960950000121',
      notaLoja: 5,
      notaProduto: 4,
      notaVendedor: 5,
      notaAtendimento: 4,
      comentario: 'Ótima experiência de compra! Produto chegou rápido e bem embalado.',
      dataAvaliacao: DateTime.now(),
    );
    await HiveService.adicionarAvaliacao(avaliacao);

    // Adicionar comprovante de exemplo (simulando o da imagem)
    final comprovante = Comprovante(
      id: 'comp_001',
      estabelecimento: 'GELO PagBank',
      produto: 'VENDA DEBITO MAESTRO',
      valor: 30.00,
      cartaoCredito: '7817',
      bandeira: 'MAESTRO',
      dataTransacao: DateTime(2025, 11, 14, 9, 25),
      textoOCR: 'GELO PagBank VIA ESTABELECIMENTO R\$ 30,00 14/Nov/2025 09:25 VENDA DEBITO MAESTRO',
      dataCadastro: DateTime.now(),
      avaliacaoRealizada: false,
    );
    await HiveService.adicionarComprovante(comprovante);
  }
}

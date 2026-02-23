import 'package:hive/hive.dart';

part 'produto.g.dart';

@HiveType(typeId: 0)
class Produto extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String? descricao;

  @HiveField(3)
  double? preco;

  @HiveField(4)
  DateTime dataCompra;

  @HiveField(5)
  DateTime dataVencimentoGarantia;

  @HiveField(6)
  String? categoria;

  @HiveField(7)
  String? imagemUrl;

  @HiveField(8)
  String? notaFiscalId; // OPCIONAL - vínculo com nota fiscal

  @HiveField(9)
  String? estabelecimento;

  @HiveField(10)
  String? cnpjEstabelecimento;

  @HiveField(11)
  bool garantiaAtiva;

  @HiveField(12)
  String? codigoBarras; // Código de barras do produto

  @HiveField(13)
  String? codigoProduto; // Código do produto (SKU, referência, etc.)

  @HiveField(14)
  String origem; // 'manual' ou 'scanner' - identifica a origem do cadastro

  Produto({
    required this.id,
    required this.nome,
    this.descricao,
    this.preco,
    required this.dataCompra,
    required this.dataVencimentoGarantia,
    this.categoria,
    this.imagemUrl,
    this.notaFiscalId, // Agora é opcional
    this.estabelecimento,
    this.cnpjEstabelecimento,
    this.garantiaAtiva = true,
    this.codigoBarras,
    this.codigoProduto,
    this.origem = 'scanner', // Padrão é scanner (para compatibilidade com dados antigos)
  });

  // Calcula dias restantes da garantia
  int get diasRestantesGarantia {
    final now = DateTime.now();
    if (now.isAfter(dataVencimentoGarantia)) return 0;
    return dataVencimentoGarantia.difference(now).inDays;
  }

  // Status da garantia
  String get statusGarantia {
    final dias = diasRestantesGarantia;
    if (dias == 0) return 'Vencida';
    if (dias <= 30) return 'Expira em breve';
    return 'Ativa';
  }

  // Converter para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'dataCompra': dataCompra.toIso8601String(),
      'dataVencimentoGarantia': dataVencimentoGarantia.toIso8601String(),
      'categoria': categoria,
      'imagemUrl': imagemUrl,
      'notaFiscalId': notaFiscalId,
      'estabelecimento': estabelecimento,
      'cnpjEstabelecimento': cnpjEstabelecimento,
      'garantiaAtiva': garantiaAtiva,
      'codigoBarras': codigoBarras,
      'codigoProduto': codigoProduto,
    };
  }

  // Criar a partir de Map
  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      preco: map['preco']?.toDouble(),
      dataCompra: DateTime.parse(map['dataCompra']),
      dataVencimentoGarantia: DateTime.parse(map['dataVencimentoGarantia']),
      categoria: map['categoria'],
      imagemUrl: map['imagemUrl'],
      notaFiscalId: map['notaFiscalId'] ?? '', // Se não tiver, usa string vazia
      estabelecimento: map['estabelecimento'],
      cnpjEstabelecimento: map['cnpjEstabelecimento'],
      garantiaAtiva: map['garantiaAtiva'] ?? true,
      codigoBarras: map['codigoBarras'],
      codigoProduto: map['codigoProduto'],
    );
  }
}

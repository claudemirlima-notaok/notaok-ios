import 'package:hive/hive.dart';

part 'avaliacao.g.dart';

@HiveType(typeId: 2)
class Avaliacao extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? produtoId;

  @HiveField(2)
  String? notaFiscalId;

  @HiveField(3)
  String? estabelecimento;

  @HiveField(4)
  String? cnpjEstabelecimento;

  @HiveField(5)
  int notaLoja; // 1 a 5

  @HiveField(6)
  int notaProduto; // 1 a 5

  @HiveField(7)
  int notaVendedor; // 1 a 5

  @HiveField(8)
  int notaAtendimento; // 1 a 5

  @HiveField(9)
  String? comentario;

  @HiveField(10)
  DateTime dataAvaliacao;

  @HiveField(11)
  List<String>? categoriasAvaliadas;

  Avaliacao({
    required this.id,
    this.produtoId,
    this.notaFiscalId,
    this.estabelecimento,
    this.cnpjEstabelecimento,
    required this.notaLoja,
    required this.notaProduto,
    required this.notaVendedor,
    required this.notaAtendimento,
    this.comentario,
    required this.dataAvaliacao,
    this.categoriasAvaliadas,
  });

  // Média geral das avaliações
  double get mediaGeral {
    return (notaLoja + notaProduto + notaVendedor + notaAtendimento) / 4;
  }

  // Converter para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produtoId': produtoId,
      'notaFiscalId': notaFiscalId,
      'estabelecimento': estabelecimento,
      'cnpjEstabelecimento': cnpjEstabelecimento,
      'notaLoja': notaLoja,
      'notaProduto': notaProduto,
      'notaVendedor': notaVendedor,
      'notaAtendimento': notaAtendimento,
      'comentario': comentario,
      'dataAvaliacao': dataAvaliacao.toIso8601String(),
      'categoriasAvaliadas': categoriasAvaliadas,
    };
  }

  // Criar a partir de Map
  factory Avaliacao.fromMap(Map<String, dynamic> map) {
    return Avaliacao(
      id: map['id'],
      produtoId: map['produtoId'],
      notaFiscalId: map['notaFiscalId'],
      estabelecimento: map['estabelecimento'],
      cnpjEstabelecimento: map['cnpjEstabelecimento'],
      notaLoja: map['notaLoja'],
      notaProduto: map['notaProduto'],
      notaVendedor: map['notaVendedor'],
      notaAtendimento: map['notaAtendimento'],
      comentario: map['comentario'],
      dataAvaliacao: DateTime.parse(map['dataAvaliacao']),
      categoriasAvaliadas: map['categoriasAvaliadas'] != null 
          ? List<String>.from(map['categoriasAvaliadas']) 
          : null,
    );
  }
}

import 'package:hive/hive.dart';

part 'comprovante.g.dart';

@HiveType(typeId: 3)
class Comprovante extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? estabelecimento;

  @HiveField(2)
  String? produto;

  @HiveField(3)
  double? valor;

  @HiveField(4)
  String? cartaoCredito; // últimos 4 dígitos

  @HiveField(5)
  String? bandeira; // Visa, Master, etc

  @HiveField(6)
  DateTime? dataTransacao;

  @HiveField(7)
  String? imagemPath;

  @HiveField(8)
  String? textoOCR;

  @HiveField(9)
  DateTime dataCadastro;

  @HiveField(10)
  String? produtoId;

  @HiveField(11)
  bool avaliacaoRealizada;

  Comprovante({
    required this.id,
    this.estabelecimento,
    this.produto,
    this.valor,
    this.cartaoCredito,
    this.bandeira,
    this.dataTransacao,
    this.imagemPath,
    this.textoOCR,
    required this.dataCadastro,
    this.produtoId,
    this.avaliacaoRealizada = false,
  });

  // Converter para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estabelecimento': estabelecimento,
      'produto': produto,
      'valor': valor,
      'cartaoCredito': cartaoCredito,
      'bandeira': bandeira,
      'dataTransacao': dataTransacao?.toIso8601String(),
      'imagemPath': imagemPath,
      'textoOCR': textoOCR,
      'dataCadastro': dataCadastro.toIso8601String(),
      'produtoId': produtoId,
      'avaliacaoRealizada': avaliacaoRealizada,
    };
  }

  // Criar a partir de Map
  factory Comprovante.fromMap(Map<String, dynamic> map) {
    return Comprovante(
      id: map['id'],
      estabelecimento: map['estabelecimento'],
      produto: map['produto'],
      valor: map['valor']?.toDouble(),
      cartaoCredito: map['cartaoCredito'],
      bandeira: map['bandeira'],
      dataTransacao: map['dataTransacao'] != null 
          ? DateTime.parse(map['dataTransacao']) 
          : null,
      imagemPath: map['imagemPath'],
      textoOCR: map['textoOCR'],
      dataCadastro: DateTime.parse(map['dataCadastro']),
      produtoId: map['produtoId'],
      avaliacaoRealizada: map['avaliacaoRealizada'] ?? false,
    );
  }
}

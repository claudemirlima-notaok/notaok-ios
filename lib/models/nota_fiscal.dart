import 'package:hive/hive.dart';

part 'nota_fiscal.g.dart';

@HiveType(typeId: 1)
class NotaFiscal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String chaveAcesso;

  @HiveField(2)
  String? numeroNota;

  @HiveField(3)
  String? serie;

  @HiveField(4)
  DateTime dataEmissao;

  @HiveField(5)
  String? nomeEmitente;

  @HiveField(6)
  String? cnpjEmitente;

  @HiveField(7)
  String? enderecoEmitente;

  @HiveField(8)
  double? valorTotal;

  @HiveField(9)
  String? pdfPath;

  @HiveField(10)
  String? xmlData;

  @HiveField(11)
  List<String>? produtosIds;

  @HiveField(12)
  DateTime dataCadastro;

  @HiveField(13)
  String? nomeVendedor;

  @HiveField(14)
  String? imagemNotaPath;

  @HiveField(15)
  String origem; // 'manual' ou 'scanner'

  NotaFiscal({
    required this.id,
    required this.chaveAcesso,
    this.numeroNota,
    this.serie,
    required this.dataEmissao,
    this.nomeEmitente,
    this.cnpjEmitente,
    this.enderecoEmitente,
    this.valorTotal,
    this.pdfPath,
    this.xmlData,
    this.produtosIds,
    required this.dataCadastro,
    this.nomeVendedor,
    this.imagemNotaPath,
    this.origem = 'scanner', // Padrão scanner para compatibilidade
  });

  // Converter para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chaveAcesso': chaveAcesso,
      'numeroNota': numeroNota,
      'serie': serie,
      'dataEmissao': dataEmissao.toIso8601String(),
      'nomeEmitente': nomeEmitente,
      'cnpjEmitente': cnpjEmitente,
      'enderecoEmitente': enderecoEmitente,
      'valorTotal': valorTotal,
      'pdfPath': pdfPath,
      'xmlData': xmlData,
      'produtosIds': produtosIds,
      'dataCadastro': dataCadastro.toIso8601String(),
      'nomeVendedor': nomeVendedor,
      'imagemNotaPath': imagemNotaPath,
      'origem': origem,
    };
  }

  // Criar a partir de Map
  factory NotaFiscal.fromMap(Map<String, dynamic> map) {
    return NotaFiscal(
      id: map['id'],
      chaveAcesso: map['chaveAcesso'],
      numeroNota: map['numeroNota'],
      serie: map['serie'],
      dataEmissao: DateTime.parse(map['dataEmissao']),
      nomeEmitente: map['nomeEmitente'],
      cnpjEmitente: map['cnpjEmitente'],
      enderecoEmitente: map['enderecoEmitente'],
      valorTotal: map['valorTotal']?.toDouble(),
      pdfPath: map['pdfPath'],
      xmlData: map['xmlData'],
      produtosIds: map['produtosIds'] != null 
          ? List<String>.from(map['produtosIds']) 
          : null,
      dataCadastro: DateTime.parse(map['dataCadastro']),
      nomeVendedor: map['nomeVendedor'],
      imagemNotaPath: map['imagemNotaPath'],
      origem: map['origem'] ?? 'scanner',
    );
  }
}

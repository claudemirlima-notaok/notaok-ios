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
  String? bandeira; // Visa, Master, Elo, etc

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

  // ✅ NOVOS CAMPOS ADICIONADOS

  @HiveField(12)
  String? tipoTransacao; // 'CRÉDITO' ou 'DÉBITO'

  @HiveField(13)
  String? cnpj; // CNPJ do estabelecimento

  @HiveField(14)
  String? cidade; // Cidade do estabelecimento

  @HiveField(15)
  String? estado; // Estado (UF) do estabelecimento

  @HiveField(16)
  double? latitude; // Latitude da localização onde foi capturado

  @HiveField(17)
  double? longitude; // Longitude da localização onde foi capturado

  @HiveField(18)
  String? enderecoCaptura; // Endereço completo da captura (opcional)

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
    // Novos campos
    this.tipoTransacao,
    this.cnpj,
    this.cidade,
    this.estado,
    this.latitude,
    this.longitude,
    this.enderecoCaptura,
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
      'tipoTransacao': tipoTransacao,
      'cnpj': cnpj,
      'cidade': cidade,
      'estado': estado,
      'latitude': latitude,
      'longitude': longitude,
      'enderecoCaptura': enderecoCaptura,
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
      tipoTransacao: map['tipoTransacao'],
      cnpj: map['cnpj'],
      cidade: map['cidade'],
      estado: map['estado'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      enderecoCaptura: map['enderecoCaptura'],
    );
  }

  // Helpers para exibição
  String get tipoTransacaoFormatado => tipoTransacao ?? 'N/A';
  String get cnpjFormatado {
    if (cnpj == null || cnpj!.length != 14) return cnpj ?? 'N/A';
    return '${cnpj!.substring(0, 2)}.${cnpj!.substring(2, 5)}.${cnpj!.substring(5, 8)}/${cnpj!.substring(8, 12)}-${cnpj!.substring(12, 14)}';
  }
  String get localizacaoFormatada {
    if (cidade != null && estado != null) {
      return '$cidade - $estado';
    }
    if (cidade != null) return cidade!;
    if (estado != null) return estado!;
    return 'N/A';
  }
  bool get temLocalizacao => latitude != null && longitude != null;
}

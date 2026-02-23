// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProdutoAdapter extends TypeAdapter<Produto> {
  @override
  final int typeId = 0;

  @override
  Produto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Produto(
      id: fields[0] as String,
      nome: fields[1] as String,
      descricao: fields[2] as String?,
      preco: fields[3] as double?,
      dataCompra: fields[4] as DateTime,
      dataVencimentoGarantia: fields[5] as DateTime,
      categoria: fields[6] as String?,
      imagemUrl: fields[7] as String?,
      notaFiscalId: fields[8] as String?,
      estabelecimento: fields[9] as String?,
      cnpjEstabelecimento: fields[10] as String?,
      garantiaAtiva: fields[11] as bool,
      codigoBarras: fields[12] as String?,
      codigoProduto: fields[13] as String?,
      origem: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Produto obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.descricao)
      ..writeByte(3)
      ..write(obj.preco)
      ..writeByte(4)
      ..write(obj.dataCompra)
      ..writeByte(5)
      ..write(obj.dataVencimentoGarantia)
      ..writeByte(6)
      ..write(obj.categoria)
      ..writeByte(7)
      ..write(obj.imagemUrl)
      ..writeByte(8)
      ..write(obj.notaFiscalId)
      ..writeByte(9)
      ..write(obj.estabelecimento)
      ..writeByte(10)
      ..write(obj.cnpjEstabelecimento)
      ..writeByte(11)
      ..write(obj.garantiaAtiva)
      ..writeByte(12)
      ..write(obj.codigoBarras)
      ..writeByte(13)
      ..write(obj.codigoProduto)
      ..writeByte(14)
      ..write(obj.origem);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProdutoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

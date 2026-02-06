// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avaliacao.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AvaliacaoAdapter extends TypeAdapter<Avaliacao> {
  @override
  final int typeId = 2;

  @override
  Avaliacao read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Avaliacao(
      id: fields[0] as String,
      produtoId: fields[1] as String?,
      notaFiscalId: fields[2] as String?,
      estabelecimento: fields[3] as String?,
      cnpjEstabelecimento: fields[4] as String?,
      notaLoja: fields[5] as int,
      notaProduto: fields[6] as int,
      notaVendedor: fields[7] as int,
      notaAtendimento: fields[8] as int,
      comentario: fields[9] as String?,
      dataAvaliacao: fields[10] as DateTime,
      categoriasAvaliadas: (fields[11] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Avaliacao obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.produtoId)
      ..writeByte(2)
      ..write(obj.notaFiscalId)
      ..writeByte(3)
      ..write(obj.estabelecimento)
      ..writeByte(4)
      ..write(obj.cnpjEstabelecimento)
      ..writeByte(5)
      ..write(obj.notaLoja)
      ..writeByte(6)
      ..write(obj.notaProduto)
      ..writeByte(7)
      ..write(obj.notaVendedor)
      ..writeByte(8)
      ..write(obj.notaAtendimento)
      ..writeByte(9)
      ..write(obj.comentario)
      ..writeByte(10)
      ..write(obj.dataAvaliacao)
      ..writeByte(11)
      ..write(obj.categoriasAvaliadas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvaliacaoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

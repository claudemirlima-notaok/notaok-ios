// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comprovante.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComprovanteAdapter extends TypeAdapter<Comprovante> {
  @override
  final int typeId = 3;

  @override
  Comprovante read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Comprovante(
      id: fields[0] as String,
      estabelecimento: fields[1] as String?,
      produto: fields[2] as String?,
      valor: fields[3] as double?,
      cartaoCredito: fields[4] as String?,
      bandeira: fields[5] as String?,
      dataTransacao: fields[6] as DateTime?,
      imagemPath: fields[7] as String?,
      textoOCR: fields[8] as String?,
      dataCadastro: fields[9] as DateTime,
      produtoId: fields[10] as String?,
      avaliacaoRealizada: fields[11] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Comprovante obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.estabelecimento)
      ..writeByte(2)
      ..write(obj.produto)
      ..writeByte(3)
      ..write(obj.valor)
      ..writeByte(4)
      ..write(obj.cartaoCredito)
      ..writeByte(5)
      ..write(obj.bandeira)
      ..writeByte(6)
      ..write(obj.dataTransacao)
      ..writeByte(7)
      ..write(obj.imagemPath)
      ..writeByte(8)
      ..write(obj.textoOCR)
      ..writeByte(9)
      ..write(obj.dataCadastro)
      ..writeByte(10)
      ..write(obj.produtoId)
      ..writeByte(11)
      ..write(obj.avaliacaoRealizada);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComprovanteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

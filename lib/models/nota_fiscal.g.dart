// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nota_fiscal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotaFiscalAdapter extends TypeAdapter<NotaFiscal> {
  @override
  final int typeId = 1;

  @override
  NotaFiscal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotaFiscal(
      id: fields[0] as String,
      chaveAcesso: fields[1] as String,
      numeroNota: fields[2] as String?,
      serie: fields[3] as String?,
      dataEmissao: fields[4] as DateTime,
      nomeEmitente: fields[5] as String?,
      cnpjEmitente: fields[6] as String?,
      enderecoEmitente: fields[7] as String?,
      valorTotal: fields[8] as double?,
      pdfPath: fields[9] as String?,
      xmlData: fields[10] as String?,
      produtosIds: (fields[11] as List?)?.cast<String>(),
      dataCadastro: fields[12] as DateTime,
      nomeVendedor: fields[13] as String?,
      imagemNotaPath: fields[14] as String?,
      origem: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NotaFiscal obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chaveAcesso)
      ..writeByte(2)
      ..write(obj.numeroNota)
      ..writeByte(3)
      ..write(obj.serie)
      ..writeByte(4)
      ..write(obj.dataEmissao)
      ..writeByte(5)
      ..write(obj.nomeEmitente)
      ..writeByte(6)
      ..write(obj.cnpjEmitente)
      ..writeByte(7)
      ..write(obj.enderecoEmitente)
      ..writeByte(8)
      ..write(obj.valorTotal)
      ..writeByte(9)
      ..write(obj.pdfPath)
      ..writeByte(10)
      ..write(obj.xmlData)
      ..writeByte(11)
      ..write(obj.produtosIds)
      ..writeByte(12)
      ..write(obj.dataCadastro)
      ..writeByte(13)
      ..write(obj.nomeVendedor)
      ..writeByte(14)
      ..write(obj.imagemNotaPath)
      ..writeByte(15)
      ..write(obj.origem);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotaFiscalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

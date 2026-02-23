// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsuarioAdapter extends TypeAdapter<Usuario> {
  @override
  final int typeId = 4;

  @override
  Usuario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Usuario(
      id: fields[0] as String,
      nome: fields[1] as String,
      email: fields[2] as String,
      cpf: fields[3] as String,
      telefone: fields[4] as String,
      dataNascimento: fields[5] as String?,
      foto: fields[6] as String?,
      tipoLogin: fields[7] as String?,
      emailVerificado: fields[8] as bool,
      dataCadastro: fields[9] as DateTime?,
      ultimaAtualizacao: fields[10] as DateTime?,
      enderecos: (fields[11] as List?)?.cast<Endereco>(),
    );
  }

  @override
  void write(BinaryWriter writer, Usuario obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.cpf)
      ..writeByte(4)
      ..write(obj.telefone)
      ..writeByte(5)
      ..write(obj.dataNascimento)
      ..writeByte(6)
      ..write(obj.foto)
      ..writeByte(7)
      ..write(obj.tipoLogin)
      ..writeByte(8)
      ..write(obj.emailVerificado)
      ..writeByte(9)
      ..write(obj.dataCadastro)
      ..writeByte(10)
      ..write(obj.ultimaAtualizacao)
      ..writeByte(11)
      ..write(obj.enderecos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnderecoAdapter extends TypeAdapter<Endereco> {
  @override
  final int typeId = 5;

  @override
  Endereco read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Endereco(
      id: fields[0] as String,
      apelido: fields[1] as String,
      cep: fields[2] as String,
      logradouro: fields[3] as String,
      numero: fields[4] as String,
      complemento: fields[5] as String?,
      bairro: fields[6] as String,
      cidade: fields[7] as String,
      estado: fields[8] as String,
      principal: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Endereco obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.apelido)
      ..writeByte(2)
      ..write(obj.cep)
      ..writeByte(3)
      ..write(obj.logradouro)
      ..writeByte(4)
      ..write(obj.numero)
      ..writeByte(5)
      ..write(obj.complemento)
      ..writeByte(6)
      ..write(obj.bairro)
      ..writeByte(7)
      ..write(obj.cidade)
      ..writeByte(8)
      ..write(obj.estado)
      ..writeByte(9)
      ..write(obj.principal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnderecoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

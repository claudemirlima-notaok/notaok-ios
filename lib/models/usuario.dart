import 'package:hive/hive.dart';

part 'usuario.g.dart';

@HiveType(typeId: 4)
class Usuario extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nome;

  @HiveField(2)
  late String email;

  @HiveField(3)
  late String cpf; // CPF como chave única de validação

  @HiveField(4)
  late String telefone;

  @HiveField(5)
  String? dataNascimento;

  @HiveField(6)
  String? foto;

  @HiveField(7)
  String? tipoLogin; // 'email', 'google', 'facebook', 'apple', 'instagram'

  @HiveField(8)
  bool emailVerificado;

  @HiveField(9)
  DateTime dataCadastro;

  @HiveField(10)
  DateTime? ultimaAtualizacao;

  @HiveField(11)
  List<Endereco> enderecos;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.telefone,
    this.dataNascimento,
    this.foto,
    this.tipoLogin = 'email',
    this.emailVerificado = false,
    DateTime? dataCadastro,
    this.ultimaAtualizacao,
    List<Endereco>? enderecos,
  })  : dataCadastro = dataCadastro ?? DateTime.now(),
        enderecos = enderecos ?? [];

  // Método para validar CPF
  static bool validarCPF(String cpf) {
    // Remove caracteres não numéricos
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

    // Verifica se tem 11 dígitos
    if (cpf.length != 11) return false;

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

    // Valida primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int primeiroDigito = 11 - (soma % 11);
    if (primeiroDigito >= 10) primeiroDigito = 0;
    if (primeiroDigito != int.parse(cpf[9])) return false;

    // Valida segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    int segundoDigito = 11 - (soma % 11);
    if (segundoDigito >= 10) segundoDigito = 0;
    if (segundoDigito != int.parse(cpf[10])) return false;

    return true;
  }

  // Formata CPF (###.###.###-##)
  static String formatarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

  // Formata telefone ((##) #####-####)
  static String formatarTelefone(String telefone) {
    telefone = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    if (telefone.length == 11) {
      return '(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7, 11)}';
    }
    return telefone;
  }

  // Converter para mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'dataNascimento': dataNascimento,
      'foto': foto,
      'tipoLogin': tipoLogin,
      'emailVerificado': emailVerificado,
      'dataCadastro': dataCadastro.toIso8601String(),
      'ultimaAtualizacao': ultimaAtualizacao?.toIso8601String(),
      'enderecos': enderecos.map((e) => e.toMap()).toList(),
    };
  }

  // Criar a partir de um mapa
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      telefone: map['telefone'] ?? '',
      dataNascimento: map['dataNascimento'],
      foto: map['foto'],
      tipoLogin: map['tipoLogin'] ?? 'email',
      emailVerificado: map['emailVerificado'] ?? false,
      dataCadastro: map['dataCadastro'] != null
          ? DateTime.parse(map['dataCadastro'])
          : DateTime.now(),
      ultimaAtualizacao: map['ultimaAtualizacao'] != null
          ? DateTime.parse(map['ultimaAtualizacao'])
          : null,
      enderecos: map['enderecos'] != null
          ? (map['enderecos'] as List)
              .map((e) => Endereco.fromMap(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

@HiveType(typeId: 5)
class Endereco extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String apelido; // 'Casa', 'Trabalho', etc.

  @HiveField(2)
  late String cep;

  @HiveField(3)
  late String logradouro;

  @HiveField(4)
  late String numero;

  @HiveField(5)
  String? complemento;

  @HiveField(6)
  late String bairro;

  @HiveField(7)
  late String cidade;

  @HiveField(8)
  late String estado;

  @HiveField(9)
  bool principal;

  Endereco({
    required this.id,
    required this.apelido,
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    this.principal = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apelido': apelido,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'principal': principal,
    };
  }

  factory Endereco.fromMap(Map<String, dynamic> map) {
    return Endereco(
      id: map['id'] ?? '',
      apelido: map['apelido'] ?? '',
      cep: map['cep'] ?? '',
      logradouro: map['logradouro'] ?? '',
      numero: map['numero'] ?? '',
      complemento: map['complemento'],
      bairro: map['bairro'] ?? '',
      cidade: map['cidade'] ?? '',
      estado: map['estado'] ?? '',
      principal: map['principal'] ?? false,
    );
  }

  @override
  String toString() {
    return '$logradouro, $numero${complemento != null ? ', $complemento' : ''} - $bairro, $cidade/$estado - CEP: $cep';
  }
}

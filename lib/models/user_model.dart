class UserModel {
  final String id;
  final String nome;
  final String email;
  final String cpf;
  final String telefone;
  final DateTime dataNascimento;
  final EnderecoModel endereco;
  final String? loginSocial;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.telefone,
    required this.dataNascimento,
    required this.endereco,
    this.loginSocial,
  });

  // Método para converter de JSON para UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      cpf: json['cpf'] ?? '',
      telefone: json['telefone'] ?? '',
      dataNascimento: json['dataNascimento'] != null
          ? DateTime.parse(json['dataNascimento'])
          : DateTime.now(),
      endereco: json['endereco'] != null
          ? EnderecoModel.fromJson(json['endereco'])
          : EnderecoModel(
              cep: '',
              logradouro: '',
              numero: '',
              complemento: '',
              bairro: '',
              cidade: '',
              uf: '',
            ),
      loginSocial: json['loginSocial'],
    );
  }

  // Método para converter de UserModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'dataNascimento': dataNascimento.toIso8601String(),
      'endereco': endereco.toJson(),
      'loginSocial': loginSocial,
    };
  }

  // Método copyWith para criar uma nova instância com alguns campos alterados
  UserModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? cpf,
    String? telefone,
    DateTime? dataNascimento,
    EnderecoModel? endereco,
    String? loginSocial,
  }) {
    return UserModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      endereco: endereco ?? this.endereco,
      loginSocial: loginSocial ?? this.loginSocial,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, nome: $nome, email: $email, cpf: $cpf, telefone: $telefone, dataNascimento: $dataNascimento, endereco: $endereco, loginSocial: $loginSocial)';
  }
}

class EnderecoModel {
  final String cep;
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;  // OBRIGATÓRIO

  EnderecoModel({
    required this.cep,
    required this.logradouro,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,  // OBRIGATÓRIO SEMPRE
  });

  // Método para converter de JSON para EnderecoModel
  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    return EnderecoModel(
      cep: json['cep'] ?? '',
      logradouro: json['logradouro'] ?? '',
      numero: json['numero'] ?? '',
      complemento: json['complemento'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      uf: json['uf'] ?? json['estado'] ?? '',
    );
  }

  // Método para converter de EnderecoModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
    };
  }

  // Método copyWith para criar uma nova instância com alguns campos alterados
  EnderecoModel copyWith({
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? uf,
  }) {
    return EnderecoModel(
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
    );
  }

  @override
  String toString() {
    return 'EnderecoModel(cep: $cep, logradouro: $logradouro, numero: $numero, complemento: $complemento, bairro: $bairro, cidade: $cidade, uf: $uf)';
  }
}

// CLASSE ENDERECO SEPARADA (para compatibilidade com register_screen)
class Endereco {
  final String cep;
  final String logradouro;  // CORRETO: logradouro (não rua)
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;

  Endereco({
    required this.cep,
    required this.logradouro,  // PARÂMETRO CORRETO
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  @override
  String toString() {
    return 'Endereco(cep: $cep, logradouro: $logradouro, numero: $numero, complemento: $complemento, bairro: $bairro, cidade: $cidade, uf: $uf)';
  }
}
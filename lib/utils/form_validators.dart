class FormValidators {
  // VALIDAÇÕES EM PORTUGUÊS (para compatibilidade com arquivos antigos)
  static String? validarNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value.trim())) {
      return 'Nome deve conter apenas letras';
    }
    return null;
  }

  static String? validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? validarCPF(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CPF é obrigatório';
    }
    final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'CPF inválido';
    }
    // Validação dos dígitos verificadores
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int digito1 = 11 - (soma % 11);
    if (digito1 >= 10) digito1 = 0;
    if (int.parse(cpf[9]) != digito1) {
      return 'CPF inválido';
    }
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    int digito2 = 11 - (soma % 11);
    if (digito2 >= 10) digito2 = 0;
    if (int.parse(cpf[10]) != digito2) {
      return 'CPF inválido';
    }
    return null;
  }

  static String? validarTelefone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone é obrigatório';
    }
    final telefone = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (telefone.length < 10 || telefone.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    return null;
  }

  static String? validarCEP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CEP é obrigatório';
    }
    final cep = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) {
      return 'CEP deve ter 8 dígitos';
    }
    return null;
  }

  static String? validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Senha deve conter ao menos: 1 minúscula, 1 maiúscula, 1 número';
    }
    return null;
  }

  static String? validarConfirmarSenha(String? value, String senha) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != senha) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  static String? validarObrigatorio(String? value, [String? campo]) {
    if (value == null || value.trim().isEmpty) {
      return '${campo ?? 'Campo'} é obrigatório';
    }
    return null;
  }

  // VALIDAÇÕES EM INGLÊS (para compatibilidade com telas atuais)
  static String? validateEmail(String? value) => validarEmail(value);
  static String? validateFullName(String? value) => validarNome(value);
  static String? validateCPF(String? value) => validarCPF(value);
  static String? validatePassword(String? value) => validarSenha(value);
  static String? validateCEP(String? value) => validarCEP(value);

  static String? validateConfirmPassword(String? value, String password) {
    return validarConfirmarSenha(value, password);
  }

  static String? validateRequired(String? value, [String? field]) {
    return validarObrigatorio(value, field);
  }

  static String? validateHouseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Número é obrigatório';
    }
    if (!RegExp(r'^[0-9]+[a-zA-Z]?$').hasMatch(value.trim())) {
      return 'Número inválido';
    }
    return null;
  }

  static String? validateBirthDate(DateTime? data) {
    if (data == null) {
      return 'Data de nascimento é obrigatória';
    }
    final agora = DateTime.now();
    final idade = agora.difference(data).inDays / 365;
    if (idade < 13) {
      return 'Idade mínima é 13 anos';
    }
    if (idade > 120) {
      return 'Data de nascimento inválida';
    }
    return null;
  }
}
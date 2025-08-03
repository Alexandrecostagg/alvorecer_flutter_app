import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/form_validators.dart';
import '../theme/alvorecer_theme.dart';

class CompleteProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? socialData;  // OPCIONAL

  const CompleteProfileScreen({
    super.key,
    this.socialData,  // SEM required
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _authService = AuthService();

  // Controladores dos campos
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();

  // Máscaras
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  int _currentStep = 0;
  bool _isLoading = false;
  DateTime? _dataNascimento;

  @override
  void initState() {
    super.initState();
    _preencherDadosSociais();
  }

  void _preencherDadosSociais() {
    if (widget.socialData != null) {
      _nomeController.text = widget.socialData!['nome'] ?? '';
    }
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text,
        email: widget.socialData?['email'] ?? '',
        cpf: _cpfController.text,
        telefone: _telefoneController.text,
        dataNascimento: _dataNascimento!,
        endereco: EnderecoModel(
          cep: _cepController.text,
          logradouro: _logradouroController.text,
          numero: _numeroController.text,
          complemento: _complementoController.text,
          bairro: _bairroController.text,
          cidade: _cidadeController.text,
          uf: _ufController.text,  // OBRIGATÓRIO
        ),
        loginSocial: widget.socialData?['provider'] ?? 'email',
      );

      await _authService.completarPerfilSocial(user);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selecionarData() async {
    final dataAtual = DateTime.now();
    final dataMinima = DateTime(dataAtual.year - 100);
    final dataMaxima = DateTime(dataAtual.year - 13);

    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? dataMaxima,
      firstDate: dataMinima,
      lastDate: dataMaxima,
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione sua data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataNascimento = dataSelecionada;
        _dataNascimentoController.text = 
            '${dataSelecionada.day.toString().padLeft(2, '0')}/'
            '${dataSelecionada.month.toString().padLeft(2, '0')}/'
            '${dataSelecionada.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Perfil'),
        backgroundColor: AlvorecerTheme.primaryGold,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildDadosPessoais(),
            _buildEndereco(),
          ],
        ),
      ),
    );
  }

  Widget _buildDadosPessoais() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Dados Pessoais',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome completo *',
              border: OutlineInputBorder(),
            ),
            validator: FormValidators.validarNome,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cpfController,
            inputFormatters: <TextInputFormatter>[_cpfFormatter],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'CPF *',
              border: OutlineInputBorder(),
            ),
            validator: FormValidators.validarCPF,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _telefoneController,
            inputFormatters: <TextInputFormatter>[_telefoneFormatter],
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefone *',
              border: OutlineInputBorder(),
            ),
            validator: FormValidators.validarTelefone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dataNascimentoController,
            readOnly: true,
            onTap: _selecionarData,
            decoration: const InputDecoration(
              labelText: 'Data de nascimento *',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            validator: (value) {
              if (_dataNascimento == null) {
                return 'Data de nascimento é obrigatória';
              }
              final idade = DateTime.now().difference(_dataNascimento!).inDays / 365;
              if (idade < 13) {
                return 'Idade mínima é 13 anos';
              }
              return null;
            },
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_nomeController.text.isNotEmpty &&
                  _cpfController.text.isNotEmpty &&
                  _telefoneController.text.isNotEmpty &&
                  _dataNascimento != null) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentStep = 1);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AlvorecerTheme.primaryGold,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Próximo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEndereco() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Endereço',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cepController,
                  inputFormatters: <TextInputFormatter>[_cepFormatter],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'CEP *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.validarCEP,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _numeroController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.validarObrigatorio,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _logradouroController,
                  decoration: const InputDecoration(
                    labelText: 'Logradouro *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.validarObrigatorio,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _complementoController,
                  decoration: const InputDecoration(
                    labelText: 'Complemento',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.validarObrigatorio,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Cidade *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.validarObrigatorio,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _ufController,
                  decoration: const InputDecoration(
                    labelText: 'UF *',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormValidators.validarObrigatorio,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() => _currentStep = 0);
                  },
                  child: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarPerfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AlvorecerTheme.primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Finalizar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
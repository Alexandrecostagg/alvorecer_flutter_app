import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/form_validators.dart';
import '../theme/alvorecer_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;
  
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AlvorecerTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _emailSent ? _buildSuccessView() : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        _buildHeader(),
        const SizedBox(height: 48),
        _buildForm(),
        const SizedBox(height: 32),
        _buildResetButton(),
        const Spacer(),
        _buildBackToLoginLink(),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 60,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'E-mail Enviado!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AlvorecerTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Enviamos um link de recuperação para:',
          style: TextStyle(
            fontSize: 16,
            color: AlvorecerTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AlvorecerTheme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                'Instruções importantes:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Verifique sua caixa de entrada\n'
                '• O link expira em 24 horas\n'
                '• Verifique também a pasta de spam\n'
                '• Use um dispositivo seguro para redefinir',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _emailSent = false;
                    _emailController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AlvorecerTheme.primaryColor,
                  side: BorderSide(color: AlvorecerTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Tentar Outro E-mail'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AlvorecerTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Voltar ao Login'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AlvorecerTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset_outlined,
            size: 50,
            color: AlvorecerTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Esqueceu sua senha?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AlvorecerTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Não se preocupe! Digite seu e-mail e enviaremos um link seguro para redefinir sua senha.',
          style: TextStyle(
            fontSize: 16,
            color: AlvorecerTheme.textSecondaryColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'E-mail cadastrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AlvorecerTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            decoration: InputDecoration(
              hintText: 'Digite seu e-mail cadastrado',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: FormValidators.validateEmail,
            onFieldSubmitted: (_) => _resetPassword(),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AlvorecerTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: _isLoading
            ? const SizedBox.shrink()
            : const Icon(Icons.send_outlined),
        label: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Enviar Link de Recuperação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_back,
          size: 16,
          color: AlvorecerTheme.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Voltar para o Login',
            style: TextStyle(
              color: AlvorecerTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.resetPassword(_emailController.text);

      if (result.success) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          _showErrorMessage(result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Erro interno. Tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
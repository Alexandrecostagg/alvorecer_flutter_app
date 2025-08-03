import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DevotionalScreen extends StatefulWidget {
  const DevotionalScreen({super.key});

  @override
  State<DevotionalScreen> createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends State<DevotionalScreen> {
  final PageController _pageController = PageController();
  int _currentDay = DateTime.now().day;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devocional Diário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showCalendar,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: 31, // Dias do mês
        onPageChanged: (index) {
          setState(() {
            _currentDay = index + 1;
          });
        },
        itemBuilder: (context, index) {
          return _DevotionalContent(day: index + 1);
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _currentDay > 1
                  ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              icon: const Icon(Icons.navigate_before),
              label: const Text('Anterior'),
            ),
            Text(
              'Dia $_currentDay',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _currentDay < 31
                  ? () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              icon: const Icon(Icons.navigate_next),
              label: const Text('Próximo'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendar() {
    showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year, DateTime.now().month, _currentDay),
      firstDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
    ).then((date) {
      if (date != null) {
        setState(() {
          _currentDay = date.day;
        });
        _pageController.animateToPage(
          _currentDay - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}

class _DevotionalContent extends StatelessWidget {
  final int day;

  const _DevotionalContent({required this.day});

  @override
  Widget build(BuildContext context) {
    final devotional = _getDevotionalForDay(day);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data
          Text(
            DateFormat('EEEE, d MMMM', 'pt_BR').format(
              DateTime(DateTime.now().year, DateTime.now().month, day),
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Título
          Text(
            devotional.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Versículo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  devotional.verse,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  devotional.reference,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Reflexão
          Text(
            'Reflexão',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            devotional.reflection,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),

          const SizedBox(height: 24),

          // Oração
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Oração do Dia',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  devotional.prayer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Ação do dia
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.task_alt, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Desafio de Hoje',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  devotional.challenge,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Ações
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Compartilhar devocional
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Favoritar devocional
                  },
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Favoritar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _DevotionalData _getDevotionalForDay(int day) {
    // Exemplo de dados para o devocional
    final devotionals = {
      1: _DevotionalData(
        title: 'Novo Começo',
        verse: 'As suas misericórdias se renovam cada manhã; grande é a tua fidelidade.',
        reference: 'Lamentações 3:23',
        reflection: 'Cada novo dia é uma oportunidade de recomeçar. Deus nos oferece Sua misericórdia renovada a cada manhã. Não importa os erros do passado, hoje é um novo dia para caminhar com Ele.',
        prayer: 'Senhor, obrigado por Sua misericórdia que se renova a cada manhã. Ajude-me a aproveitar este novo dia para glorificar Seu nome e servir ao próximo. Amém.',
        challenge: 'Hoje, perdoe alguém que te magoou e demonstre a misericórdia de Deus.',
      ),
      // Adicione mais devocionais para outros dias
    };

    return devotionals[day] ?? _DevotionalData(
      title: 'Confiança em Deus',
      verse: 'Confie no Senhor de todo o seu coração e não se apoie em seu próprio entendimento.',
      reference: 'Provérbios 3:5',
      reflection: 'A sabedoria humana é limitada, mas a sabedoria de Deus é infinita. Quando confiamos completamente no Senhor, Ele dirige nossos passos pelo caminho certo.',
      prayer: 'Pai celestial, entrego minha vida em Suas mãos. Ajude-me a confiar em Sua sabedoria mesmo quando não compreendo Seus caminhos. Amém.',
      challenge: 'Identifique uma área da sua vida onde precisa confiar mais em Deus e entregue a Ele.',
    );
  }
}

class _DevotionalData {
  final String title;
  final String verse;
  final String reference;
  final String reflection;
  final String prayer;
  final String challenge;

  _DevotionalData({
    required this.title,
    required this.verse,
    required this.reference,
    required this.reflection,
    required this.prayer,
    required this.challenge,
  });
}

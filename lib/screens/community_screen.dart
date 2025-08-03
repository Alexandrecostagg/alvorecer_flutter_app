import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Criar novo post
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Grupos de Oração
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grupos de Oração',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGold,
                      child: Icon(Icons.group, color: Colors.white),
                    ),
                    title: const Text('Oração Matinal'),
                    subtitle: const Text('324 membros • Ativo agora'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Abrir grupo
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.secondaryBlue,
                      child: Icon(Icons.favorite, color: Colors.white),
                    ),
                    title: const Text('Jovens em Oração'),
                    subtitle: const Text('156 membros • 12 online'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Abrir grupo
                    },
                  ),
                ],
              ),
            ),
          ),

          // Posts da Comunidade
          for (int i = 0; i < 5; i++)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: NetworkImage('https://via.placeholder.com/40'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'João Silva',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '2 horas atrás',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Que Deus abençoe a todos neste dia! Lembrem-se: "Tudo posso naquele que me fortalece" - Filipenses 4:13 🙏',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {},
                        ),
                        const Text('24'),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {},
                        ),
                        const Text('8'),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
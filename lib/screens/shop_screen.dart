import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja Cristã'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Abrir carrinho
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Categorias
            Container(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('Livros', true),
                  _buildCategoryChip('Cursos', false),
                  _buildCategoryChip('Kids', false),
                  _buildCategoryChip('Bíblias', false),
                  _buildCategoryChip('Presentes', false),
                ],
              ),
            ),

            // Produtos em Destaque
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Livros em Destaque',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return _buildProductCard(context, index);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          // Handle category selection
        },
        selectedColor: AppTheme.primaryGold,
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    final products = [
      {'title': 'Propósito de Vida', 'author': 'Rick Warren', 'price': 'R\$ 29,90'},
      {'title': 'Jesus Calling', 'author': 'Sarah Young', 'price': 'R\$ 24,90'},
      {'title': 'A Cabana', 'author': 'William P. Young', 'price': 'R\$ 32,90'},
      {'title': 'Bíblia de Estudo', 'author': 'John MacArthur', 'price': 'R\$ 89,90'},
      {'title': 'O Peregrino', 'author': 'John Bunyan', 'price': 'R\$ 19,90'},
      {'title': 'Curso de Teologia', 'author': 'Diversos', 'price': 'R\$ 149,90'},
    ];

    final product = products[index % products.length];

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Icon(
                Icons.book,
                size: 60,
                color: AppTheme.primaryGold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['author']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product['price']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bible_mark.dart';
import '../services/bible_marks_service.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({Key? key}) : super(key: key);

  @override
  _MarksScreenState createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Marcações'),
        backgroundColor: const Color(0xFF5D5FEF),
        foregroundColor: Colors.white,
        actions: [
          // Botão de pesquisa
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          // Botão de opções
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'exportar':
                  _exportMarks();
                  break;
                case 'importar':
                  _importMarks();
                  break;
                case 'limpar':
                  _confirmClearMarks();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'exportar',
                child: ListTile(
                  leading: Icon(Icons.upload_file),
                  title: Text('Exportar marcações'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'importar',
                child: ListTile(
                  leading: Icon(Icons.download_rounded),
                  title: Text('Importar marcações'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'limpar',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Limpar todas as marcações', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Destaques'),
            Tab(text: 'Marcadores'),
            Tab(text: 'Anotações'),
          ],
        ),
      ),
      body: Consumer<BibleMarksService>(
        builder: (context, marksService, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Destaques
              _buildMarksList(
                _filterMarks(marksService.getMarksByType('highlight')),
                'highlight',
              ),
              
              // Marcadores
              _buildMarksList(
                _filterMarks(marksService.getMarksByType('bookmark')),
                'bookmark',
              ),
              
              // Anotações
              _buildMarksList(
                _filterMarks(marksService.getNotesOnly()),
                'note',
              ),
            ],
          );
        },
      ),
      // FAB para exibir estatísticas
      floatingActionButton: Consumer<BibleMarksService>(
        builder: (context, marksService, child) {
          return FloatingActionButton(
            backgroundColor: const Color(0xFF5D5FEF),
            child: const Icon(Icons.bar_chart),
            onPressed: () {
              _showStatistics(marksService);
            },
          );
        }
      ),
    );
  }
  
  // Filtrar marcações baseado na pesquisa
  List<BibleMark> _filterMarks(List<BibleMark> marks) {
    if (_searchQuery.isEmpty) return marks;
    
    final query = _searchQuery.toLowerCase();
    return marks.where((mark) {
      return mark.bookName.toLowerCase().contains(query) ||
             mark.text.toLowerCase().contains(query) ||
             mark.note.toLowerCase().contains(query) ||
             '${mark.bookName} ${mark.chapter}:${mark.verse}'.toLowerCase().contains(query);
    }).toList();
  }
  
  // Diálogo de pesquisa
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buscar marcações'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Digite palavras-chave...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          actions: [
            TextButton(
              child: const Text('Limpar'),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Buscar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  
  // Construir lista de marcações
  Widget _buildMarksList(List<BibleMark> marks, String markType) {
    if (marks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              markType == 'highlight' ? Icons.brush :
              markType == 'bookmark' ? Icons.bookmark :
              Icons.note,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                ? 'Nenhuma marcação encontrada para "$_searchQuery"' :
                markType == 'highlight' ? 'Nenhum destaque encontrado' :
                markType == 'bookmark' ? 'Nenhum marcador encontrado' :
                'Nenhuma anotação encontrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: marks.length,
      itemBuilder: (context, index) {
        final mark = marks[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _navigateToVerse(mark);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: markType == 'highlight' ? mark.color : 
                                  markType == 'bookmark' ? const Color(0xFF5D5FEF) : 
                                  Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${mark.bookName} ${mark.chapter}:${mark.verse}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Menu de opções por marcação
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'editar') {
                            _editMark(mark);
                          } else if (value == 'excluir') {
                            _confirmDeleteMark(mark);
                          } else if (value == 'favorito') {
                            _toggleFavorite(mark);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'editar',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Editar'),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'favorito',
                            child: ListTile(
                              leading: Icon(mark.isFavorite ? Icons.favorite : Icons.favorite_border),
                              title: Text(mark.isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'excluir',
                            child: ListTile(
                              leading: Icon(Icons.delete_outline, color: Colors.red),
                              title: Text('Excluir', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mark.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (mark.note.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.note, size: 16, color: Color(0xFF5D5FEF)),
                              const SizedBox(width: 4),
                              const Text(
                                'Anotação:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF5D5FEF),
                                ),
                              ),
                              const Spacer(),
                              if (mark.isFavorite)
                                const Icon(Icons.favorite, size: 16, color: Colors.red),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(mark.note),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Criado em: ${_formatDate(mark.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Formatar data
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  // Confirmação para excluir marcação
  void _confirmDeleteMark(BibleMark mark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text(
            'Deseja excluir esta ${mark.markType == 'highlight' ? 'destacação' : 
                          mark.markType == 'bookmark' ? 'marcação' : 
                          'anotação'}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                
                final marksService = Provider.of<BibleMarksService>(
                  context, 
                  listen: false
                );
                
                marksService.deleteMark(mark.id);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item excluído')),
                );
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
  
  // Navegação para o versículo
  void _navigateToVerse(BibleMark mark) {
    // Aqui você implementará a navegação para o versículo específico
    // Por enquanto, apenas mostramos uma mensagem
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navegando para ${mark.bookName} ${mark.chapter}:${mark.verse}')),
    );
    
    Navigator.pop(context);
  }
  
  // Edição de marcação
  void _editMark(BibleMark mark) {
    final TextEditingController noteController = TextEditingController(text: mark.note);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar - ${mark.bookName} ${mark.chapter}:${mark.verse}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Anotação:'),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Adicione sua anotação aqui',
                ),
                maxLines: 5,
              ),
              
              if (mark.markType == 'highlight') ...[
                const SizedBox(height: 16),
                const Text('Cor do destaque:'),
                const SizedBox(height: 8),
                _buildColorSelector(mark),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                
                final marksService = Provider.of<BibleMarksService>(
                  context, 
                  listen: false
                );
                
                marksService.updateMark(
                  markId: mark.id,
                  note: noteController.text,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marcação atualizada')),
                );
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
  
  // Seletor de cores para destaques
  Widget _buildColorSelector(BibleMark mark) {
    final List<Color> highlightColors = [
      Colors.yellow.shade200,
      Colors.green.shade200,
      Colors.blue.shade200,
      Colors.pink.shade200,
      Colors.orange.shade200,
      Colors.purple.shade200,
    ];
    
    return Wrap(
      spacing: 8,
      children: highlightColors.map((color) {
        final isSelected = mark.color.value == color.value;
        
        return GestureDetector(
          onTap: () {
            final marksService = Provider.of<BibleMarksService>(
              context, 
              listen: false
            );
            
            marksService.updateMark(
              markId: mark.id,
              color: color,
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.black54) : null,
          ),
        );
      }).toList(),
    );
  }
  
  // Alternar favorito
  void _toggleFavorite(BibleMark mark) {
    final marksService = Provider.of<BibleMarksService>(
      context, 
      listen: false
    );
    
    marksService.updateMark(
      markId: mark.id,
      isFavorite: !mark.isFavorite,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mark.isFavorite 
          ? 'Removido dos favoritos'
          : 'Adicionado aos favoritos'
        ),
      ),
    );
  }
  
  // Mostrar estatísticas
  void _showStatistics(BibleMarksService marksService) {
    final highlightCount = marksService.getMarksByType('highlight').length;
    final bookmarkCount = marksService.getMarksByType('bookmark').length;
    final noteCount = marksService.getNotesOnly().length;
    final favoriteCount = marksService.getFavorites().length;
    
    // Agrupar por livro
    final Map<String, int> bookCounts = {};
    for (final mark in marksService.marks) {
      bookCounts[mark.bookName] = (bookCounts[mark.bookName] ?? 0) + 1;
    }
    
    // Encontrar livro mais marcado
    String? mostMarkedBook;
    int maxCount = 0;
    bookCounts.forEach((book, count) {
      if (count > maxCount) {
        maxCount = count;
        mostMarkedBook = book;
      }
    });
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Estatísticas de Marcações'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem(Icons.brush, 'Destaques', highlightCount),
              _buildStatItem(Icons.bookmark, 'Marcadores', bookmarkCount),
              _buildStatItem(Icons.note, 'Anotações', noteCount),
              _buildStatItem(Icons.favorite, 'Favoritos', favoriteCount),
              const Divider(),
              if (mostMarkedBook != null)
                _buildStatItem(Icons.book, 'Livro mais marcado', '$mostMarkedBook ($maxCount)'),
              _buildStatItem(Icons.calendar_today, 'Total de marcações', marksService.marks.length),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
  
  // Item de estatística
  Widget _buildStatItem(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5D5FEF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // Exportar marcações
  void _exportMarks() {
    final marksService = Provider.of<BibleMarksService>(context, listen: false);
    final jsonData = marksService.exportMarksAsJson();
    
    // Aqui você implementaria a lógica para salvar o arquivo
    // Por enquanto, apenas mostraremos uma mensagem
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marcações exportadas com sucesso')),
    );
  }
  
  // Importar marcações
  void _importMarks() {
    // Aqui você implementaria a lógica para carregar um arquivo
    // Por enquanto, apenas mostraremos um diálogo simulado
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importar Marcações'),
          content: const Text('Esta funcionalidade será implementada em breve.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  // Confirmar limpar todas as marcações
  void _confirmClearMarks() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpar marcações'),
          content: const Text(
            'Tem certeza que deseja excluir TODAS as marcações? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                
                final marksService = Provider.of<BibleMarksService>(
                  context, 
                  listen: false
                );
                
                marksService.clearAllMarks();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todas as marcações foram removidas')),
                );
              },
              child: const Text('Limpar tudo'),
            ),
          ],
        );
      },
    );
  }
}
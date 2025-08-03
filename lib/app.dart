import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'dart:convert';
import 'glorify_bible_view.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  _AppContainerState createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  List<dynamic> _books = [];
  bool _isLoading = true;
  bool _useGlorifyInterface = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() {
    setState(() {
      _isLoading = true;
    });

    try {
      final jsResult = js.context.callMethod('getBibleBooks');
      
      if (jsResult != null) {
        final parsedBooks = json.decode(jsResult.toString());
        setState(() {
          _books = parsedBooks;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Escolhe qual interface mostrar
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bíblia Sagrada'),
        actions: [
          IconButton(
            icon: Icon(_useGlorifyInterface 
                ? Icons.view_list 
                : Icons.auto_awesome),
            onPressed: () {
              setState(() {
                _useGlorifyInterface = !_useGlorifyInterface;
              });
            },
            tooltip: _useGlorifyInterface 
                ? 'Mudar para interface clássica' 
                : 'Mudar para interface Glorify',
          ),
        ],
      ),
      body: _useGlorifyInterface 
          ? GlorifyBibleView(books: _books)
          : _buildClassicInterface(),
    );
  }

  Widget _buildClassicInterface() {
    // Corpo da interface atual
    return Center(
      child: ElevatedButton(
        child: const Text('Ver nova interface Glorify'),
        onPressed: () {
          setState(() {
            _useGlorifyInterface = true;
          });
        },
      ),
    );
  }
}
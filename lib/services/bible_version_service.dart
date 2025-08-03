// bible_version_service.dart
import 'package:flutter/material.dart';
import 'dart:js' as js;

class BibleVersionService extends ChangeNotifier {
  String _currentVersion = 'arc'; // Versão padrão em minúsculo para combinar com seu código JS
  
  final List<String> availableVersions = ['arc', 'nvi', 'acf', 'naa'];
  
  String get currentVersion => _currentVersion;
  
  Future<void> initialize() async {
    print('Inicializando BibleVersionService...');
    
    try {
      // Verifica se o BibleManager está disponível
      if (js.context.hasProperty('bibleManager')) {
        print('BibleManager detectado no JavaScript');
        
        // Atualiza a versão atual no BibleManager.js
        js.context['bibleManager']['currentVersion'] = _currentVersion;
        print('Versão atual definida no BibleManager: $_currentVersion');
      } else {
        print('AVISO: BibleManager não encontrado no JavaScript');
      }
    } catch (e) {
      print('Erro ao inicializar BibleVersionService: $e');
    }
    
    notifyListeners();
  }
  
  Future<void> setVersion(String version) async {
    if (availableVersions.contains(version) && version != _currentVersion) {
      print('Alterando versão da Bíblia de $_currentVersion para $version');
      _currentVersion = version;
      
      try {
        // Verifica se o BibleManager está disponível
        if (js.context.hasProperty('bibleManager')) {
          // Atualiza a versão no BibleManager.js
          js.context['bibleManager']['currentVersion'] = version;
          print('Versão atualizada no BibleManager: $version');
          
          // Limpa o cache para forçar reload dos versículos
          if (js.context['bibleManager'].hasProperty('cacheManager')) {
            js.context['bibleManager']['cacheManager'].callMethod('clearCache', []);
            print('Cache do BibleManager limpo');
          }
        } else {
          print('AVISO: BibleManager não disponível para atualizar versão');
        }
      } catch (e) {
        print('Erro ao atualizar versão no BibleManager: $e');
      }
      
      notifyListeners();
    }
  }
  
  // Método para obter nome completo da versão
  String getVersionFullName(String versionCode) {
    switch (versionCode.toLowerCase()) {
      case 'arc':
        return 'Almeida Revista e Corrigida';
      case 'nvi':
        return 'Nova Versão Internacional';
      case 'acf':
        return 'Almeida Corrigida Fiel';
      case 'naa':
        return 'Nova Almeida Atualizada';
      default:
        return versionCode.toUpperCase();
    }
  }
  
  // Método para testar se o JavaScript está funcionando
  bool testJavaScriptConnection() {
    try {
      if (js.context.hasProperty('bibleManager')) {
        // Testa chamada de função
        final testResult = js.context.callMethod('testBibleManager', []);
        print('Teste do BibleManager: $testResult');
        return true;
      } else {
        print('BibleManager não encontrado no contexto JavaScript');
        return false;
      }
    } catch (e) {
      print('Erro no teste de conexão JavaScript: $e');
      return false;
    }
  }
  
  // Método para obter versículos com a versão atual
  Future<List<dynamic>> getBibleVerses(String bookId, int chapterNumber) async {
    try {
      print('Solicitando versículos de $bookId $chapterNumber (versão: $_currentVersion)');
      
      if (!js.context.hasProperty('getBibleVerses')) {
        print('ERRO: Função getBibleVerses não encontrada no JavaScript');
        return [];
      }
      
      // Chama a função JavaScript com a versão atual
      js.context.callMethod('getBibleVerses', [bookId, chapterNumber, _currentVersion]);
      
      // Aguarda um pouco para o JavaScript processar (método assíncrono)
      await Future.delayed(Duration(milliseconds: 500));
      
      // Verifica se os dados estão prontos
      for (int attempts = 0; attempts < 10; attempts++) {
        if (js.context.hasProperty('checkBibleVersesStatus')) {
          final statusResult = js.context.callMethod('checkBibleVersesStatus', []);
          final statusData = _parseJsonString(statusResult);
          
          if (statusData != null && statusData['status'] == 'ready') {
            print('Versículos carregados com sucesso: ${statusData['verses']?.length ?? 0} versículos');
            return statusData['verses'] ?? [];
          }
        }
        
        // Aguarda mais um pouco antes da próxima tentativa
        await Future.delayed(Duration(milliseconds: 200));
      }
      
      print('Timeout ao aguardar versículos');
      return [];
    } catch (e) {
      print('Erro ao obter versículos: $e');
      return [];
    }
  }
  
  // Método auxiliar para fazer parse seguro de JSON string
  dynamic _parseJsonString(dynamic jsonString) {
    try {
      if (jsonString == null) return null;
      
      // Se já é um objeto, retorna ele mesmo
      if (jsonString is Map || jsonString is List) {
        return jsonString;
      }
      
      // Se é string, tenta fazer parse
      if (jsonString is String) {
        // Remove espaços em branco e verifica se não está vazio
        final trimmed = jsonString.trim();
        if (trimmed.isEmpty || trimmed == 'null') return null;
        
        // Tenta fazer parse do JSON
        return js.context.callMethod('JSON.parse', [trimmed]);
      }
      
      return null;
    } catch (e) {
      print('Erro ao fazer parse do JSON: $e');
      return null;
    }
  }
}
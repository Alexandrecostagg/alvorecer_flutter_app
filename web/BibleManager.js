// BibleManager.js - VERSÃO FINAL CORRIGIDA
class BibleManager {
  constructor() {
    this.cache = new Map();
    this.initialized = false;
    console.log('🔧 BibleManager construtor chamado');
  }

  async initialize() {
    if (this.initialized) {
      console.log('✅ BibleManager já inicializado');
      return true;
    }
    
    try {
      // Aguardar BibliaData estar disponível
      var attempts = 0;
      while (typeof BibliaData === 'undefined' && attempts < 20) {
        console.log('⏳ Aguardando BibliaData... tentativa ' + (attempts + 1));
        await new Promise(function(resolve) {
          setTimeout(resolve, 100);
        });
        attempts++;
      }
      
      if (typeof BibliaData !== 'undefined') {
        this.initialized = true;
        console.log('✅ BibleManager inicializado com sucesso');
        return true;
      }
      
      console.error('❌ BibliaData não encontrada após 20 tentativas');
      return false;
    } catch (error) {
      console.error('❌ Erro ao inicializar BibleManager:', error);
      return false;
    }
  }

  async loadChapter(book, chapter) {
    console.log('📖 Carregando', book, chapter);
    
    var cacheKey = book + '_' + chapter;
    
    if (this.cache.has(cacheKey)) {
      console.log('📋 Retornando do cache:', cacheKey);
      return this.cache.get(cacheKey);
    }

    try {
      await this.initialize();
      
      if (!this.initialized) {
        throw new Error('BibleManager não foi inicializado');
      }
      
      var chapterData = BibliaData.getCapitulo(book, chapter);
      
      if (Object.keys(chapterData).length === 0) {
        throw new Error('Capítulo ' + chapter + ' do livro ' + book + ' não encontrado');
      }

      var result = {
        book: book,
        chapter: parseInt(chapter, 10),
        verses: chapterData,
        version: 'Almeida Revista e Corrigida',
        success: true
      };

      this.cache.set(cacheKey, result);
      console.log('✅ Capítulo carregado com sucesso:', result);
      return result;
      
    } catch (error) {
      console.error('❌ Erro ao carregar capítulo:', error);
      
      // Retornar erro estruturado
      var errorResult = {
        book: book,
        chapter: parseInt(chapter, 10),
        verses: {},
        version: 'Almeida Revista e Corrigida',
        success: false,
        error: error.message
      };
      
      return errorResult;
    }
  }

  async searchVerses(query) {
    try {
      await this.initialize();
      
      if (!this.initialized) {
        return [];
      }
      
      return BibliaData.buscar(query);
    } catch (error) {
      console.error('❌ Erro na busca:', error);
      return [];
    }
  }
}

// Criar instância global
window.BibleManager = BibleManager;
window.bibleManager = new BibleManager();

console.log('✅ BibleManager carregado globalmente');

// Inicializar automaticamente
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 Auto-inicializando BibleManager...');
    window.bibleManager.initialize();
  });
} else {
  console.log('🚀 Auto-inicializando BibleManager...');
  window.bibleManager.initialize();
}
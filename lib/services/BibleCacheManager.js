/**
 * BibleCacheManager.js
 * 
 * Classe responsável pelo gerenciamento de cache da Bíblia
 * Armazena e recupera dados em cache local para melhorar performance
 * e permitir uso offline
 */

class BibleCacheManager {
  constructor() {
    this.storageKey = 'alvorecer_bible_cache';
    this.cacheConfig = null;
  }
  
  /**
   * Inicializa o gerenciador de cache
   * @returns {Promise<boolean>} Sucesso da inicialização
   */
  async initialize() {
    try {
      // Carrega as configurações de cache
      const response = await fetch('assets/data/bible_cache_config.json');
      if (!response.ok) {
        throw new Error(`Failed to load cache config: ${response.status} ${response.statusText}`);
      }
      
      this.cacheConfig = await response.json();
      return true;
    } catch (error) {
      console.error('Failed to initialize cache manager', error);
      // Usa configurações padrão
      this.cacheConfig = {
        cache_strategy: {
          max_age_days: 30,
          priority_books: ["João", "Salmos", "Gênesis", "Romanos", "Mateus"],
          download_on_wifi_only: false,
          auto_cleanup_threshold_mb: 50
        }
      };
      return false;
    }
  }
  
  /**
   * Obtém dados do cache
   * @param {string} key Chave para busca no cache
   * @returns {Promise<Object|null>} Dados do cache ou null se não encontrado/expirado
   */
  async getFromCache(key) {
    try {
      const cacheData = localStorage.getItem(this.storageKey);
      if (!cacheData) return null;
      
      const cache = JSON.parse(cacheData);
      const entry = cache[key];
      
      if (!entry) return null;
      
      // Verifica se o cache está expirado
      const maxAgeMs = this.cacheConfig.cache_strategy.max_age_days * 24 * 60 * 60 * 1000;
      const now = new Date().getTime();
      
      if (now - entry.timestamp > maxAgeMs) {
        // Cache expirado, remove
        console.log(`Cache expired for ${key}`);
        delete cache[key];
        localStorage.setItem(this.storageKey, JSON.stringify(cache));
        return null;
      }
      
      console.log(`Cache hit for ${key}`);
      return entry.data;
    } catch (error) {
      console.error(`Error retrieving from cache: ${key}`, error);
      return null;
    }
  }
  
  /**
   * Salva dados no cache
   * @param {string} key Chave para armazenamento
   * @param {Object} data Dados a serem armazenados
   * @returns {Promise<boolean>} Sucesso da operação
   */
  async saveToCache(key, data) {
    try {
      const cacheData = localStorage.getItem(this.storageKey);
      const cache = cacheData ? JSON.parse(cacheData) : {};
      
      cache[key] = {
        timestamp: new Date().getTime(),
        data: data
      };
      
      localStorage.setItem(this.storageKey, JSON.stringify(cache));
      console.log(`Saved to cache: ${key}`);
      
      // Verifica se precisa fazer limpeza do cache
      await this.checkCacheSize();
      
      return true;
    } catch (error) {
      console.error(`Error saving to cache: ${key}`, error);
      return false;
    }
  }
  
  /**
   * Verifica o tamanho do cache e limpa se necessário
   * @returns {Promise<void>}
   */
  async checkCacheSize() {
    try {
      const cacheData = localStorage.getItem(this.storageKey);
      if (!cacheData) return;
      
      // Estima o tamanho do cache em MB
      const cacheSizeMB = cacheData.length * 2 / (1024 * 1024);
      
      if (cacheSizeMB > this.cacheConfig.cache_strategy.auto_cleanup_threshold_mb) {
        console.log(`Cache size (${cacheSizeMB.toFixed(2)}MB) exceeded threshold (${this.cacheConfig.cache_strategy.auto_cleanup_threshold_mb}MB), cleaning up...`);
        await this.cleanupCache();
      }
    } catch (error) {
      console.error('Error checking cache size', error);
    }
  }
  
  /**
   * Limpa dados antigos do cache
   * @returns {Promise<void>}
   */
  async cleanupCache() {
    try {
      const cacheData = localStorage.getItem(this.storageKey);
      if (!cacheData) return;
      
      const cache = JSON.parse(cacheData);
      
      // Transforma em array para ordenar por timestamp
      const entries = Object.entries(cache).map(([key, value]) => ({
        key,
        timestamp: value.timestamp
      }));
      
      // Ordena do mais antigo para o mais recente
      entries.sort((a, b) => a.timestamp - b.timestamp);
      
      // Remove os 20% mais antigos
      const removeCount = Math.floor(entries.length * 0.2);
      console.log(`Removing ${removeCount} oldest cache entries`);
      
      for (let i = 0; i < removeCount; i++) {
        const key = entries[i].key;
        
        // Não remove livros prioritários
        if (this.isPriorityBook(key)) {
          console.log(`Skipping priority item: ${key}`);
          continue;
        }
        
        console.log(`Removing from cache: ${key}`);
        delete cache[key];
      }
      
      localStorage.setItem(this.storageKey, JSON.stringify(cache));
    } catch (error) {
      console.error('Error cleaning up cache', error);
    }
  }
  
  /**
   * Verifica se um item é de um livro prioritário
   * @param {string} key Chave do item
   * @returns {boolean} Se é um livro prioritário
   */
  isPriorityBook(key) {
    const priorityBooks = this.cacheConfig.cache_strategy.priority_books;
    
    for (const book of priorityBooks) {
      if (key.toLowerCase().includes(book.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }
  
  /**
   * Limpa todo o cache
   * @returns {Promise<boolean>} Sucesso da operação
   */
  async clearAllCache() {
    try {
      localStorage.removeItem(this.storageKey);
      console.log('Cache cleared completely');
      return true;
    } catch (error) {
      console.error('Error clearing cache', error);
      return false;
    }
  }
  
  /**
   * Pré-carrega capítulos frequentemente acessados
   * @returns {Promise<number>} Número de capítulos carregados
   */
  async preloadPriorityChapters() {
    // Esta função seria implementada para pré-carregar capítulos importantes
    // quando o usuário tiver conexão com a internet
    console.log('Preload of priority chapters not yet implemented');
    return 0;
  }
}

// Exporta a classe
export default BibleCacheManager;
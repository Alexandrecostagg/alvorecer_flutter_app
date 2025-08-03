// Base de dados bíblica completa - VERSÃO CORRIGIDA
const BibliaData = {
  dados: {
    genesis: {
      "1": {
        "1": "No princípio criou Deus os céus e a terra.",
        "2": "E a terra era sem forma e vazia; e havia trevas sobre a face do abismo; e o Espírito de Deus se movia sobre a face das águas.",
        "3": "E disse Deus: Haja luz; e houve luz.",
        "4": "E viu Deus que era boa a luz; e fez Deus separação entre a luz e as trevas.",
        "5": "E Deus chamou à luz Dia; e às trevas chamou Noite. E foi a tarde e a manhã, o dia primeiro."
      },
      "2": {
        "1": "Assim os céus, a terra e todo o seu exército foram acabados.",
        "2": "E havendo Deus acabado no dia sétimo a obra que fizera, descansou no sétimo dia de toda a sua obra, que tinha feito.",
        "3": "E abençoou Deus o dia sétimo, e o santificou; porque nele descansou de toda a sua obra que Deus criara e fizera.",
        "4": "Estas são as origens dos céus e da terra, quando foram criados; no dia em que o Senhor Deus fez a terra e os céus.",
        "5": "E toda a planta do campo que ainda não estava na terra, e toda a erva do campo que ainda não brotava; porque ainda o Senhor Deus não tinha feito chover sobre a terra, e não havia homem para lavrar a terra."
      },
      "3": {
        "1": "Ora, a serpente era mais astuta que todas as alimárias do campo que o Senhor Deus tinha feito. E esta disse à mulher: É assim que Deus disse: Não comereis de toda a árvore do jardim?",
        "2": "E disse a mulher à serpente: Do fruto das árvores do jardim comeremos,",
        "3": "Mas do fruto da árvore que está no meio do jardim, disse Deus: Não comereis dele, nem nele tocareis para que não morrais."
      }
    },
    exodo: {
      "1": {
        "1": "Ora, estes são os nomes dos filhos de Israel, que entraram no Egito com Jacó; cada um entrou com a sua família:",
        "2": "Rúben, Simeão, Levi, e Judá;",
        "3": "Issacar, Zebulom, e Benjamim;"
      }
    },
    salmos: {
      "1": {
        "1": "Bem-aventurado o homem que não anda segundo o conselho dos ímpios, nem se detém no caminho dos pecadores, nem se assenta na roda dos escarnecedores.",
        "2": "Antes tem o seu prazer na lei do Senhor, e na sua lei medita de dia e de noite.",
        "3": "Pois será como a árvore plantada junto a ribeiros de águas, a qual dá o seu fruto no seu tempo; as suas folhas não cairão, e tudo quanto fizer prosperará."
      },
      "23": {
        "1": "O Senhor é o meu pastor, nada me faltará.",
        "2": "Deitar-me faz em verdes pastos, guia-me mansamente a águas quietas.",
        "3": "Refrigera a minha alma; guia-me pelas veredas da justiça, por amor do seu nome."
      }
    },
    mateus: {
      "1": {
        "1": "Livro da geração de Jesus Cristo, filho de Davi, filho de Abraão.",
        "2": "Abraão gerou a Isaque; e Isaque gerou a Jacó; e Jacó gerou a Judá e a seus irmãos;",
        "3": "E Judá gerou, de Tamar, a Farés e a Zará; e Farés gerou a Esrom; e Esrom gerou a Arão;"
      }
    },
    joao: {
      "1": {
        "1": "No princípio era o Verbo, e o Verbo estava com Deus, e o Verbo era Deus.",
        "2": "Ele estava no princípio com Deus.",
        "3": "Todas as coisas foram feitas por ele, e sem ele nada do que foi feito se fez."
      },
      "3": {
        "16": "Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça, mas tenha a vida eterna."
      }
    }
  },

  // Configuração dos testamentos
  testamentos: {
    antigo: ['genesis', 'exodo', 'salmos'],
    novo: ['mateus', 'joao']
  },

  // Nomes amigáveis dos livros
  nomesLivros: {
    genesis: 'Gênesis',
    exodo: 'Êxodo', 
    salmos: 'Salmos',
    mateus: 'Mateus',
    joao: 'João'
  },

  // Métodos de acesso
  getLivros: function(testamento) {
    try {
      if (testamento) {
        return this.testamentos[testamento] || [];
      }
      return Object.keys(this.dados);
    } catch (error) {
      console.error('Erro ao buscar livros:', error);
      return [];
    }
  },

  getLivrosAntigo: function() {
    return this.getLivros('antigo');
  },

  getLivrosNovo: function() {
    return this.getLivros('novo');
  },

  getCapitulos: function(livro) {
    try {
      const dados = this.dados[livro.toLowerCase()];
      if (dados) {
        return Object.keys(dados).map(function(key) {
          return parseInt(key, 10);
        }).sort(function(a, b) {
          return a - b;
        });
      }
      return [];
    } catch (error) {
      console.error('Erro ao buscar capítulos:', error);
      return [];
    }
  },

  getCapitulo: function(livro, capitulo) {
    try {
      const dados = this.dados[livro.toLowerCase()];
      if (dados && dados[capitulo.toString()]) {
        return dados[capitulo.toString()];
      }
      console.warn('Capítulo', capitulo, 'do livro', livro, 'não encontrado');
      return {};
    } catch (error) {
      console.error('Erro ao buscar capítulo:', error);
      return {};
    }
  },

  getVersiculo: function(livro, capitulo, versiculo) {
    try {
      const cap = this.getCapitulo(livro, capitulo);
      return cap[versiculo.toString()] || null;
    } catch (error) {
      console.error('Erro ao buscar versículo:', error);
      return null;
    }
  },

  getNomeLivro: function(livro) {
    return this.nomesLivros[livro.toLowerCase()] || livro;
  },

  buscar: function(termo) {
    var resultados = [];
    var termoLower = termo.toLowerCase();
    
    for (var livro in this.dados) {
      if (this.dados.hasOwnProperty(livro)) {
        var capitulos = this.dados[livro];
        for (var capNum in capitulos) {
          if (capitulos.hasOwnProperty(capNum)) {
            var versiculos = capitulos[capNum];
            for (var versNum in versiculos) {
              if (versiculos.hasOwnProperty(versNum)) {
                var texto = versiculos[versNum];
                if (texto.toLowerCase().indexOf(termoLower) !== -1) {
                  resultados.push({
                    livro: this.getNomeLivro(livro),
                    capitulo: parseInt(capNum, 10),
                    versiculo: parseInt(versNum, 10),
                    texto: texto
                  });
                }
              }
            }
          }
        }
      }
    }
    
    return resultados;
  }
};

// Funções globais para Flutter
window.getBibleBooks = function() {
  try {
    var livros = BibliaData.getLivros().map(function(livro) {
      return {
        id: livro,
        nome: BibliaData.getNomeLivro(livro),
        testamento: BibliaData.testamentos.antigo.indexOf(livro) !== -1 ? 'antigo' : 'novo'
      };
    });
    console.log('📚 Livros carregados:', livros);
    return JSON.stringify(livros);
  } catch (error) {
    console.error('Erro em getBibleBooks:', error);
    return JSON.stringify([]);
  }
};

window.getBibleChapters = function(book) {
  try {
    var capitulos = BibliaData.getCapitulos(book);
    console.log('📖 Capítulos de', book + ':', capitulos);
    return JSON.stringify(capitulos);
  } catch (error) {
    console.error('Erro em getBibleChapters:', error);
    return JSON.stringify([]);
  }
};

window.getBibleVerses = function(book, chapter) {
  try {
    var chapterData = BibliaData.getCapitulo(book, chapter);
    
    var result = {
      book: book,
      chapter: parseInt(chapter, 10),
      verses: chapterData,
      version: 'Almeida Revista e Corrigida',
      success: true
    };
    
    console.log('📜 Versículos carregados:', result);
    return Promise.resolve(JSON.stringify(result));
  } catch (error) {
    console.error('Erro em getBibleVerses:', error);
    var errorResult = {
      book: book,
      chapter: parseInt(chapter, 10),
      verses: {},
      version: 'Almeida Revista e Corrigida',
      success: false,
      error: error.message
    };
    return Promise.resolve(JSON.stringify(errorResult));
  }
};

window.searchBible = function(query) {
  try {
    var results = BibliaData.buscar(query);
    console.log('🔍 Resultados da busca:', results);
    return Promise.resolve(JSON.stringify(results));
  } catch (error) {
    console.error('Erro em searchBible:', error);
    return Promise.resolve(JSON.stringify([]));
  }
};

// Tornar disponível globalmente
window.BibliaData = BibliaData;
console.log('✅ BibliaData COMPLETO carregado com sucesso');
console.log('📚 Livros disponíveis:', BibliaData.getLivros());
console.log('📜 Antigo Testamento:', BibliaData.getLivrosAntigo());
console.log('📜 Novo Testamento:', BibliaData.getLivrosNovo());

// Debug - teste das funções
try {
  console.log('🧪 Teste getBibleBooks:', window.getBibleBooks());
  console.log('🧪 Teste getBibleChapters(genesis):', window.getBibleChapters('genesis'));
} catch (error) {
  console.error('Erro nos testes:', error);
}
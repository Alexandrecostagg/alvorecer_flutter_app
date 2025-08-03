# Codex Agent Config for Flutter

name: FlutterAgent
description: >
  Agente para projetos Flutter/Dart.  
  Ignora execução de testes no ambiente Codex porque Flutter SDK não está disponível.  
  Alterações e melhorias devem ser validadas localmente.

capabilities:
  - edit_files
  - create_pull_requests
  - generate_code_suggestions

instructions:
  - Sempre gerar código Dart/Flutter seguindo boas práticas.
  - Não executar "flutter test" ou "dart analyze" no ambiente remoto.
  - Caso seja necessário validar mudanças, informar o usuário para rodar testes localmente:
      flutter pub get
      flutter test

tasks:
  default:
    steps:
      - message: >
          O agente irá modificar arquivos, mas não executará testes devido à ausência do SDK Flutter.
      - action: generate_code
      - action: create_pull_request

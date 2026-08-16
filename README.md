# Essenza Mobile

Frontend Flutter do Essenza.

## Distribuir uma versão para testers

O workflow `.github/workflows/firebase-distribution.yml` publica uma nova versão no Firebase App Distribution quando uma tag `v*` é enviada para o GitHub.

Consulte [docs/firebase-distribution.md](docs/firebase-distribution.md) para configurar o Firebase, os secrets e publicar a primeira versão.

## Executar

Com o backend rodando em Docker e usando o emulador Android:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Em um celular físico, substitua `10.0.2.2` pelo IP local do computador.

O backend precisa estar disponível em `http://localhost:8080` e o primeiro fluxo implementado é cadastro/login com JWT.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

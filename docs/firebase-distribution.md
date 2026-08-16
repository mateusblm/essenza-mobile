# Distribuição de testes Android

O Essenza usa o Firebase App Distribution para publicar versões de teste no Firebase App Tester.

## Configuração única

1. Crie ou selecione um projeto no Firebase Console.
2. Registre um app Android com o package name `com.essenza.essenza_mobile`.
3. No App Distribution, crie um grupo de testers, por exemplo `android-testers`, e adicione os e-mails.
4. Instale o Firebase CLI e autentique:

```bash
firebase login
firebase projects:list
```

5. Obtenha o Firebase App ID em Configurações do projeto > Seus apps.
6. Gere um token para a CLI:

```bash
firebase login:ci
```

## Secrets do GitHub

Em Settings > Secrets and variables > Actions, crie:

- `API_BASE_URL`: URL pública da API Railway, terminando em `/api/v1`;
- `FIREBASE_APP_ID`: identificador do app Android no Firebase;
- `FIREBASE_TOKEN`: token gerado por `firebase login:ci`;
- `FIREBASE_TESTER_GROUP`: alias do grupo, por exemplo `android-testers`.

## Publicar uma versão

```bash
git tag v0.1.0
git push origin v0.1.0
```

O workflow gera um APK release com a URL pública da API e o envia ao grupo configurado no Firebase App Distribution.

## Teste manual local

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.exemplo.com/api/v1

firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app SEU_FIREBASE_APP_ID \
  --groups android-testers \
  --release-notes "Teste local"
```

Não commite tokens ou arquivos de credenciais no repositório.

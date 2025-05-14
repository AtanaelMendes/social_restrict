# BundleBlock - Controle de Aplicativos

Aplicativo Flutter para controle e monitoramento de uso de aplicativos.

## 📋 Pré-requisitos

- Flutter SDK (versão >=2.19.6)
- Dart SDK (versão compatível com Flutter)
- Android Studio / VS Code
- Git
- Dispositivo Android para testes (versão 6.0 ou superior)

## 🚀 Instalação

1. Clone o repositório:
```bash
git clone [URL_DO_REPOSITÓRIO]
cd bundleblock
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure o arquivo de ambiente:
   - Crie um arquivo `.env` na raiz do projeto
   - Copie o conteúdo do arquivo `.env.example` (se existir)
   - Preencha as variáveis de ambiente necessárias:
```env
# Ambiente
ENVIRONMENT=production

# API Configuration
HOST=https://app-api.rhbrasil.com.br
API_VERSION=v1
API_PATH=app/api
TOKEN=seu_token_aqui

# AWS Configuration
AWS_KEY_ID=sua_aws_key_id
AWS_SECRET_ID=sua_aws_secret_id

# Other Services
UPLOAD_IMAGES_API_URL=sua_url_de_upload
MAPS_API_KEY=sua_chave_do_google_maps
```

4. Configure o Firebase:
   - Adicione o arquivo `google-services.json` na pasta `android/app/`
   - Configure as credenciais do Firebase no console do Firebase

## 🔧 Configuração do Android

1. Abra o projeto no Android Studio
2. Configure o arquivo `android/app/build.gradle`:
   - Verifique se o `applicationId` está correto
   - Confirme se as versões do SDK estão corretas

3. Configure as permissões no `android/app/src/main/AndroidManifest.xml`:
   - Verifique se todas as permissões necessárias estão declaradas
   - Confirme se os serviços em background estão configurados

## 🏃‍♂️ Executando o Projeto

1. Conecte um dispositivo Android ou inicie um emulador

2. Execute o projeto:
```bash
flutter run
```

3. Para gerar um APK de release:
```bash
flutter build apk --release
```

## 📱 Funcionalidades Principais

- Monitoramento de uso de aplicativos
- Bloqueio de aplicativos
- Rastreamento de localização
- Notificações em background
- Integração com Firebase

## 🔐 Permissões Necessárias

O aplicativo requer as seguintes permissões:
- Localização
- Uso de aplicativos
- Notificações
- Overlay
- Internet

## 🛠️ Tecnologias Utilizadas

- Flutter
- GetX (Gerenciamento de Estado)
- Dio (Requisições HTTP)
- Firebase (Notificações)
- Shared Preferences (Armazenamento Local)
- Background Fetch (Tarefas em Background)

## 📦 Estrutura do Projeto

```
lib/
  ├── config/         # Configurações do app
  ├── data/          # Camada de dados
  │   ├── modules/   # Módulos da aplicação
  │   └── provider/  # Provedores de dados
  ├── android/       # Código nativo Android
  └── widgets/       # Widgets reutilizáveis
```

## ⚠️ Solução de Problemas

1. Se encontrar problemas com permissões:
   - Verifique se todas as permissões foram concedidas no dispositivo
   - Reinicie o aplicativo após conceder as permissões

2. Se houver problemas com o Firebase:
   - Verifique se o arquivo `google-services.json` está correto
   - Confirme se as dependências do Firebase estão atualizadas

3. Para problemas de build:
   - Execute `flutter clean`
   - Delete a pasta `build/`
   - Execute `flutter pub get`
   - Tente buildar novamente

## 📄 Licença

Este projeto está sob a licença [inserir tipo de licença]. Veja o arquivo `LICENSE` para mais detalhes.

## 🤝 Contribuição

1. Faça um Fork do projeto
2. Crie uma Branch para sua Feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a Branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

# 📚 Aleatoriamente

**Conhecimentos que você não sabia que queria saber**

Um aplicativo iOS leve e divertido que oferece curiosidades aleatórias diariamente, ajudando você a se desconectar das redes sociais e aprender algo novo todos os dias.

## 🌟 Características Principais

### 🧠 Descoberta de Conhecimentos
- **Tela principal estilo Tinder**: Swipe para descobrir novos fatos curiosos
- **Categorias diversificadas**: Ciência, História, Natureza, Cultura, Tecnologia, Saúde, Entretenimento
- **Design de cartões**: Interface limpa e intuitiva
- **Filtros por categoria**: Encontre conhecimentos específicos

### 💛 Sistema de Favoritos
- **Salvar conhecimentos**: Marque seus favoritos para ler depois
- **Sincronização**: Favoritos salvos na nuvem
- **Busca e filtros**: Encontre facilmente seus conhecimentos salvos
- **Estatísticas**: Veja quantas pessoas favoritaram cada conhecimento

### 🔗 Compartilhamento
- **Compartilhamento nativo**: Compartilhe via WhatsApp, redes sociais, etc.
- **Formatação automática**: Texto formatado com emoji e categoria
- **Imagem personalizada**: Gera imagem para compartilhamento

### 🚩 Sistema de Report
- **Reportar erros**: Informação incorreta, incompleta ou sem fonte
- **Moderação**: Sistema de moderação para manter qualidade
- **Feedback**: Usuários ajudam a melhorar o conteúdo

### 🏆 Ranking e Gamificação
- **Top Fatos**: Ranking dos conhecimentos mais favoritados
- **Top Usuários**: Ranking de quem mais contribui
- **Sistema de pontos**: Ganhe pontos por interações
- **Conquistas**: Badges por uso e contribuições

### 👤 Perfil do Usuário
- **Login social**: Apple ID, Google ou email
- **Estatísticas pessoais**: Favoritos, contribuições, pontos
- **Histórico**: Veja seus conhecimentos favoritos
- **Configurações**: Personalize notificações e conteúdo

### ➕ Contribuições
- **Enviar conhecimentos**: Contribua com fatos curiosos
- **Moderação**: Conteúdo revisado antes de publicação
- **Diretrizes**: Regras claras para contribuições
- **Reconhecimento**: Pontos por contribuições aprovadas

### 🔔 Notificações Inteligentes
- **2x ao dia**: Notificações em horários aleatórios
- **Conteúdo personalizado**: Baseado em suas preferências
- **Configurável**: Ative/desative conforme preferir
- **Horário personalizado**: Escolha quando receber

## 🛠️ Tecnologias Utilizadas

### Frontend (iOS)
- **SwiftUI**: Interface moderna e declarativa
- **Combine**: Programação reativa
- **Core Data**: Armazenamento local
- **AuthenticationServices**: Login com Apple
- **GoogleSignIn**: Login com Google

### Backend
- **Firebase Authentication**: Autenticação segura
- **Firebase Firestore**: Banco de dados em tempo real
- **Firebase Storage**: Armazenamento de mídia
- **Firebase Cloud Functions**: Lógica de backend
- **Firebase Cloud Messaging**: Notificações push

### Design
- **Design System**: Componentes consistentes
- **Animações suaves**: Microinterações
- **Modo escuro/claro**: Suporte a temas
- **Acessibilidade**: Suporte completo a VoiceOver

## 📱 Instalação e Configuração

### Pré-requisitos
- Xcode 14.0+
- iOS 16.0+
- Swift 5.8+
- Conta Apple Developer (para distribuição)
- Projeto Firebase configurado

### 1. Clone o Repositório
```bash
git clone https://github.com/seu-usuario/aleatoriamente.git
cd aleatoriamente
```

### 2. Configurar Firebase
1. Crie um projeto no [Firebase Console](https://console.firebase.google.com)
2. Adicione um app iOS
3. Baixe o arquivo `GoogleService-Info.plist`
4. Adicione o arquivo ao projeto Xcode

### 3. Configurar Dependências
O projeto usa Swift Package Manager. As dependências serão baixadas automaticamente:
- Firebase iOS SDK
- Google Sign-In iOS

### 4. Configurar Autenticação
1. No Firebase Console, vá para Authentication
2. Habilite Apple Sign-In e Google Sign-In
3. Configure as URLs de redirecionamento

### 5. Configurar Firestore
1. No Firebase Console, vá para Firestore Database
2. Crie as seguintes coleções:
   - `knowledge` (conhecimentos aprovados)
   - `contributions` (contribuições pendentes)
   - `users` (perfis de usuários)
   - `userFavorites` (favoritos dos usuários)
   - `reports` (reports de conteúdo)

### 6. Configurar Regras de Segurança
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários podem ler conhecimentos aprovados
    match /knowledge/{document} {
      allow read: if true;
      allow write: if false;
    }
    
    // Usuários podem gerenciar seus próprios favoritos
    match /userFavorites/{document} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Usuários podem contribuir
    match /contributions/{document} {
      allow read, write: if request.auth != null;
    }
    
    // Usuários podem reportar
    match /reports/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 7. Build e Executar
1. Abra `Aleatoriamente.xcodeproj` no Xcode
2. Selecione um simulador ou dispositivo
3. Pressione `Cmd + R` para executar

## 🎨 Protótipo HTML

Para visualizar o protótipo do app, abra o arquivo `prototype/index.html` em qualquer navegador moderno.

### Funcionalidades do Protótipo
- ✅ Interface completa do app
- ✅ Navegação entre abas
- ✅ Sistema de login
- ✅ Cartões de conhecimento
- ✅ Favoritos
- ✅ Ranking
- ✅ Perfil do usuário
- ✅ Contribuições
- ✅ Filtros por categoria
- ✅ Animações e interações

## 📊 Estrutura do Projeto

```
Aleatoriamente/
├── Aleatoriamente/
│   ├── AleatoriamenteApp.swift          # App principal
│   ├── Models/
│   │   └── Knowledge.swift              # Modelos de dados
│   ├── Managers/
│   │   ├── AuthenticationManager.swift  # Gerenciador de auth
│   │   └── KnowledgeManager.swift       # Gerenciador de dados
│   ├── Views/
│   │   ├── ContentView.swift            # View principal
│   │   ├── LoginView.swift              # Tela de login
│   │   ├── DiscoveryView.swift          # Tela de descoberta
│   │   ├── FavoritesView.swift          # Tela de favoritos
│   │   ├── RankingView.swift            # Tela de ranking
│   │   ├── ProfileView.swift            # Tela de perfil
│   │   └── ContributionView.swift       # Tela de contribuição
│   └── Assets.xcassets/                 # Recursos visuais
├── prototype/
│   ├── index.html                       # Protótipo HTML
│   ├── styles.css                       # Estilos CSS
│   └── script.js                        # JavaScript
└── README.md                            # Este arquivo
```

## 🔧 Configurações Avançadas

### Notificações Push
1. Configure Firebase Cloud Messaging
2. Implemente `UNUserNotificationCenterDelegate`
3. Configure horários de notificação

### Analytics
1. Configure Firebase Analytics
2. Implemente eventos personalizados
3. Monitore engajamento

### Testes
```bash
# Executar testes unitários
xcodebuild test -scheme Aleatoriamente -destination 'platform=iOS Simulator,name=iPhone 15'

# Executar testes de UI
xcodebuild test -scheme Aleatoriamente -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:AleatoriamenteUITests
```

## 🚀 Deploy

### App Store Connect
1. Configure certificados e provisioning profiles
2. Archive o projeto no Xcode
3. Faça upload para App Store Connect
4. Configure metadados e screenshots
5. Submeta para revisão

### TestFlight
1. Configure grupos de teste
2. Faça upload da build
3. Convide testadores
4. Monitore feedback

## 📈 Métricas e Analytics

### KPIs Principais
- **DAU/MAU**: Usuários ativos diários/mensais
- **Retenção**: Retenção de 1, 7, 30 dias
- **Engajamento**: Tempo de sessão, fatos vistos
- **Conversão**: Taxa de favoritos, compartilhamentos
- **Qualidade**: Reports, moderação

### Eventos Firebase
- `knowledge_viewed`: Conhecimento visualizado
- `knowledge_favorited`: Conhecimento favoritado
- `knowledge_shared`: Conhecimento compartilhado
- `knowledge_reported`: Conhecimento reportado
- `contribution_submitted`: Contribuição enviada
- `user_login`: Login do usuário

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- **Firebase**: Plataforma de backend
- **SwiftUI**: Framework de UI
- **Comunidade iOS**: Suporte e feedback
- **Testadores**: Feedback valioso

## 📞 Suporte

- **Email**: suporte@aleatoriamente.app
- **Website**: https://aleatoriamente.app
- **Documentação**: https://docs.aleatoriamente.app

---

**Desenvolvido com ❤️ para promover conhecimento e reduzir a dependência das redes sociais.** 
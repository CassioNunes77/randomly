# 🎨 Protótipo HTML - Aleatoriamente

Este é um protótipo funcional do app **Aleatoriamente** criado em HTML, CSS e JavaScript para demonstração das funcionalidades principais.

## 🚀 Como Testar

### Método 1: Abrir Diretamente
1. Navegue até a pasta `prototype/`
2. Abra o arquivo `index.html` em qualquer navegador moderno
3. O protótipo funcionará completamente no navegador

### Método 2: Servidor Local (Recomendado)
```bash
# Usando Python 3
python -m http.server 8000

# Usando Node.js
npx serve .

# Usando PHP
php -S localhost:8000
```

Depois acesse: `http://localhost:8000/prototype/`

## 🎯 Funcionalidades Demonstradas

### ✅ Tela de Login
- Interface de login com Apple ID, Google e modo visitante
- Animações suaves e design moderno
- Simulação de processo de login

### ✅ Tela Principal (Descobrir)
- **Cartão de conhecimento**: Exibe fatos curiosos em formato de cartão
- **Ações**: Favoritar, compartilhar e reportar
- **Navegação**: Botão para próximo conhecimento
- **Filtros**: Modal para filtrar por categoria
- **Estatísticas**: Contador de favoritos e fonte

### ✅ Favoritos
- **Lista de favoritos**: Visualização dos conhecimentos salvos
- **Busca**: Campo de busca funcional
- **Filtros**: Chips para filtrar por categoria
- **Ações**: Remover favoritos

### ✅ Ranking
- **Duas abas**: Top Fatos e Top Usuários
- **Ranking visual**: Badges de posição (1º, 2º, 3º)
- **Estatísticas**: Favoritos, contribuições, pontos
- **Avatares**: Imagens de perfil dos usuários

### ✅ Perfil
- **Informações do usuário**: Nome, email, data de cadastro
- **Estatísticas**: Cards com favoritos, contribuições e pontos
- **Ações rápidas**: Contribuir e ver contribuições
- **Configurações**: Acesso às configurações do app

### ✅ Contribuições
- **Formulário completo**: Título, conteúdo, categoria, fonte
- **Validação**: Contador de caracteres e validação de campos
- **Configurações**: Toggle para conteúdo +18
- **Diretrizes**: Instruções para contribuições

### ✅ Modais e Interações
- **Filtro de categorias**: Modal com todas as categorias
- **Contribuição**: Modal completo para enviar fatos
- **Animações**: Transições suaves entre telas
- **Feedback**: Toasts de confirmação

## 🎨 Design System

### Cores
- **Primária**: `#ff9a56` (Laranja)
- **Secundária**: `#ffad33` (Amarelo)
- **Texto**: `#333333` (Cinza escuro)
- **Texto secundário**: `#666666` (Cinza médio)
- **Background**: `#f8f9fa` (Cinza claro)

### Tipografia
- **Fonte**: Poppins (Google Fonts)
- **Títulos**: 24px, 700 weight
- **Subtítulos**: 18px, 600 weight
- **Corpo**: 16px, 400 weight
- **Legendas**: 14px, 400 weight

### Componentes
- **Cartões**: Bordas arredondadas, sombras suaves
- **Botões**: Estados hover, transições suaves
- **Badges**: Categorias com emojis
- **Modais**: Overlay com animações

## 📱 Responsividade

O protótipo é responsivo e funciona bem em:
- **Desktop**: 1024px+
- **Tablet**: 768px - 1023px
- **Mobile**: 320px - 767px

## 🔧 Personalização

### Adicionar Novos Conhecimentos
Edite o arquivo `script.js` e adicione novos itens ao array `sampleKnowledge`:

```javascript
const sampleKnowledge = [
  {
    title: "Seu novo fato",
    content: "Descrição do fato...",
    category: "Ciência",
    emoji: "🔬",
    favoriteCount: 123,
    source: "Fonte do fato"
  },
  // ... outros fatos
];
```

### Modificar Cores
Edite o arquivo `styles.css` e altere as variáveis CSS:

```css
:root {
  --primary-color: #ff9a56;
  --secondary-color: #ffad33;
  --text-color: #333333;
  --background-color: #f8f9fa;
}
```

### Adicionar Novas Categorias
1. Adicione a categoria no array `Knowledge.KnowledgeCategory.allCases`
2. Atualize o HTML com os novos filtros
3. Adicione os estilos correspondentes

## 🐛 Solução de Problemas

### Protótipo não carrega
- Verifique se todos os arquivos estão na pasta `prototype/`
- Certifique-se de que o navegador suporta ES6+
- Abra o console do navegador para verificar erros

### Estilos não aplicados
- Verifique se o arquivo `styles.css` está no mesmo diretório
- Certifique-se de que a fonte Poppins está carregando
- Verifique se o Font Awesome está acessível

### JavaScript não funciona
- Abra o console do navegador (F12)
- Verifique se há erros JavaScript
- Certifique-se de que o arquivo `script.js` está sendo carregado

## 📊 Dados de Exemplo

O protótipo inclui dados de exemplo para demonstração:

### Conhecimentos
- 5 fatos curiosos de diferentes categorias
- Estatísticas realistas de favoritos
- Fontes variadas

### Usuários
- Perfil de exemplo com estatísticas
- Ranking de usuários fictícios
- Contribuições de exemplo

### Categorias
- Ciência (🔬)
- História (📚)
- Natureza (🌿)
- Cultura (🎭)
- Tecnologia (💻)
- Saúde (🏥)
- Entretenimento (🎬)
- Aleatório (🎲)

## 🚀 Próximos Passos

Para transformar este protótipo em um app real:

1. **Implementar backend**: Configurar Firebase
2. **Autenticação**: Integrar Apple ID e Google Sign-In
3. **Banco de dados**: Configurar Firestore
4. **Notificações**: Implementar FCM
5. **Deploy**: Publicar na App Store

## 📞 Suporte

Se encontrar problemas ou tiver sugestões:
- Abra uma issue no repositório
- Entre em contato: suporte@aleatoriamente.app

---

**Este protótipo demonstra a experiência completa do app Aleatoriamente. Divirta-se explorando todas as funcionalidades! 🎉** 
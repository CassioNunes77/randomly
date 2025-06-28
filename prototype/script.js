// App State
let currentTab = 'discovery';
let currentKnowledgeIndex = 0;
let isFavorite = false;

// Sample Data
const sampleKnowledge = [
    {
        title: "Os polvos têm três corações",
        content: "Os polvos possuem três corações: dois bombeiam sangue para as brânquias, enquanto o terceiro mantém a circulação para o resto do corpo. Quando o polvo nada, o coração principal para de bater, o que explica por que eles preferem rastejar do que nadar.",
        category: "Ciência",
        emoji: "🔬",
        favoriteCount: 1247,
        source: "National Geographic"
    },
    {
        title: "O primeiro email foi enviado em 1971",
        content: "Ray Tomlinson enviou o primeiro email da história entre dois computadores que estavam lado a lado. Ele escolheu o símbolo @ para separar o nome do usuário do nome da máquina, criando o formato que usamos até hoje.",
        category: "História",
        emoji: "📚",
        favoriteCount: 892,
        source: "MIT"
    },
    {
        title: "As abelhas podem reconhecer rostos humanos",
        content: "As abelhas têm a capacidade de reconhecer e lembrar rostos humanos individuais. Elas usam padrões visuais complexos para distinguir entre diferentes pessoas, uma habilidade impressionante para um inseto com um cérebro do tamanho de uma semente de gergelim.",
        category: "Natureza",
        emoji: "🌿",
        favoriteCount: 567,
        source: "Science Daily"
    },
    {
        title: "O som mais alto do mundo é o de uma erupção vulcânica",
        content: "A erupção do vulcão Krakatoa em 1883 produziu o som mais alto já registrado na história. O som foi ouvido a mais de 4.800 km de distância e causou ondas de choque que deram a volta na Terra várias vezes.",
        category: "Ciência",
        emoji: "🔬",
        favoriteCount: 743,
        source: "Geological Society"
    },
    {
        title: "O primeiro filme colorido foi feito em 1902",
        content: "O primeiro filme colorido foi 'A Trip to the Moon' de Georges Méliès, lançado em 1902. O filme foi pintado à mão, frame por frame, por artistas que usavam pincéis minúsculos para colorir cada fotograma individualmente.",
        category: "Cultura",
        emoji: "🎭",
        favoriteCount: 445,
        source: "Film History Archive"
    }
];

// Initialize App
document.addEventListener('DOMContentLoaded', function() {
    // Show login screen initially
    showScreen('login');
    
    // Add event listeners
    setupEventListeners();
});

// Screen Management
function showScreen(screenName) {
    // Hide all screens
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.remove('active');
    });
    
    // Show target screen
    document.getElementById(screenName + '-screen').classList.add('active');
}

// Tab Management
function showTab(tabName) {
    // Update tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.closest('.tab-btn').classList.add('active');
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(tabName + '-tab').classList.add('active');
    
    currentTab = tabName;
    
    // Load specific content
    if (tabName === 'discovery') {
        loadRandomKnowledge();
    } else if (tabName === 'favorites') {
        loadFavorites();
    } else if (tabName === 'ranking') {
        loadRanking();
    }
}

// Login Function
function login() {
    // Simulate login process
    showLoading();
    
    setTimeout(() => {
        hideLoading();
        showScreen('main-app');
        loadRandomKnowledge();
    }, 1500);
}

// Knowledge Management
function loadRandomKnowledge() {
    const knowledge = sampleKnowledge[currentKnowledgeIndex];
    updateKnowledgeCard(knowledge);
}

function updateKnowledgeCard(knowledge) {
    const card = document.querySelector('.knowledge-card');
    
    card.innerHTML = `
        <div class="card-header">
            <div class="category-badge">
                <span class="category-emoji">${knowledge.emoji}</span>
                <span class="category-name">${knowledge.category}</span>
            </div>
            <div class="card-actions">
                <button class="action-btn favorite-btn ${isFavorite ? 'active' : ''}" onclick="toggleFavorite()">
                    <i class="fas fa-heart"></i>
                </button>
                <button class="action-btn share-btn" onclick="shareKnowledge()">
                    <i class="fas fa-share"></i>
                </button>
                <button class="action-btn report-btn" onclick="reportKnowledge()">
                    <i class="fas fa-flag"></i>
                </button>
            </div>
        </div>
        <div class="card-content">
            <h3>${knowledge.title}</h3>
            <p>${knowledge.content}</p>
            <div class="knowledge-stats">
                <span class="favorite-count">
                    <i class="fas fa-heart"></i>
                    ${knowledge.favoriteCount} pessoas favoritaram
                </span>
                <span class="source">
                    <i class="fas fa-link"></i>
                    Fonte: ${knowledge.source}
                </span>
            </div>
        </div>
    `;
}

function nextKnowledge() {
    currentKnowledgeIndex = (currentKnowledgeIndex + 1) % sampleKnowledge.length;
    isFavorite = false;
    loadRandomKnowledge();
    
    // Add animation
    const card = document.querySelector('.knowledge-card');
    card.style.transform = 'translateX(100%)';
    card.style.opacity = '0';
    
    setTimeout(() => {
        card.style.transition = 'none';
        card.style.transform = 'translateX(-100%)';
        
        setTimeout(() => {
            card.style.transition = 'all 0.3s ease';
            card.style.transform = 'translateX(0)';
            card.style.opacity = '1';
        }, 50);
    }, 300);
}

function toggleFavorite() {
    isFavorite = !isFavorite;
    const favoriteBtn = document.querySelector('.favorite-btn');
    
    if (isFavorite) {
        favoriteBtn.classList.add('active');
        favoriteBtn.style.color = '#ff4757';
        showToast('Adicionado aos favoritos!');
    } else {
        favoriteBtn.classList.remove('active');
        favoriteBtn.style.color = '#666';
        showToast('Removido dos favoritos!');
    }
}

function shareKnowledge() {
    const knowledge = sampleKnowledge[currentKnowledgeIndex];
    const shareText = `🤓 ${knowledge.title}\n\n${knowledge.content}\n\n${knowledge.emoji} ${knowledge.category}\n\nCompartilhado via Aleatoriamente`;
    
    if (navigator.share) {
        navigator.share({
            title: knowledge.title,
            text: shareText
        });
    } else {
        // Fallback: copy to clipboard
        navigator.clipboard.writeText(shareText).then(() => {
            showToast('Conteúdo copiado para a área de transferência!');
        });
    }
}

function reportKnowledge() {
    const reasons = ['Informação Incorreta', 'Informação Incompleta', 'Sem Fonte'];
    const reason = prompt('Selecione o motivo do report:\n1. Informação Incorreta\n2. Informação Incompleta\n3. Sem Fonte');
    
    if (reason && reasons[reason - 1]) {
        showToast('Report enviado! Obrigado pelo feedback.');
    }
}

// Category Filter
function showCategoryFilter() {
    const modal = document.getElementById('category-modal');
    modal.classList.add('active');
}

function selectCategory(category) {
    // Filter knowledge by category
    if (category === 'all') {
        currentKnowledgeIndex = 0;
    } else {
        // Find knowledge with matching category
        const categoryMap = {
            'science': 'Ciência',
            'history': 'História',
            'nature': 'Natureza',
            'culture': 'Cultura'
        };
        
        const targetCategory = categoryMap[category];
        const index = sampleKnowledge.findIndex(k => k.category === targetCategory);
        if (index !== -1) {
            currentKnowledgeIndex = index;
        }
    }
    
    closeModal();
    loadRandomKnowledge();
}

// Ranking Management
function showRankingTab(tab) {
    document.querySelectorAll('.ranking-tab').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    document.querySelectorAll('.ranking-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(tab + '-ranking').classList.add('active');
}

function loadRanking() {
    // Ranking data is already in HTML
}

function loadFavorites() {
    // Favorites data is already in HTML
}

// Contribution
function showContribution() {
    const modal = document.getElementById('contribution-modal');
    modal.classList.add('active');
}

// Modal Management
function closeModal() {
    document.querySelectorAll('.modal').forEach(modal => {
        modal.classList.remove('active');
    });
}

// Utility Functions
function showLoading() {
    const loadingDiv = document.createElement('div');
    loadingDiv.id = 'loading';
    loadingDiv.innerHTML = `
        <div class="loading-spinner">
            <i class="fas fa-spinner fa-spin"></i>
            <p>Entrando...</p>
        </div>
    `;
    loadingDiv.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
    `;
    
    const spinner = loadingDiv.querySelector('.loading-spinner');
    spinner.style.cssText = `
        background: white;
        padding: 40px;
        border-radius: 16px;
        text-align: center;
        box-shadow: 0 4px 20px rgba(0,0,0,0.2);
    `;
    
    spinner.querySelector('i').style.cssText = `
        font-size: 40px;
        color: #ff9a56;
        margin-bottom: 16px;
    `;
    
    document.body.appendChild(loadingDiv);
}

function hideLoading() {
    const loading = document.getElementById('loading');
    if (loading) {
        loading.remove();
    }
}

function showToast(message) {
    const toast = document.createElement('div');
    toast.textContent = message;
    toast.style.cssText = `
        position: fixed;
        bottom: 20px;
        left: 50%;
        transform: translateX(-50%);
        background: #333;
        color: white;
        padding: 12px 24px;
        border-radius: 8px;
        font-size: 14px;
        z-index: 10000;
        animation: slideUp 0.3s ease;
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideDown 0.3s ease';
        setTimeout(() => {
            toast.remove();
        }, 300);
    }, 2000);
}

// Event Listeners
function setupEventListeners() {
    // Close modal when clicking outside
    document.querySelectorAll('.modal').forEach(modal => {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                closeModal();
            }
        });
    });
    
    // Form submission
    const contributionForm = document.querySelector('.contribution-form');
    if (contributionForm) {
        contributionForm.addEventListener('submit', (e) => {
            e.preventDefault();
            showToast('Contribuição enviada com sucesso!');
            closeModal();
        });
    }
    
    // Character count for textarea
    const textarea = document.querySelector('.contribution-form textarea');
    if (textarea) {
        textarea.addEventListener('input', (e) => {
            const count = e.target.value.length;
            const charCount = e.target.parentElement.querySelector('.char-count');
            if (charCount) {
                charCount.innerHTML = `
                    <span style="color: ${count >= 50 ? 'green' : 'red'}">${count} caracteres</span>
                    ${count < 50 ? '<span style="color: red">Mínimo: 50 caracteres</span>' : ''}
                `;
            }
        });
    }
}

// CSS Animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideUp {
        from {
            transform: translateX(-50%) translateY(100%);
            opacity: 0;
        }
        to {
            transform: translateX(-50%) translateY(0);
            opacity: 1;
        }
    }
    
    @keyframes slideDown {
        from {
            transform: translateX(-50%) translateY(0);
            opacity: 1;
        }
        to {
            transform: translateX(-50%) translateY(100%);
            opacity: 0;
        }
    }
    
    .favorite-btn.active {
        color: #ff4757 !important;
        animation: heartBeat 0.3s ease;
    }
    
    @keyframes heartBeat {
        0% { transform: scale(1); }
        50% { transform: scale(1.2); }
        100% { transform: scale(1); }
    }
`;
document.head.appendChild(style); 
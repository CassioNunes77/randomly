import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        if authManager.isAuthenticated {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoveryView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Descobrir")
                }
                .tag(0)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favoritos")
                }
                .tag(1)
            
            RankingView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Ranking")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
                .tag(3)
        }
        .accentColor(.orange)
    }
}

struct DiscoveryView: View {
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @State private var showingCategoryFilter = false
    @State private var showingContribution = false
    @State private var showingReport = false
    @State private var selectedCategory: Knowledge.KnowledgeCategory?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Aleatoriamente")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Button(action: {
                            showingCategoryFilter = true
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Knowledge Card
                    if let knowledge = knowledgeManager.currentKnowledge {
                        KnowledgeCardView(knowledge: knowledge)
                            .padding(.horizontal)
                    } else if knowledgeManager.isLoading {
                        ProgressView("Carregando...")
                            .scaleEffect(1.5)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Erro ao carregar")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(knowledgeManager.errorMessage ?? "Tente novamente")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Tentar Novamente") {
                                knowledgeManager.loadRandomKnowledge()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    HStack(spacing: 30) {
                        Button(action: {
                            knowledgeManager.toggleFavorite()
                        }) {
                            VStack {
                                Image(systemName: "heart.fill")
                                    .font(.title)
                                Text("Favoritar")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.red)
                        
                        Button(action: {
                            knowledgeManager.shareKnowledge()
                        }) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title)
                                Text("Compartilhar")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.blue)
                        
                        Button(action: {
                            showingReport = true
                        }) {
                            VStack {
                                Image(systemName: "flag.fill")
                                    .font(.title)
                                Text("Reportar")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.orange)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCategoryFilter) {
            CategoryFilterView(selectedCategory: $selectedCategory) { category in
                knowledgeManager.getKnowledgeByCategory(category)
                showingCategoryFilter = false
            }
        }
        .sheet(isPresented: $showingContribution) {
            ContributionView()
        }
        .alert("Reportar Conhecimento", isPresented: $showingReport) {
            Button("Informação Incorreta") {
                knowledgeManager.reportKnowledge(reason: "Informação Incorreta")
            }
            Button("Informação Incompleta") {
                knowledgeManager.reportKnowledge(reason: "Informação Incompleta")
            }
            Button("Sem Fonte") {
                knowledgeManager.reportKnowledge(reason: "Sem Fonte")
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Selecione o motivo do report:")
        }
        .onAppear {
            if knowledgeManager.currentKnowledge == nil {
                knowledgeManager.loadRandomKnowledge()
            }
        }
    }
}

struct KnowledgeCardView: View {
    let knowledge: Knowledge
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category Badge
            HStack {
                Text(knowledge.category.emoji)
                    .font(.title2)
                Text(knowledge.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                
                Spacer()
                
                if knowledge.isAdultContent {
                    Text("18+")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            }
            
            // Title
            Text(knowledge.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Content
            Text(knowledge.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(isExpanded ? nil : 6)
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
            
            // Expand/Collapse Button
            if knowledge.content.count > 200 {
                Button(action: {
                    isExpanded.toggle()
                }) {
                    Text(isExpanded ? "Ver menos" : "Ver mais")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            // Source
            if let source = knowledge.source {
                HStack {
                    Image(systemName: "link")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Fonte: \(source)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Stats
            HStack {
                Label("\(knowledge.favoriteCount) favoritos", systemImage: "heart.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let authorName = knowledge.authorName {
                    Text("Por: \(authorName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CategoryFilterView: View {
    @Binding var selectedCategory: Knowledge.KnowledgeCategory?
    let onSelect: (Knowledge.KnowledgeCategory) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(Knowledge.KnowledgeCategory.allCases, id: \.self) { category in
                Button(action: {
                    onSelect(category)
                }) {
                    HStack {
                        Text(category.emoji)
                            .font(.title2)
                        
                        Text(category.rawValue)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedCategory == category {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("Filtrar por Categoria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(KnowledgeManager())
} 
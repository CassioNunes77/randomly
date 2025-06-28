import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @State private var searchText = ""
    @State private var selectedCategory: Knowledge.KnowledgeCategory?
    
    var filteredFavorites: [Knowledge] {
        var favorites = knowledgeManager.favorites
        
        if !searchText.isEmpty {
            favorites = favorites.filter { knowledge in
                knowledge.title.localizedCaseInsensitiveContains(searchText) ||
                knowledge.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            favorites = favorites.filter { $0.category == category }
        }
        
        return favorites
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Buscar favoritos...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: {
                            selectedCategory = nil
                        }) {
                            Text("Todas")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == nil ? Color.orange : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == nil ? .white : .primary)
                                .cornerRadius(20)
                        }
                        
                        ForEach(Knowledge.KnowledgeCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = selectedCategory == category ? nil : category
                            }) {
                                HStack {
                                    Text(category.emoji)
                                        .font(.caption)
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedCategory == category ? Color.orange : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if filteredFavorites.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Nenhum favorito encontrado")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Comece a favoritar conhecimentos interessantes!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredFavorites) { knowledge in
                        FavoriteCardView(knowledge: knowledge)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Meus Favoritos")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FavoriteCardView: View {
    let knowledge: Knowledge
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(knowledge.category.emoji)
                    .font(.title3)
                
                Text(knowledge.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
                
                Spacer()
                
                Button(action: {
                    knowledgeManager.toggleFavorite()
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
            
            // Title
            Text(knowledge.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Content Preview
            Text(knowledge.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Stats
            HStack {
                Label("\(knowledge.favoriteCount) favoritos", systemImage: "heart.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let source = knowledge.source {
                    Text("Fonte: \(source)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            KnowledgeDetailView(knowledge: knowledge)
        }
    }
}

struct KnowledgeDetailView: View {
    let knowledge: Knowledge
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Category Badge
                    HStack {
                        Text(knowledge.category.emoji)
                            .font(.title)
                        Text(knowledge.category.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
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
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Content
                    Text(knowledge.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                    // Source
                    if let source = knowledge.source {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fonte")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(source)
                                .font(.body)
                                .foregroundColor(.blue)
                                .underline()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Stats
                    VStack(spacing: 12) {
                        HStack {
                            Label("\(knowledge.favoriteCount) pessoas favoritaram", systemImage: "heart.fill")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        
                        if let authorName = knowledge.authorName {
                            HStack {
                                Label("Contribuído por \(authorName)", systemImage: "person.fill")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                        }
                        
                        HStack {
                            Label("Adicionado em \(knowledge.createdAt.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Detalhes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(KnowledgeManager())
} 
import SwiftUI
import FirebaseFirestore

struct RankingView: View {
    @StateObject private var rankingManager = RankingManager()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab Selector
                Picker("Ranking Type", selection: $selectedTab) {
                    Text("Top Fatos").tag(0)
                    Text("Top Usuários").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    TopFactsView(rankingManager: rankingManager)
                } else {
                    TopUsersView(rankingManager: rankingManager)
                }
            }
            .navigationTitle("Ranking")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct TopFactsView: View {
    @ObservedObject var rankingManager: RankingManager
    
    var body: some View {
        List {
            ForEach(Array(rankingManager.topFacts.enumerated()), id: \.element.id) { index, knowledge in
                TopFactRowView(knowledge: knowledge, rank: index + 1)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            await rankingManager.loadTopFacts()
        }
        .onAppear {
            Task {
                await rankingManager.loadTopFacts()
            }
        }
    }
}

struct TopFactRowView: View {
    let knowledge: Knowledge
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 40, height: 40)
                
                Text("\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Category and Title
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
                }
                
                Text(knowledge.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
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
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .orange
        }
    }
}

struct TopUsersView: View {
    @ObservedObject var rankingManager: RankingManager
    
    var body: some View {
        List {
            ForEach(Array(rankingManager.topUsers.enumerated()), id: \.element.id) { index, user in
                TopUserRowView(user: user, rank: index + 1)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            await rankingManager.loadTopUsers()
        }
        .onAppear {
            Task {
                await rankingManager.loadTopUsers()
            }
        }
    }
}

struct TopUserRowView: View {
    let user: User
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 40, height: 40)
                
                Text("\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // User Avatar
            if let imageURL = user.profileImageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(user.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    Label("\(user.favoriteCount) favoritos", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(user.contributionCount) contribuições", systemImage: "plus.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(user.totalPoints) pontos")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .orange
        }
    }
}

class RankingManager: ObservableObject {
    @Published var topFacts: [Knowledge] = []
    @Published var topUsers: [User] = []
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    @MainActor
    func loadTopFacts() async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("knowledge")
                .whereField("isApproved", isEqualTo: true)
                .order(by: "favoriteCount", descending: true)
                .limit(to: 20)
                .getDocuments()
            
            topFacts = snapshot.documents.compactMap { document in
                try? document.data(as: Knowledge.self)
            }
        } catch {
            print("Error loading top facts: \(error)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadTopUsers() async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("users")
                .order(by: "totalPoints", descending: true)
                .limit(to: 20)
                .getDocuments()
            
            topUsers = snapshot.documents.compactMap { document in
                try? document.data(as: User.self)
            }
        } catch {
            print("Error loading top users: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    RankingView()
} 
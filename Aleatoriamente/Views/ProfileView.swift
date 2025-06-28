import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    @State private var showingSettings = false
    @State private var showingContribution = false
    @State private var showingContributions = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    ProfileHeaderView(user: authManager.currentUser)
                    
                    // Stats Cards
                    StatsCardsView(user: authManager.currentUser)
                    
                    // Quick Actions
                    QuickActionsView(
                        showingContribution: $showingContribution,
                        showingContributions: $showingContributions
                    )
                    
                    // Settings Section
                    SettingsSectionView(showingSettings: $showingSettings)
                }
                .padding()
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingContribution) {
                ContributionView()
            }
            .sheet(isPresented: $showingContributions) {
                UserContributionsView()
            }
        }
    }
}

struct ProfileHeaderView: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Image
            if let imageURL = user?.profileImageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.orange, lineWidth: 3)
                )
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.gray)
                    .overlay(
                        Circle()
                            .stroke(Color.orange, lineWidth: 3)
                    )
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(user?.name ?? "Usuário")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(user?.email ?? "")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                if let createdAt = user?.createdAt {
                    Text("Membro desde \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct StatsCardsView: View {
    let user: User?
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCardView(
                title: "Favoritos",
                value: "\(user?.favoriteCount ?? 0)",
                icon: "heart.fill",
                color: .red
            )
            
            StatCardView(
                title: "Contribuições",
                value: "\(user?.contributionCount ?? 0)",
                icon: "plus.circle.fill",
                color: .blue
            )
            
            StatCardView(
                title: "Pontos",
                value: "\(user?.totalPoints ?? 0)",
                icon: "star.fill",
                color: .orange
            )
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickActionsView: View {
    @Binding var showingContribution: Bool
    @Binding var showingContributions: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ações Rápidas")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Button(action: {
                    showingContribution = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Contribuir com um Fato")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    showingContributions = true
                }) {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill")
                            .foregroundColor(.green)
                        Text("Ver Minhas Contribuições")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct SettingsSectionView: View {
    @Binding var showingSettings: Bool
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Configurações")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Button(action: {
                    showingSettings = true
                }) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.orange)
                        Text("Configurações do App")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    authManager.signOut()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Sair da Conta")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("adultContentEnabled") private var adultContentEnabled = false
    @AppStorage("dailyNotificationTime") private var dailyNotificationTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notificações") {
                    Toggle("Ativar Notificações", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        DatePicker("Horário da Notificação", selection: $dailyNotificationTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("Conteúdo") {
                    Toggle("Mostrar Conteúdo +18", isOn: $adultContentEnabled)
                }
                
                Section("Sobre") {
                    HStack {
                        Text("Versão")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Política de Privacidade", destination: URL(string: "https://aleatoriamente.app/privacy")!)
                    
                    Link("Termos de Uso", destination: URL(string: "https://aleatoriamente.app/terms")!)
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Concluído") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct UserContributionsView: View {
    @StateObject private var contributionsManager = ContributionsManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(contributionsManager.contributions) { contribution in
                    ContributionRowView(contribution: contribution)
                }
            }
            .navigationTitle("Minhas Contribuições")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                contributionsManager.loadUserContributions()
            }
        }
    }
}

struct ContributionRowView: View {
    let contribution: UserContribution
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(contribution.category.emoji)
                    .font(.title3)
                
                Text(contribution.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
                
                Spacer()
                
                StatusBadgeView(status: contribution.status)
            }
            
            Text(contribution.title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(contribution.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Text("Enviado em \(contribution.createdAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct StatusBadgeView: View {
    let status: UserContribution.ContributionStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(8)
    }
    
    private var statusText: String {
        switch status {
        case .pending: return "Pendente"
        case .approved: return "Aprovado"
        case .rejected: return "Rejeitado"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        }
    }
}

class ContributionsManager: ObservableObject {
    @Published var contributions: [UserContribution] = []
    
    private let db = Firestore.firestore()
    
    func loadUserContributions() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("contributions")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading contributions: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self?.contributions = snapshot?.documents.compactMap { document in
                        try? document.data(as: UserContribution.self)
                    } ?? []
                }
            }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
        .environmentObject(KnowledgeManager())
} 
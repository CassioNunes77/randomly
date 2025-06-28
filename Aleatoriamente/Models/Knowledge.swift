import Foundation
import FirebaseFirestore

struct Knowledge: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let content: String
    let category: KnowledgeCategory
    let source: String?
    let isAdultContent: Bool
    let authorId: String?
    let authorName: String?
    let createdAt: Date
    let favoriteCount: Int
    let isApproved: Bool
    
    enum KnowledgeCategory: String, CaseIterable, Codable {
        case science = "Ciência"
        case history = "História"
        case nature = "Natureza"
        case culture = "Cultura"
        case technology = "Tecnologia"
        case health = "Saúde"
        case entertainment = "Entretenimento"
        case random = "Aleatório"
        
        var emoji: String {
            switch self {
            case .science: return "🔬"
            case .history: return "📚"
            case .nature: return "🌿"
            case .culture: return "🎭"
            case .technology: return "💻"
            case .health: return "🏥"
            case .entertainment: return "🎬"
            case .random: return "🎲"
            }
        }
    }
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let email: String
    let profileImageURL: String?
    let favoriteCount: Int
    let contributionCount: Int
    let totalPoints: Int
    let createdAt: Date
}

struct UserFavorite: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let knowledgeId: String
    let createdAt: Date
}

struct UserContribution: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let title: String
    let content: String
    let category: Knowledge.KnowledgeCategory
    let source: String?
    let isAdultContent: Bool
    let status: ContributionStatus
    let createdAt: Date
    
    enum ContributionStatus: String, Codable {
        case pending = "pending"
        case approved = "approved"
        case rejected = "rejected"
    }
} 
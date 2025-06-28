import Foundation
import FirebaseFirestore
import Combine

class KnowledgeManager: ObservableObject {
    @Published var currentKnowledge: Knowledge?
    @Published var favorites: [Knowledge] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadRandomKnowledge()
        loadFavorites()
    }
    
    func loadRandomKnowledge() {
        isLoading = true
        
        db.collection("knowledge")
            .whereField("isApproved", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        self?.errorMessage = "Nenhum conhecimento encontrado"
                        return
                    }
                    
                    let randomDocument = documents.randomElement()!
                    
                    do {
                        let knowledge = try randomDocument.data(as: Knowledge.self)
                        self?.currentKnowledge = knowledge
                    } catch {
                        self?.errorMessage = "Erro ao carregar conhecimento"
                    }
                }
            }
    }
    
    func loadFavorites() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("userFavorites")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading favorites: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let favoriteIds = documents.compactMap { doc -> String? in
                    try? doc.data(as: UserFavorite.self).knowledgeId
                }
                
                self?.loadKnowledgeByIds(favoriteIds)
            }
    }
    
    private func loadKnowledgeByIds(_ ids: [String]) {
        guard !ids.isEmpty else { return }
        
        db.collection("knowledge")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error loading knowledge by IDs: \(error)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    let knowledge = documents.compactMap { doc -> Knowledge? in
                        try? doc.data(as: Knowledge.self)
                    }
                    
                    self?.favorites = knowledge
                }
            }
    }
    
    func toggleFavorite() {
        guard let knowledge = currentKnowledge,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        let favoriteRef = db.collection("userFavorites")
            .whereField("userId", isEqualTo: userId)
            .whereField("knowledgeId", isEqualTo: knowledge.id ?? "")
        
        favoriteRef.getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error checking favorite: \(error)")
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                // Remove favorite
                documents.first?.reference.delete { error in
                    if let error = error {
                        print("Error removing favorite: \(error)")
                    } else {
                        self?.updateFavoriteCount(knowledgeId: knowledge.id ?? "", increment: -1)
                        self?.loadFavorites()
                    }
                }
            } else {
                // Add favorite
                let favorite = UserFavorite(
                    userId: userId,
                    knowledgeId: knowledge.id ?? "",
                    createdAt: Date()
                )
                
                do {
                    try self?.db.collection("userFavorites").addDocument(from: favorite)
                    self?.updateFavoriteCount(knowledgeId: knowledge.id ?? "", increment: 1)
                    self?.loadFavorites()
                } catch {
                    print("Error adding favorite: \(error)")
                }
            }
        }
    }
    
    private func updateFavoriteCount(knowledgeId: String, increment: Int) {
        db.collection("knowledge").document(knowledgeId).updateData([
            "favoriteCount": FieldValue.increment(Int64(increment))
        ]) { error in
            if let error = error {
                print("Error updating favorite count: \(error)")
            }
        }
    }
    
    func shareKnowledge() {
        guard let knowledge = currentKnowledge else { return }
        
        let shareText = """
        🤓 \(knowledge.title)
        
        \(knowledge.content)
        
        \(knowledge.category.emoji) \(knowledge.category.rawValue)
        
        Compartilhado via Aleatoriamente
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    func reportKnowledge(reason: String) {
        guard let knowledge = currentKnowledge else { return }
        
        let report = [
            "knowledgeId": knowledge.id ?? "",
            "reason": reason,
            "reportedAt": Date(),
            "reportedBy": Auth.auth().currentUser?.uid ?? "anonymous"
        ] as [String : Any]
        
        db.collection("reports").addDocument(data: report) { error in
            if let error = error {
                print("Error reporting knowledge: \(error)")
            } else {
                print("Knowledge reported successfully")
            }
        }
    }
    
    func submitContribution(title: String, content: String, category: Knowledge.KnowledgeCategory, source: String?, isAdultContent: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let contribution = UserContribution(
            userId: userId,
            title: title,
            content: content,
            category: category,
            source: source,
            isAdultContent: isAdultContent,
            status: .pending,
            createdAt: Date()
        )
        
        do {
            try db.collection("contributions").addDocument(from: contribution)
            print("Contribution submitted successfully")
        } catch {
            print("Error submitting contribution: \(error)")
        }
    }
    
    func getKnowledgeByCategory(_ category: Knowledge.KnowledgeCategory) {
        isLoading = true
        
        db.collection("knowledge")
            .whereField("category", isEqualTo: category.rawValue)
            .whereField("isApproved", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        self?.errorMessage = "Nenhum conhecimento encontrado nesta categoria"
                        return
                    }
                    
                    let randomDocument = documents.randomElement()!
                    
                    do {
                        let knowledge = try randomDocument.data(as: Knowledge.self)
                        self?.currentKnowledge = knowledge
                    } catch {
                        self?.errorMessage = "Erro ao carregar conhecimento"
                    }
                }
            }
    }
} 
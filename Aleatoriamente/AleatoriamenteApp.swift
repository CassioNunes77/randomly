import SwiftUI
import Firebase

@main
struct AleatoriamenteApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var knowledgeManager = KnowledgeManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(knowledgeManager)
                .preferredColorScheme(.light)
        }
    }
} 
import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices

class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.fetchUserData(userId: user.uid)
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    func signInWithApple() {
        isLoading = true
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func signInWithGoogle() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                print("Google sign in error: \(error)")
                self?.isLoading = false
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.isLoading = false
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        print("Firebase auth error: \(error)")
                    }
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    private func fetchUserData(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    do {
                        let user = try document.data(as: User.self)
                        self?.currentUser = user
                        self?.isAuthenticated = true
                    } catch {
                        print("Error decoding user: \(error)")
                        self?.createUserProfile(userId: userId)
                    }
                } else {
                    self?.createUserProfile(userId: userId)
                }
            }
        }
    }
    
    private func createUserProfile(userId: String) {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        
        let user = User(
            name: firebaseUser.displayName ?? "Usuário",
            email: firebaseUser.email ?? "",
            profileImageURL: firebaseUser.photoURL?.absoluteString,
            favoriteCount: 0,
            contributionCount: 0,
            totalPoints: 0,
            createdAt: Date()
        )
        
        do {
            try db.collection("users").document(userId).setData(from: user)
            self.currentUser = user
            self.isAuthenticated = true
        } catch {
            print("Error creating user profile: \(error)")
        }
    }
}

extension AuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        print("Apple sign in error: \(error)")
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            print("Apple sign in error: \(error)")
        }
    }
    
    private var currentNonce: String? {
        return nil // Implement nonce generation for Apple Sign In
    }
} 
import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    
                    VStack(spacing: 8) {
                        Text("Aleatoriamente")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Conhecimentos que você não sabia que queria saber")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Login Options
                VStack(spacing: 16) {
                    // Apple Sign In
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                print("Apple Sign In success: \(authResults)")
                            case .failure(let error):
                                print("Apple Sign In error: \(error)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(12)
                    
                    // Google Sign In
                    Button(action: {
                        authManager.signInWithGoogle()
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .font(.title3)
                            Text("Continuar com Google")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(authManager.isLoading)
                    
                    // Guest Mode
                    Button(action: {
                        // Implement guest mode
                    }) {
                        Text("Continuar como Visitante")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .underline()
                    }
                    .disabled(authManager.isLoading)
                }
                .padding(.horizontal, 40)
                
                // Loading Indicator
                if authManager.isLoading {
                    ProgressView("Entrando...")
                        .scaleEffect(1.2)
                }
                
                Spacer()
                
                // Footer
                VStack(spacing: 8) {
                    Text("Ao continuar, você concorda com nossos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Button("Termos de Uso") {
                            // Open terms
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                        
                        Text("e")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Política de Privacidade") {
                            // Open privacy policy
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct SignInWithAppleButton: UIViewRepresentable {
    let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onCompletion: (Result<ASAuthorization, Error>) -> Void
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleSignInWithApple), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        let parent: SignInWithAppleButton
        
        init(_ parent: SignInWithAppleButton) {
            self.parent = parent
        }
        
        @objc func handleSignInWithApple() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            parent.onRequest(request)
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                fatalError("No window found")
            }
            return window
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            parent.onCompletion(.success(authorization))
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            parent.onCompletion(.failure(error))
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
} 
import SwiftUI

struct ContributionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var knowledgeManager: KnowledgeManager
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedCategory: Knowledge.KnowledgeCategory = .random
    @State private var source = ""
    @State private var isAdultContent = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        content.count >= 50
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informações do Conhecimento") {
                    TextField("Título do conhecimento", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Conteúdo")
                            .font(.headline)
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        HStack {
                            Text("\(content.count) caracteres")
                                .font(.caption)
                                .foregroundColor(content.count >= 50 ? .green : .red)
                            
                            Spacer()
                            
                            if content.count < 50 {
                                Text("Mínimo: 50 caracteres")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section("Categoria") {
                    Picker("Categoria", selection: $selectedCategory) {
                        ForEach(Knowledge.KnowledgeCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.emoji)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Fonte (Opcional)") {
                    TextField("URL ou nome da fonte", text: $source)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Adicione uma fonte para dar credibilidade ao seu conhecimento")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Configurações") {
                    Toggle("Conteúdo +18", isOn: $isAdultContent)
                    
                    Text("Marque se o conteúdo é adequado apenas para maiores de 18 anos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Diretrizes") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Seja preciso e verifique as informações")
                        Text("• Use linguagem clara e acessível")
                        Text("• Evite conteúdo ofensivo ou inadequado")
                        Text("• Contribuições passam por moderação")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Contribuir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enviar") {
                        submitContribution()
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
            }
            .alert("Contribuição", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("sucesso") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func submitContribution() {
        isSubmitting = true
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSource = source.trimmingCharacters(in: .whitespacesAndNewlines)
        
        knowledgeManager.submitContribution(
            title: trimmedTitle,
            content: trimmedContent,
            category: selectedCategory,
            source: trimmedSource.isEmpty ? nil : trimmedSource,
            isAdultContent: isAdultContent
        )
        
        // Simulate submission delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            alertMessage = "Contribuição enviada com sucesso! Ela será revisada e pode ser adicionada à biblioteca em breve."
            showingAlert = true
        }
    }
}

#Preview {
    ContributionView()
        .environmentObject(KnowledgeManager())
} 
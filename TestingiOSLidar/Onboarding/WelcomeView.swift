import SwiftUI

struct WelcomeView: View {
    var onContinueTapped: () -> Void
    
    var body: some View {
        VStack {
            Text("Bem-vindo ao App!")
                .font(.title)
                .padding()
            
            Spacer()
            
            Button(action: {
                onContinueTapped()
            }) {
                Text("Continuar")
            }
            .padding()
        }
    }
}

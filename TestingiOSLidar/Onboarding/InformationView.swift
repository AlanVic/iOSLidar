import SwiftUI

struct InformationView: View {
    var onContinueTapped: () -> Void
    
    var body: some View {
        VStack {
            Text("Algumas informações úteis sobre o aplicativo...")
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

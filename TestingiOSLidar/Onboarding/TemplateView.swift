import SwiftUI

struct TemplateView: View {
    var title: String
    var message: String
    var buttonTitle: String
    var onContinueTapped: () -> Void
    var secondaryButton: () -> Void
    var shouldPresentSecondaryButton: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
            
            Text(message)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button(action: onContinueTapped) {
                HStack {
                    Text(buttonTitle)
                        .accentColor(.white)
                        .font(.title3)
                }
                .padding([.bottom, .top], 4)
                .frame(maxWidth: .infinity)
            }
            .frame(width: UIScreen.main.bounds.width - 64)
            .buttonStyle(.borderedProminent)
            .padding([.bottom], 12)
            
            if shouldPresentSecondaryButton {
                Button("Pular", action: secondaryButton)
            }
        }
    }
}

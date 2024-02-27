import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    var presentHomeScreen: () -> ()
    
    var body: some View {
        VStack {
            if currentPage == 0 {
                WelcomeView(onContinueTapped: nextPage)
            } else if currentPage == 1 {
                InformationView(onContinueTapped: nextPage)
            } else if currentPage == 2 {
                Button("Concluir", action: presentHomeScreen)
            }
        }
    }
    
    func nextPage() {
        withAnimation {
            currentPage += 1
        }
    }
}

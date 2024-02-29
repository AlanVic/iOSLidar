import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    var presentHomeScreen: () -> ()
    
    var body: some View {
        VStack {
            if currentPage == 0 {
                TemplateView(
                    title: "Bem-vindo ao nosso aplicativo!",
                    message: "Estamos animados em tê-lo conosco para explorar as possibilidades emocionantes do sensor LiDAR em seu dispositivo. O LiDAR é uma tecnologia avançada que permite ao seu dispositivo perceber e interagir com o mundo ao seu redor em três dimensões, proporcionando uma experiência totalmente nova e imersiva.",
                    buttonTitle: "Continuar",
                    onContinueTapped: nextPage,
                    secondaryButton: presentHomeScreen,
                    shouldPresentSecondaryButton: true
                )
            } else if currentPage == 1 {
                TemplateView(
                    title: "O que é LiDAR?",
                    message: "O LiDAR, que significa Light Detection and Ranging (Detecção e Varredura a Laser), é uma tecnologia que utiliza pulsos de luz laser para medir distâncias e criar mapas tridimensionais detalhados do ambiente. Isso significa que o seu dispositivo pode entender a forma, a profundidade e a textura dos objetos ao seu redor com uma precisão impressionante.",
                    buttonTitle: "Continuar",
                    onContinueTapped: nextPage,
                    secondaryButton: presentHomeScreen,
                    shouldPresentSecondaryButton: true
                )
            } else if currentPage == 2 {
                TemplateView(
                    title: "Experimente e Capture",
                    message: "Com o nosso aplicativo, você poderá explorar e interagir com o mundo ao seu redor de uma maneira completamente nova. Tire proveito do sensor LiDAR para medir distâncias com precisão, escanear objetos em 3D e até mesmo criar modelos tridimensionais incríveis. Você pode capturar os frames e compartilhá-los!",
                    buttonTitle: "Continuar",
                    onContinueTapped: nextPage,
                    secondaryButton: presentHomeScreen,
                    shouldPresentSecondaryButton: true
                )
            } else if currentPage == 3 {
                TemplateView(
                    title: "Comece a Explorar",
                    message: "Agora que você está pronto para começar sua jornada com o sensor LiDAR, clique no botão abaixo para entrar na experiência incrível que preparamos para você! Verifique se o seu iPhone possui o sensor LiDAR, não são todos os modelos que possuem!",
                    buttonTitle: "Começar",
                    onContinueTapped: presentHomeScreen,
                    secondaryButton: presentHomeScreen,
                    shouldPresentSecondaryButton: false
                )
            }
        }
    }
    
    func nextPage() {
        withAnimation {
            currentPage += 1
        }
    }
}

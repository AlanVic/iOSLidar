import UIKit
import SwiftUI

final class OnboardingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Criando uma instância da view SwiftUI
        let swiftUIView = OnboardingView {
            UserDefaults.standard.setValue(true, forKey: "onboarding")
            let storyboard = UIStoryboard(name: "Main", bundle: .init(for: AppDelegate.self))
            let viewController = storyboard.instantiateViewController(withIdentifier: "Features")
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true)
        }
        
        // Criando um UIHostingController para a view SwiftUI
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Adicionando o UIHostingController como filho desta view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Definindo as restrições para o UIHostingController
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

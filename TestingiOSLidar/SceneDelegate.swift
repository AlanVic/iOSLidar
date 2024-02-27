//
//  SceneDelegate.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 16/09/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let userSawOnboarding = UserDefaults.standard.bool(forKey: "onboarding")
        window?.rootViewController = userSawOnboarding ? createFeaturesViewController() : OnboardingViewController()
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Private Methods
    
    private func createFeaturesViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .init(for: AppDelegate.self))
        let viewController = storyboard.instantiateViewController(withIdentifier: "Features")
        return UINavigationController(rootViewController: viewController)
    }
}


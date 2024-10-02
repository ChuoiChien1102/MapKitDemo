//
//  SceneDelegate.swift
//  MapKitQuestion2
//
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard (scene is UIWindowScene) else { return }
        
        // Create a new UIWindow instance with the windowScene
        let mainVC = ViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)
        
        // Set the initial view controller
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

//
//  SplashViewController.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 31.05.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        let window = UIApplication.shared.sceneDelegate?.window ?? UIWindow()
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            UIApplication.shared.rootViewController = HomeViewController()
        }
    }
}

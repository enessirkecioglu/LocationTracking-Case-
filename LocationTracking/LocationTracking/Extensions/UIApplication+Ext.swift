//
//  UIApplication+Ext.swift
//  LocationTracking
//
//  Created by Enes Sirkecioğlu on 31.05.2024.
//

import UIKit

extension UIApplication {
    
    var sceneDelegate: SceneDelegate? {
        return UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
    }
    
    var rootViewController: UIViewController? {
        get {
            return sceneDelegate?.window?.rootViewController
        }
        set {
            sceneDelegate?.window?.rootViewController = newValue
        }
    }
}

//
//  AppDelegate.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.01.26.
//

import Foundation
import UIKit

extension Notification.Name {
    static let mainCommandShortcut = Notification.Name("mainCommandShortcut")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

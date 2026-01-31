//
//  SceneDelegate.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.01.26.
//

import Foundation
import UIKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {

    // if application runs
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcutItem(shortcutItem)
        completionHandler(true)
    }

    // if application not runs
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("\(connectionOptions)") 
        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcutItem(shortcutItem)
        }
    }

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case "seeb.HARemoteIOS.mainCommand":
            let str = shortcutItem.userInfo!["id"] as! String
            IntentHandleService.shared.mainCommandId = str
        default:
            return
        }
    }
}


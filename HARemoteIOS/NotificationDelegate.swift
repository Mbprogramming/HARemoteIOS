//
//  NotificationDelegate.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 21.01.26.
//

import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Erlaubt das Anzeigen des Banners, auch wenn die App offen ist
        completionHandler([.banner, .sound, .list]) // .list für das Notification Center
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
    
        // Hier können Sie Daten aus der Nachricht auslesen (z.B. eine ID für Deep Linking)
        if let customData = userInfo["executionId"] as? String {
            HomeRemoteAPI.shared.removeBanner(executionId: customData)
        }
        
        // WICHTIG: Den CompletionHandler aufrufen
        completionHandler()
    }
}

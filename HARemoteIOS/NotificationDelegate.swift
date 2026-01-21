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
}

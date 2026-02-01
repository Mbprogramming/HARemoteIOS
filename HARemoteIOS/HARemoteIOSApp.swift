//
//  HARemoteIOSApp.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 21.11.25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct HARemoteIOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var showFeedbackAlert: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: .mainCommandShortcut)) { obj in
                    showFeedbackAlert.toggle()
                }
            .onAppear {
                requestNotificationPermission()
            }
            .alert(isPresented: $showFeedbackAlert) {
                Alert(
                    title: Text("Please Give Us a Second Chance"),
                    message: Text("We’d love your feedback before you uninstall."),
                    primaryButton: .default(Text("Send Feedback")) {
                        // perform feedback navigation/action here
                    },
                    secondaryButton: .cancel(Text("Maybe Later"))
                )
            }
        }
        .modelContainer(for: [RemoteHistoryEntry.self, RemoteFavorite.self, HueMultiEntry.self])
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
}

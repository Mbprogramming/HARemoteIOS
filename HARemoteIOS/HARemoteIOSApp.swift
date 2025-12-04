//
//  HARemoteIOSApp.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 21.11.25.
//

import SwiftUI
import SwiftData

@main
struct HARemoteIOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [RemoteHistoryEntry.self, RemoteFavorite.self])
    }
}

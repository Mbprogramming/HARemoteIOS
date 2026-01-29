//
//  Untitled.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 23.01.26.
//

import AppIntents

struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts : [AppShortcut] {
        AppShortcut(
            intent: RunCommandIntent(),
            phrases: [
                "Starte Befehl mit \(.applicationName)",
                "Starte mit \(.applicationName)"
            ],
            shortTitle: "Befehl starten",
            systemImageName: "play.circle"
        )
        AppShortcut(
            intent: OpenRemoteIntent(),
            phrases: [
                "Öffne Fernbedienung mit \(.applicationName)",
                "Öffne mit \(.applicationName)"
            ],
            shortTitle: "Öffne Fernbedienung",
            systemImageName: "av.remote"
        )
    }
}

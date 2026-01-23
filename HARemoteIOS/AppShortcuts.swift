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
            ],
            shortTitle: "Befehl starten",
            systemImageName: "av.remote"
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
        AppShortcut(
            intent: RunMainCommandIntent(),
            phrases: [
                "Starte Hauptbefehl mit \(.applicationName)",
                "Ausführen mit \(.applicationName)"
            ],
            shortTitle: "Hauptbefehl starten",
            systemImageName: "av.remote"
        )
    }
}

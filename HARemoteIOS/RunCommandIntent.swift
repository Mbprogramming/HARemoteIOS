//
//  RunCommandIntent.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 23.01.26.
//

import Foundation
import AppIntents

struct RunCommandIntent: AppIntent {
    static var title: LocalizedStringResource = "Starte einen Befehl"
    static var description = IntentDescription("Führe einen bestimmten Befehl aus")
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Gerät")
    var device: String

    @Parameter(title: "Befehl")
    var command: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: "Befehl \(command) für \(device) wurde gesendet.")
    }
}

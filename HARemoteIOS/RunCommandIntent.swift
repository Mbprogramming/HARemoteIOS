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
    
    @Parameter(title: "Befehl")
    var command: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        IntentHandleService.shared.command = command
        IntentHandleService.shared.intentType = "RunCommandIntent"
        
        return .result(dialog: "Befehl \(command) wurde gesendet.")
    }
}

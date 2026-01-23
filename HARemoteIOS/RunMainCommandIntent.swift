//
//  RunMainCommandIntent.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 23.01.26.
//

import Foundation
import AppIntents

struct RunMainCommandIntent: AppIntent {
    static var title: LocalizedStringResource = "Starte einen Hauptbefehl"
    static var description = IntentDescription("Führe einen bestimmten Hauptbefehl aus")
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Befehl")
    var command: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        IntentHandleService.shared.command = command
        IntentHandleService.shared.intentType = "RunMainCommandIntent"
        
        return .result(dialog: "Hauptbefehl \(command) wurde gesendet.")
    }
}

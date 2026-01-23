//
//  OpenRemoteIntent.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 23.01.26.
//

import Foundation
import AppIntents

struct OpenRemoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Öffnet eine Fernbedienung"
    static var description = IntentDescription("Öffne eine Fernbedienung")
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Fernbedienung")
    var remote: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: "Remote \(remote) wird geöffnet.")
    }
}

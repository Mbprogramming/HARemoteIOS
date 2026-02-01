//
//  SearchResult.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 27.01.26.
//

import Foundation

@Observable
final class SearchResult : Identifiable {
    var remote: Remote?
    var command: SearchableCommand?
    var mainCommand: SearchableCommand?
    var score: Double?
    var range: [ClosedRange<Int>]?
    private let fallbackId = UUID().uuidString
    var id: String {
        remote?.id ?? command?.id ?? mainCommand?.id ?? fallbackId
    }

    init(remote: Remote? = nil, score: Double? = nil, range: [ClosedRange<Int>]? = nil) {
        self.remote = remote
        self.score = score
        self.range = range
    }
    
    init(command: SearchableCommand? = nil, score: Double? = nil, range: [ClosedRange<Int>]? = nil, isMainCommand: Bool = false) {
        if isMainCommand {
            self.mainCommand = command
            self.score = score
            self.range = range
        } else {
            self.command = command
            self.score = score
            self.range = range
        }
    }
}

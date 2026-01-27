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
    var score: Double?
    var range: [ClosedRange<Int>]?
    var id: String {
        remote?.id ?? UUID().uuidString
    }

    init(remote: Remote? = nil, score: Double? = nil, range: [ClosedRange<Int>]? = nil) {
        self.remote = remote
        self.score = score
        self.range = range
    }
}

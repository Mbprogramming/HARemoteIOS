//
//  StringStringTuple.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 09.12.25.
//
// Maybe use a generic Tuple class in the future

import Foundation
import Observation

@Observable class StringStringTuple: Decodable, Identifiable, Hashable, Equatable {
    let item1: String?
    let item2: String?

    // Provide a deterministic id derived from the pair (item1,item2)
    var id: String { "\(item1 ?? "<nil>")|\(item2 ?? "<nil>")" }

    static func == (lhs: StringStringTuple, rhs: StringStringTuple) -> Bool {
        return lhs.item1 == rhs.item1 && lhs.item2 == rhs.item2
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(item1 ?? "")
        hasher.combine(item2 ?? "")
    }
}

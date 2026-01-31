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
    
    // Use item1 as the identity
    var id: String? { item1 }
    
    static func == (lhs: StringStringTuple, rhs: StringStringTuple) -> Bool {
        return lhs.item1 == rhs.item1
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(item1)
    }
}

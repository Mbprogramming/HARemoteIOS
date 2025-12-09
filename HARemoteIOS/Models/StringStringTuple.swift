//
//  StringStringTuple.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 09.12.25.
//

import Foundation
import Observation

@Observable class StringStringTuple: Decodable, Identifiable {
    let item1: String?
    let item2: String?
}

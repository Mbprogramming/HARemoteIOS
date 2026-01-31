//
//  HueMultiEntry.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 08.01.26.
//

import Foundation
import SwiftData

@Model
final class HueMultiEntry {
    var id: UUID = UUID()
    var name: String = ""
    var ids: String = ""
    
    init(id: UUID = UUID(), name: String = "", ids: String = "") {
        self.id = id
        self.name = name
        self.ids = ids
    }
}

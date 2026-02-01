//
//  ListViewRow.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 07.01.26.
//

import Foundation
import Observation

@Observable class ListViewRow : Identifiable {
    var id: UUID = UUID()
    var items: [RemoteItem?] = []
    
    var count: Int {
        return items.count
    }
}

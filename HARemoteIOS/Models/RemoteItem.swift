//
//  RemoteItem.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import Foundation
import Observation

@Observable class RemoteItem : Decodable, Identifiable, Equatable {
    static func == (lhs: RemoteItem, rhs: RemoteItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String?
    let template: RemoteTemplate?
    let description: String?
    let children: [RemoteItem]?
    let device: String?
    let command: String?
    let stateDevice: String?
    let state: String?
    let stateIcon: String?
    let clientIcon: String?
    let showStateAndIcon: Bool?
    //stateColor    [...]
    let posX: Int?
    let posY: Int?
    let rowSpan: Int?
    let colSpan: Int?
    let icon: String?
    let min: String?
    let max: String?
    let step: String?
    let greatStep: String?
    let steps: [StringStringTuple]?
    let lastChange: String?
    //moreParameter    {...}
    //nullable: true
    //defaultConverter    [...]
    let gridHalfHeight: Bool?
    let commandMenuItems: [RemoteItem]?
    //stateList    [...]
    //gridBackgroundOpacity    [...]
    //gridBackgroundColor    [...]
    let backgroundImage: String?
    //buttonForm    ButtonFormEnum[...]
    
    var lastChangeDate: Date? {
        if let ls = lastChange {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: ls) {
                return date
            }
        }
        return nil
    }
    
    public func calculateUsedGridRows() -> Int {
        if template == .Grid3x4Inline ||
            template == .Grid4x5Inline ||
            template == .Grid5x3Inline ||
            template == .Grid6x4Inline {
            var maxRow = -1
            if children != nil {
                for child in children! {
                    if child.posY != nil && child.posY! > maxRow {
                        maxRow = child.posY!
                    }
                }
                return maxRow + 1
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
}

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
    
    enum CodingKeys: CodingKey {
        case id
        case template
        case description
        case children
        case device
        case command
        case stateDevice
        case state
        case stateIcon
        case clientIcon
        case showStateAndIcon
        case posX
        case posY
        case rowSpan
        case colSpan
        case icon
        case min
        case max
        case step
        case greatStep
        case steps
        case lastChange
        case moreParameter
        case gridHalfHeight
        case commandMenuItems
        case backgroundImage
        case _$observationRegistrar
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.template = try container.decodeIfPresent(RemoteTemplate.self, forKey: .template)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.children = try container.decodeIfPresent([RemoteItem].self, forKey: .children)
        self.device = try container.decodeIfPresent(String.self, forKey: .device)
        self.command = try container.decodeIfPresent(String.self, forKey: .command)
        self.stateDevice = try container.decodeIfPresent(String.self, forKey: .stateDevice)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
        self.stateIcon = try container.decodeIfPresent(String.self, forKey: .stateIcon)
        self.clientIcon = try container.decodeIfPresent(String.self, forKey: .clientIcon)
        self.showStateAndIcon = try container.decodeIfPresent(Bool.self, forKey: .showStateAndIcon)
        self.posX = try container.decodeIfPresent(Int.self, forKey: .posX)
        self.posY = try container.decodeIfPresent(Int.self, forKey: .posY)
        self.rowSpan = try container.decodeIfPresent(Int.self, forKey: .rowSpan)
        self.colSpan = try container.decodeIfPresent(Int.self, forKey: .colSpan)
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.min = try container.decodeIfPresent(String.self, forKey: .min)
        self.max = try container.decodeIfPresent(String.self, forKey: .max)
        self.step = try container.decodeIfPresent(String.self, forKey: .step)
        self.greatStep = try container.decodeIfPresent(String.self, forKey: .greatStep)
        self.steps = try container.decodeIfPresent([StringStringTuple].self, forKey: .steps)
        self.lastChange = try container.decodeIfPresent(String.self, forKey: .lastChange)
        self.moreParameter = try container.decodeIfPresent([String : String].self, forKey: .moreParameter)
        self.gridHalfHeight = try container.decodeIfPresent(Bool.self, forKey: .gridHalfHeight)
        self.commandMenuItems = try container.decodeIfPresent([RemoteItem].self, forKey: .commandMenuItems)
        self.backgroundImage = try container.decodeIfPresent(String.self, forKey: .backgroundImage)
    }
    
    init(id: String? = nil, template: RemoteTemplate? = nil, description: String? = nil, device: String? = nil, command: String? = nil, icon: String? = nil) {
        self.id = id
        self.template = template
        self.device = device
        self.command = command
        self.icon = icon
        self.description = description
        self.children = nil
        self.stateDevice = nil
        self.state = nil
        self.stateIcon = nil
        self.clientIcon = nil
        self.showStateAndIcon = nil
        self.posX = nil
        self.posY = nil
        self.rowSpan = nil
        self.colSpan = nil
        self.min = nil
        self.max = nil
        self.step = nil
        self.greatStep = nil
        self.steps = nil
        self.lastChange = nil
        self.moreParameter = nil
        self.gridHalfHeight = nil
        self.commandMenuItems = nil
        self.backgroundImage = nil
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
    let moreParameter: Dictionary<String, String>?
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

//
//  HACommand.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 20.01.26.
//

import Foundation

@Observable class HACommand: Decodable, Identifiable, Equatable, Hashable {
    static func == (lhs: HACommand, rhs: HACommand) -> Bool {
        if let lid = lhs.id, let rid = rhs.id {
            return lid == rid
        }
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        if let id = id {
            hasher.combine(id)
        } else {
            hasher.combine(ObjectIdentifier(self))
        }
    }
    
    let id: String?
    let device: String?
    let group: String?
    let description: String?
    let template: String?
    let commandType: CommandType?
    let defaultConverter: String?
    
    public var emptyGroup: String? {
        if group == nil {
            return "Empty"
        } else {
            return group
        }
    }
}

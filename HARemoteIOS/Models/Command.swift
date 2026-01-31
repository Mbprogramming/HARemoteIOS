//
//  ICommand.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 20.01.26.
//

import Foundation

@Observable class Command: Decodable, Identifiable, Equatable, Hashable {
    static func == (lhs: Command, rhs: Command) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String?
    let device: String?
    let group: String?
    let description: String?
    let template: String?
    let commandType: CommandType?
    let defaultConverter: String?
}

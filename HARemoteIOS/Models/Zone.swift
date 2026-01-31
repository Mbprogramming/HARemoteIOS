//
//  Zone.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import Foundation
import Observation

@Observable class Zone: Decodable, Identifiable {
    let description: String
    let icon: String?
    let background: String?
    let id: String
    let mainCommands: [String]?
    let remoteIds: [String]?
    //let lastChange: Double
    let isVisible: Bool?
}

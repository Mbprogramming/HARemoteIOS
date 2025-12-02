//
//  State.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 02.12.25.
//

import Foundation
import Observation

@Observable class IState: Decodable, Identifiable {
    let id: String?
    let device: String?
    let value: String?
    let convertedValue: String?
    let color: Int64?
    let icon: String?
    let convertDescription: String?
    let nativeType: String?
    let showValueAndIcon: Bool?
    let stateToIcon: String?
    let stateToColor: String?
    //lastChange    [...]
    let isCombined: Bool?
    let additionalText: String?
}

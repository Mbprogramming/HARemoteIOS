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
    
    var completeValue : String {
        get {
            return self.convertedValue ?? self.value ?? "N/A"
        }
    }
    
    var showImage : Bool {
        get {
            if icon != nil && icon?.isEmpty == false {
                return true
            }
            return false
        }
    }
    
    var showText : Bool {
        get {
            if showImage == false {
                return true
            }
            if showValueAndIcon == true {
                return true
            }
            return false
        }
    }
}

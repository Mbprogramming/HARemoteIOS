//
//  State.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 02.12.25.
//

import SwiftUI
import Foundation
import Observation

@Observable class IState: Decodable, Identifiable, Equatable {
    static func == (lhs: IState, rhs: IState) -> Bool {
        return lhs.device == rhs.device && lhs.id == rhs.id && lhs.value == rhs.value
    }
    
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
    let lastChange: String?
    let isCombined: Bool?
    let additionalText: String?
    
    init(id: String?, device: String?, value: String?, convertedValue: String?, color: Int64?, icon: String?, convertDescription: String?,
         nativeType: String?, showValueAndIcon: Bool?, stateToIcon: String?, stateToColor: String?, isCombined: Bool?, additionalText: String?,
         lastChange: String?) {
        self.id = id
        self.device = device
        self.value = value
        self.convertedValue = convertedValue
        self.color = color
        self.icon = icon
        self.convertDescription = convertDescription
        self.nativeType = nativeType
        self.showValueAndIcon = showValueAndIcon
        self.stateToIcon = stateToIcon
        self.stateToColor = stateToColor
        self.isCombined = isCombined
        self.additionalText = additionalText
        self.lastChange = lastChange
    }
    
    var completeValue : String {
        get {
            return self.convertedValue ?? self.value ?? "N/A"
        }
    }
    
    var showImage : Bool {
        get {
            if self.icon != nil && self.icon?.isEmpty == false {
                return true
            }
            return false
        }
    }
    
    var showText : Bool {
        get {
            if self.showImage == false {
                return true
            }
            if self.showValueAndIcon == nil || self.showValueAndIcon == true {
                return true
            }
            return false
        }
    }
    
    private func uiColorFromHex(rgbValue: Int64) -> UIColor {
        
        // &  binary AND operator to zero out other color values
        // >>  bitwise right shift operator
        // Divide by 0xFF because UIColor takes CGFloats between 0.0 and 1.0
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var calculatedColor : Color {
        get {
            return self.color != nil ? Color(uiColorFromHex(rgbValue: Int64(self.color!))).opacity(0.3) : Color.primary.opacity(0.3)
        }
    }
    
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
}

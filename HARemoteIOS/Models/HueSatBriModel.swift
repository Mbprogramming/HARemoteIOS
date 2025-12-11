//
//  HueSatBriModel.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 11.12.25.
//

import Foundation
import Observation

@Observable final class HueSatBriModel {
    var hue: Int = 0
    var saturation: Int = 0
    var brightness: Int = 0
    
    let hueRange: ClosedRange<Double> = 0...1
    let saturationRange: ClosedRange<Double> = 0...1
    let brightnessRange: ClosedRange<Double> = 0...1
    
    var hueDouble: Double {
        get {
            return Double(self.hue) / 255.0
        }
        set {
            self.hue = Int(newValue * 255.0)
        }
    }
    
    var hueString: String {
        get {
            return "\((Double(self.hue) * 360.0 / 255).rounded())°"
        }
    }
    
    var saturationDouble: Double {
        get {
            return Double(self.saturation) / 255.0
        }
        set {
            self.saturation = Int(newValue * 255.0)
        }
    }
    
    var saturationString: String {
        get {
            return "\((Double(self.saturation) * 100.0 / 254).rounded())%"
        }
    }
    
    var brightnessDouble: Double {
        get {
            return Double(self.brightness) / 255.0
        }
        set {
            self.brightness = Int(newValue * 255.0)
        }
    }
    
    var brightnessString: String {
        get {
            return "\((Double(self.brightness) * 100.0 / 254).rounded())%"
        }
    }
}

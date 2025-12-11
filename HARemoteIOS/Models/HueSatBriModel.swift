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
    var temperature: Int = 0
    
    var hueMin: Int = 0
    var hueMax: Int = 255
    var saturationMin: Int = 0
    var saturationMax: Int = 255
    var brightnessMin: Int = 0
    var brightnessMax: Int = 255
    var temperatureMin: Int = 0
    var temperatureMax: Int = 255
    
    public func setRanges(min: String, max: String) {
        let partsMin = min.components(separatedBy: ";")
        for part in partsMin {
            let inner = part.components(separatedBy: ":")
            if inner.count == 2 {
                if inner[0] == "Hue" {
                    hueMin = Int(inner[1]) ?? 0
                }
                if inner[0] == "Saturation" {
                    saturationMin = Int(inner[1]) ?? 0
                }
                if inner[0] == "Brightness" {
                    brightnessMin = Int(inner[1]) ?? 0
                }
                if inner[0] == "ColorTemperature" {
                    temperatureMin = Int(inner[1]) ?? 0
                }
            }
        }
        let partsMax = max.components(separatedBy: ";")
        for part in partsMax {
            let inner = part.components(separatedBy: ":")
            if inner.count == 2 {
                if inner[0] == "Hue" {
                    hueMax = Int(inner[1]) ?? 0
                }
                if inner[0] == "Saturation" {
                    saturationMax = Int(inner[1]) ?? 0
                }
                if inner[0] == "Brightness" {
                    brightnessMax = Int(inner[1]) ?? 0
                }
                if inner[0] == "ColorTemperature" {
                    temperatureMax = Int(inner[1]) ?? 0
                }
            }
        }
        hue = hueMin
        saturation = saturationMin
        brightness = brightnessMin
        temperature = temperatureMin
    }
    
    public func setState(state: IState) {
        let partsValue = state.value?.components(separatedBy: ";") ?? []
        for part in partsValue {
            let inner = part.components(separatedBy: ":")
            if inner.count == 2 {
                if inner[0] == "Hue" {
                    hue = Int(inner[1]) ?? 0
                }
                if inner[0] == "Saturation" {
                    saturation = Int(inner[1]) ?? 0
                }
                if inner[0] == "Brightness" {
                    brightness = Int(inner[1]) ?? 0
                }
                if inner[0] == "ColorTemperature" {
                    temperature = Int(inner[1]) ?? 0
                }
            }
        }
    }
    
    let hueRange: ClosedRange<Double> = 0...1
    let saturationRange: ClosedRange<Double> = 0...1
    let brightnessRange: ClosedRange<Double> = 0...1
    let temperatureRange: ClosedRange<Double> = 0...1
    
    var hueDouble: Double {
        get {
            return Double(hue - hueMin) / Double(hueMax - hueMin)
        }
        set {
            hue = Int(newValue * Double(hueMax - hueMin)) + hueMin
        }
    }
    
    var hueString: String {
        get {
            return "\((Double(hue - hueMin) * 360.0 / Double(hueMax - hueMin)).rounded())°"
        }
    }
    
    var temperatureDouble: Double {
        get {
            return Double(temperature - temperatureMin) / Double(temperatureMax - temperatureMin)
        }
        set {
            temperature = Int(newValue * Double(temperatureMax - temperatureMin)) + temperatureMin
        }
    }
    
    var temperatureString: String {
        get {
            return "\((1000000 / Double(temperature)).rounded())K"
        }
    }
    
    
    var saturationDouble: Double {
        get {
            return Double(saturation - saturationMin) / Double(saturationMax - saturationMin)
        }
        set {
            saturation = Int(newValue * Double(saturationMax - saturationMin)) + saturationMin
        }
    }
    
    var saturationString: String {
        get {
            return "\((Double(saturation - saturationMin) * 100.0 / Double(saturationMax - saturationMin)).rounded())%"
        }
    }
    
    var brightnessDouble: Double {
        get {
            return Double(brightness - brightnessMin) / Double(brightnessMax - brightnessMin)
        }
        set {
            brightness = Int(newValue * Double(brightnessMax - brightnessMin)) + brightnessMin
        }
    }
    
    var brightnessString: String {
        get {
            return "\((Double(brightness - brightnessMin) * 100.0 / Double(brightnessMax - brightnessMin)).rounded())%"
        }
    }
    
    var hueSatBriComplete: String {
        get {
            return "Hue:\(hue);Saturation:\(saturation);Brightness:\(brightness);"
        }
    }
    
    var tempBriComplete: String {
        get {
            return "ColorTemperature:\(temperature);Brightness:\(brightness);"
        }
    }
}

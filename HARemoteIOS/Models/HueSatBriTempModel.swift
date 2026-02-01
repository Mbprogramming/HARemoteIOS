//
//  HueSatBriModel.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 11.12.25.
//

import Foundation
import Observation

@Observable final class HueSatBriTempModel {
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
    
    public func setRangesHue(min: String, max: String) {
        hueMin = Int(min) ?? 0
        hueMax = Int(max) ?? 0
        hue = hueMin
    }
    
    public func setRangesSat(min: String, max: String) {
        saturationMin = Int(min) ?? 0
        saturationMax = Int(max) ?? 0
        saturation = saturationMin
    }
    
    public func setRangesBri(min: String, max: String) {
        brightnessMin = Int(min) ?? 0
        brightnessMax = Int(max) ?? 0
        brightness = brightnessMin
    }
    
    public func setRangesTemperature(min: String, max: String) {
        temperatureMin = Int(min) ?? 0
        temperatureMax = Int(max) ?? 0
        temperature = temperatureMin
    }
    
    public func setState(state: HAState) {
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
    
    public func setStateHue(state: HAState) {
        hue = Int(state.value ?? "0") ?? 0
    }

    public func setStateSat(state: HAState) {
        saturation = Int(state.value ?? "0") ?? 0
    }

    public func setStateBri(state: HAState) {
        brightness = Int(state.value ?? "0") ?? 0
    }

    public func setStateTemp(state: HAState) {
        temperature = Int(state.value ?? "0") ?? 0
    }

    let hueRange: ClosedRange<Double> = 0...1
    let saturationRange: ClosedRange<Double> = 0...1
    let brightnessRange: ClosedRange<Double> = 0...1
    let temperatureRange: ClosedRange<Double> = 0...1
    
    var hueDouble: Double {
        get {
            let denom = hueMax - hueMin
            guard denom != 0 else { return 0.0 }
            return Double(hue - hueMin) / Double(denom)
        }
        set {
            let denom = hueMax - hueMin
            if denom == 0 {
                hue = hueMin
            } else {
                hue = Int(newValue * Double(denom)) + hueMin
            }
        }
    }
    
    var hueString: String {
        get {
            let denom = hueMax - hueMin
            guard denom != 0 else { return "0°" }
            return "\((Double(hue - hueMin) * 360.0 / Double(denom)).rounded())°"
        }
    }
    
    var temperatureDouble: Double {
        get {
            let denom = temperatureMax - temperatureMin
            guard denom != 0 else { return 0.0 }
            return Double(temperature - temperatureMin) / Double(denom)
        }
        set {
            let denom = temperatureMax - temperatureMin
            if denom == 0 {
                temperature = temperatureMin
            } else {
                temperature = Int(newValue * Double(denom)) + temperatureMin
            }
        }
    }
    
    var temperatureString: String {
        get {
            guard temperature != 0 else { return "N/A" }
            return "\((1000000 / Double(temperature)).rounded())K"
        }
    }    
    var saturationDouble: Double {
        get {
            let denom = saturationMax - saturationMin
            guard denom != 0 else { return 0.0 }
            return Double(saturation - saturationMin) / Double(denom)
        }
        set {
            let denom = saturationMax - saturationMin
            if denom == 0 {
                saturation = saturationMin
            } else {
                saturation = Int(newValue * Double(denom)) + saturationMin
            }
        }
    }
    
    var saturationString: String {
        get {
            let denom = saturationMax - saturationMin
            guard denom != 0 else { return "0%" }
            return "\((Double(saturation - saturationMin) * 100.0 / Double(denom)).rounded())%"
        }
    }
    
    var brightnessDouble: Double {
        get {
            let denom = brightnessMax - brightnessMin
            guard denom != 0 else { return 0.0 }
            return Double(brightness - brightnessMin) / Double(denom)
        }
        set {
            let denom = brightnessMax - brightnessMin
            if denom == 0 {
                brightness = brightnessMin
            } else {
                brightness = Int(newValue * Double(denom)) + brightnessMin
            }
        }
    }
    
    var brightnessString: String {
        get {
            let denom = brightnessMax - brightnessMin
            guard denom != 0 else { return "0%" }
            return "\((Double(brightness - brightnessMin) * 100.0 / Double(denom)).rounded())%"
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
    
    var briComplete: String {
        get {
            return "Brightness:\(brightness)"
        }
    }
    
    var tempComplete: String {
        get {
            return "ColorTemperature:\(temperature)"
        }
    }
    
    var hueComplete: String {
        get {
            return "Hue:\(hue)"
        }
    }
    
    var satComplete: String {
        get {
            return "Saturation:\(saturation)"
        }
    }
}

//
//  CommandType.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 20.01.26.
//

import Foundation

enum CommandType: String, Decodable {
    case Unknown
    case Push
    case OnOff
    case ParameterMinMaxDouble
    case ParameterMinMaxInt
    case ParameterListDouble
    case ParameterListInt
    case ParameterListString
    case ParameterString
    case ParameterHueSaturationBrightness
    case ParameterTemperatureBrightness
    case ParameterMinMaxIntHue
    case ParameterMinMaxIntHueBri
    case ParameterMinMaxIntHueSat
    case ParameterMinMaxIntHueHue
    case ParameterMinMaxIntHueTemp
    case ParameterMultipleListBool
    case ParameterMultipleListString
    case ParameterMultipleListTempBri
    case ParameterMultipleListHueSatBri
    case ParameterMultipleListBri
    case OpenRemote
    case LastRemote
}

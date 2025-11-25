//
//  RemoteTemplate.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 25.11.25.
//

import Foundation

enum RemoteTemplate: String, Decodable {
    case Command
    case OnOff
    case Headline
    case State
    case List
    case Wrap
    case Grid3X4
    case Grid3x4Inline
    case Grid4X5
    case Grid4x5Inline
    case Slider
    case Combobox
    case SliderHue
    case SliderHueSatBri
    case SliderTempBri
    case SliderHueHue
    case SliderHueBri
    case SliderHueTemp
    case SliderHueSat
    case Space
    case Divider
    case Touch
    case SelectionList
    case SelectionListTempBri
    case SelectionListHueSatBri
    case SelectionListBri
    case CommandList
    case SelectionListParameter
    case StateList
    case Grid5x3
    case Grid5x3Inline
    case Grid6x4
    case Grid6x4Inline
    case TwoColumnList
    case EmptyListItem
}

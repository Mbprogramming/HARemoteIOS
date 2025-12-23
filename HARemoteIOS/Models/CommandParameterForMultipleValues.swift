//
//  CommandParameterForMultipleValues.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.12.25.
//

import Foundation

class CommandParameterForMultipleValues: Decodable, Encodable, Identifiable {
    var Ids: [String] = []
    var Descriptions: [String] = []
    var Parameter: String = ""
}

//
//  ContinueMacroParameter.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 08.12.25.
//

import Foundation

class ContinueMacroParameter: Decodable, Encodable, Identifiable {
    let currentTaskId: String
    let currentAnswer: Int
    
    init(currentTaskId: String = "", currentAnswer: Int = -1) {
        self.currentTaskId = currentTaskId
        self.currentAnswer = currentAnswer
    }
}

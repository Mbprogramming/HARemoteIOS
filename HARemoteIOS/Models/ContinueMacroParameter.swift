//
//  ContinueMacroParameter.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 08.12.25.
//

import Foundation

class ContinueMacroParameter: Decodable, Encodable, Identifiable {
    let CurrentTaskId: String
    let CurrentAnswer: Int
    
    var id: String { CurrentTaskId }
}    
    init(currentTaskId: String = "", currentAnswer: Int = -1) {
        CurrentTaskId = currentTaskId
        CurrentAnswer = currentAnswer
    }
}

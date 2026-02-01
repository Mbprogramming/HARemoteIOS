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

    var id: String { currentTaskId }

    init(currentTaskId: String = "", currentAnswer: Int = -1) {
        self.currentTaskId = currentTaskId
        self.currentAnswer = currentAnswer
    }

    private enum CodingKeys: String, CodingKey {
        case currentTaskId = "CurrentTaskId"
        case currentAnswer = "CurrentAnswer"
    }
}

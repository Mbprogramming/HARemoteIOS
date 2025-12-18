//
//  AutomaticExecutionEntry.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 17.12.25.
//

import Foundation

import Observation

enum AutomaticExecutionType: Decodable, Equatable {
    case deferred
    case executeAt
    case stateChange
    case unknown(value: String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
            case "Deferred": self = .deferred
            case "ExecuteAt": self = .executeAt
            case "StateChange": self = .stateChange
            default: self = .unknown(value: status ?? "unknown")
          }
      }
}

enum AutomaticExecutionAtCycle: Decodable, Equatable {
    case none
    case daily
    case weekly
    case monthly
    case unknown(value: String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
            case "None": self = .none
            case "Daily": self = .daily
            case "Weekly": self = .weekly
            case "Monthly": self = .monthly
            default: self = .unknown(value: status ?? "unknown")
          }
      }
}

enum CheckStateOperationEnum: Decodable {
    case lighter
    case lighterEqual
    case greater
    case greaterEqual
    case numEqual
    case notNumEqual
    case stringEqual
    case notStringEqual
    case wildCard
    case notWildCard
    case boolEqual
    case unknown(value: String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
            case "Lighter": self = .lighter
            case "LighterEqual": self = .lighterEqual
            case "Greater": self = .greater
            case "GreaterEqual": self = .greaterEqual
            case "NumEqual": self = .numEqual
            case "NotNumEqual": self = .notNumEqual
            case "StringEqual": self = .stringEqual
            case "NotStringEqual": self = .notStringEqual
            case "WildCard": self = .wildCard
            case "NotWildCard": self = .notWildCard
            case "BoolEqual": self = .boolEqual
            default: self = .unknown(value: status ?? "unknown")
            }
      }
}

@Observable class AutomaticExecutionEntry : Decodable, Identifiable {
    let description: String?
    let id: String?
    let device: String?
    let command: String?
    let cyclic: Bool?
    let hasParameter: Bool?
    let parameter: String?
    let decodedParameter: String?
    let automaticExecutionType: AutomaticExecutionType?
    let automaticExecutionAtCycle: AutomaticExecutionAtCycle?
    let at: String?
    let nextExecution: String?
    let nextExecutionString: String?
    let commandDescription: String?
    //firebaseService    IFirebaseService{...}
    // sendFirebase    [...]
    let operationEnum: CheckStateOperationEnum?
    let stateDevice: String?
    let state: String?
    let stateType: String?
    let limit: String?
    
    var operationString: String {
        get {
            if let operationEnum = self.operationEnum {
                switch operationEnum {
                case .lighter:
                    return "<"
                case .lighterEqual:
                    return "<="
                case .greater:
                    return ">"
                case .greaterEqual:
                    return ">="
                case .numEqual:
                    return "=="
                case .notNumEqual:
                    return "!="
                case .stringEqual:
                    return "=="
                case .notStringEqual:
                    return "!="
                case .wildCard:
                    return "*"
                case .notWildCard:
                    return "!*"
                case .boolEqual:
                    return "=="
                case .unknown( _):
                    return ""
                }
            }
            return ""
        }
    }
    
    var compareDescription : String {
        get {
            return "\(self.state ?? "") (\(self.stateDevice ?? "")) \(self.operationString) \(self.limit ?? "")"
        }
    }
}


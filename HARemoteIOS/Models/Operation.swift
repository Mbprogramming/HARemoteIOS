//
//  Operation.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 20.01.26.
//

import Foundation

enum Operation: String, Decodable, CaseIterable, Identifiable {
    case Lighter
    case LighterEqual
    case Greater
    case GreaterEqual
    case NumEqual
    case NotNumEqual
    case StringEqual
    case NotStringEqual
    case WildCard
    case NotWildCard
    case BoolEqual
    
    var id: Self { self }
    
    var showValue: String {
        switch self {
        case .Lighter: return "<"
        case .LighterEqual: return "<="
        case .Greater: return ">"
        case .GreaterEqual: return ">="
        case .NumEqual: return "=="
        case .NotNumEqual: return "!="
        case .StringEqual: return "=="
        case .NotStringEqual: return "!="
        case .WildCard: return "*"
        case .NotWildCard: return "!*"
        case .BoolEqual: return "=="
        }
    }
}

enum OperationString: String, Decodable, CaseIterable, Identifiable {
    case StringEqual
    case NotStringEqual
    case WildCard
    case NotWildCard
    
    var id: Self { self }
    
    var showValue: String {
        switch self {
        case .StringEqual: return "=="
        case .NotStringEqual: return "!="
        case .WildCard: return "*"
        case .NotWildCard: return "!*"
        }
    }
}

enum OperationNum: String, Decodable, CaseIterable, Identifiable {
    case Lighter
    case LighterEqual
    case Greater
    case GreaterEqual
    case NumEqual
    case NotNumEqual
    
    var id: Self { self }
    
    var showValue: String {
        switch self {
        case .Lighter: return "<"
        case .LighterEqual: return "<="
        case .Greater: return ">"
        case .GreaterEqual: return ">="
        case .NumEqual: return "=="
        case .NotNumEqual: return "!="
        }
    }
}

enum OperationBool: String, Decodable, CaseIterable, Identifiable {
    case BoolEqual
    
    var id: Self { self }
    
    var showValue: String {
        switch self {
        case .BoolEqual: return "=="
        }
    }
}

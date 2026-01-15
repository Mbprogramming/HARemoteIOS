//
//  IntentHandleService.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.01.26.
//

import Foundation

final class IntentHandleService {
    
    static let shared = IntentHandleService()
    
    private init() {
    }
    
    public var mainCommandId: String? = nil
}

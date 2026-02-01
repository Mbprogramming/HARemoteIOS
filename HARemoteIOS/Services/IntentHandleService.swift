//
//  IntentHandleService.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.01.26.
//

import Foundation

@MainActor @Observable
public class IntentHandleService: @unchecked Sendable {
    
    public var intentType: String? = nil
    public var command: String? = nil
    public var device: String? = nil
    public var remote: String? = nil
    public var mainCommandId: String? = nil

    static let shared = IntentHandleService()
    
    private init() {
    }
}

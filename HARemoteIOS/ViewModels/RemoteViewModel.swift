//
//  RemoteViewModel.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import Foundation
import Combine

@MainActor
@Observable final class RemoteViewModel {
    var currentRemote: RemoteItem?
    
    func load() {
        currentRemote = HomeRemoteAPI.shared.currentRemote
    }
}

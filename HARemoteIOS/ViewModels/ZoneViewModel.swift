//
//  ZoneViewModel.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import Foundation
import Combine

@MainActor
final class ZoneViewModel: ObservableObject {
    @Published var zones: [Zone] = []
    @Published var remotes: [Remote] = []
        
    func loadZones() async {
        do {
            zones = try await HomeRemoteAPI.shared.getZonesComplete()
        } catch {
            print("Fehler: \(error)")
        }
    }
    
    func loadRemotes() async {
        do {
            remotes = try await HomeRemoteAPI.shared.getRemotes()
        } catch {
            print("Fehler: \(error)")
        }
    }
}

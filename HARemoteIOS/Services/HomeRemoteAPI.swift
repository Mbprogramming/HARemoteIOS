//
//  HomeRemoteAPI.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import Foundation

protocol HomeRemoteAPIProtocol {
    func getZonesComplete() async throws -> [Zone]
    func getRemotes() async throws -> [Remote]
}

final class HomeRemoteAPI: HomeRemoteAPIProtocol {
    static let shared = HomeRemoteAPI()
    
    private var zones: [Zone] = []
    private var remotes: [Remote] = []
    
    var currentRemote: RemoteItem?
        
    private init() {
    }
    
    func getZonesComplete() async throws -> [Zone] {
        if zones.count <= 0 {
            let url = URL(string: "http://192.168.5.106:5000/api/homeautomation/zonescomplete")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            zones = try decoder.decode([Zone].self, from: data)
        }
        return zones
    }
    
    func getRemotes() async throws -> [Remote] {
        if remotes.count <= 0 {
            let url = URL(string: "http://192.168.5.106:5000/api/homeautomation/remotes")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            remotes = try decoder.decode([Remote].self, from: data)
        }
        return remotes
    }
}

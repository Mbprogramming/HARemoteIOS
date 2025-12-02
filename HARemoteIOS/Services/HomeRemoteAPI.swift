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
    private var mainCommands: [RemoteItem] = []
        
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
    
    func getMainCommands() async throws -> [RemoteItem] {
        if mainCommands.count <= 0 {
            let url = URL(string: "http://192.168.5.106:5000/api/homeautomation/maincommands")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            mainCommands = try decoder.decode([RemoteItem].self, from: data)
        }
        return mainCommands
    }
    
    func getRemoteStates(remoteId: String) async throws -> [IState] {
        let url = URL(string: "http://192.168.5.106:5000/api/homeautomation/allremotestates?remoteId=" + remoteId)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode([IState].self, from: data)
    }
    
    func sendCommand(device: String, command: String) -> String {
        let uuid = UUID().uuidString
        let url = URL(string: "http://192.168.5.106:5000/api/HomeAutomation?id=" + uuid + "&device=" + device + "&command=" + command)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let _ = URLSession.shared.dataTask(with: request)
            .resume()
        return uuid
    }
}

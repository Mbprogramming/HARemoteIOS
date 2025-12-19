//
//  HomeRemoteAPI.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI
import Foundation

protocol HomeRemoteAPIProtocol {
    func getZonesComplete() async throws -> [Zone]
    func getRemotes() async throws -> [Remote]
}

final class HomeRemoteAPI: HomeRemoteAPIProtocol {
    @AppStorage("server") var server: String = "http://192.168.5.106:5000"
    @AppStorage("username") var username: String = "mbprogramming@googlemail.com"
    @AppStorage("application") var application: String = "HARemoteIOS"
    
    static let shared = HomeRemoteAPI()
    
    private var zones: [Zone] = []
    private var remotes: [Remote] = []
    private var mainCommands: [RemoteItem] = []
        
    private init() {
    }
    
    func getZonesComplete() async throws -> [Zone] {
        if zones.count <= 0 {
            guard let url = URL(string: "\(server)/api/homeautomation/zonescomplete") else { return [] }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("\(username)", forHTTPHeaderField: "X-User")
            request.setValue("\(application)", forHTTPHeaderField: "X-App")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            zones = try decoder.decode([Zone].self, from: data)
        }
        return zones
    }
    
    func getRemotes() async throws -> [Remote] {
        if remotes.count <= 0 {
            guard let url = URL(string: "\(server)/api/homeautomation/remotes") else { return [] }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("\(username)", forHTTPHeaderField: "X-User")
            request.setValue("\(application)", forHTTPHeaderField: "X-App")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            remotes = try decoder.decode([Remote].self, from: data)
        }
        return remotes
    }
    
    func getMainCommands() async throws -> [RemoteItem] {
        if mainCommands.count <= 0 {
            guard let url = URL(string: "\(server)/api/homeautomation/maincommands") else { return [] }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("\(username)", forHTTPHeaderField: "X-User")
            request.setValue("\(application)", forHTTPHeaderField: "X-App")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            mainCommands = try decoder.decode([RemoteItem].self, from: data)
        }
        return mainCommands
    }
    
    func getAutomaticExecutions() async throws -> [AutomaticExecutionEntry] {
        guard let url = URL(string: "\(server)/api/homeautomation/automaticexecutions") else { return [] }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode([AutomaticExecutionEntry].self, from: data)
    }
    
    func getRemoteStates(remoteId: String) async throws -> [IState] {
        guard let url = URL(string: "\(server)/api/homeautomation/allremotestates?remoteId=" + remoteId) else { return [] }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode([IState].self, from: data)
    }
    
    func sendCommand(device: String, command: String) -> String {
        let uuid = UUID().uuidString
        guard let url = URL(string: "\(server)/api/HomeAutomation?id=" + uuid + "&device=" + device + "&command=" + command) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")

        let _ = URLSession.shared.dataTask(with: request)
            .resume()
        return uuid
    }
    
    func sendCommandDeferred(device: String, command: String, delay: Int, cyclic: Bool = false) -> String {
        let uuid = UUID().uuidString
        let urlString = "\(server)/api/HomeAutomation/CommandDeferred?id=\(uuid)&device=\(device)&command=\(command)&delay=\(delay)&cyclic=\((cyclic ? "true" : "false"))"
        guard let url = URL(string: urlString) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")

        let _ = URLSession.shared.dataTask(with: request)
            .resume()
        return uuid
    }
    
    func sendCommandDeferredParameter(device: String, command: String, parameter: String, delay: Int, cyclic: Bool = false) -> String {
        let uuid = UUID().uuidString
        let myParameter = escapingUrl(url: parameter) ?? ""
        let urlString = "\(server)/api/HomeAutomation/CommandParameterDeferred?id=\(uuid)&device=\(device)&command=\(command)&parameter=\(myParameter)&delay=\(delay)&cyclic=\((cyclic ? "true" : "false"))"
        guard let url = URL(string: urlString) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")

        let _ = URLSession.shared.dataTask(with: request)
            .resume()
        return uuid
    }
    
    func sendCommandAt(device: String, command: String, at: Date, repeatValue: AutomaticExecutionAtCycle) -> String {
        let uuid = UUID().uuidString
        let iso8601 = ISO8601DateFormatter()
        iso8601.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let atStr = iso8601.string(from: at)
        let repeatStr = repeatValue.description
        let urlString = "\(server)/api/HomeAutomation/CommandAt?id=\(uuid)&device=\(device)&command=\(command)&at=\(atStr)&cycle=\(repeatStr)"
        guard let url = URL(string: urlString) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")

        let _ = URLSession.shared.dataTask(with: request)
            .resume()
        return uuid
    }
    
    func sendCommandAtParameter(device: String, command: String, parameter: String, at: Date, repeatValue: AutomaticExecutionAtCycle) -> String {
        let uuid = UUID().uuidString
        let iso8601 = ISO8601DateFormatter()
        iso8601.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let atStr = iso8601.string(from: at)
        let repeatStr = repeatValue.description
        let myParameter = escapingUrl(url: parameter) ?? ""
        let urlString = "\(server)/api/HomeAutomation/CommandParameterAt?id=\(uuid)&device=\(device)&command=\(command)&parameter=\(myParameter)&at=\(atStr)&cycle=\(repeatStr)"
        guard let url = URL(string: urlString) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")

        let _ = URLSession.shared.dataTask(with: request)
            .resume()
        return uuid
    }
    
    func escapingUrl(url: String) -> String? {
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: ";/?:@&=+$, ")
        return url.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey)
    }
    
    func sendCommandParameter(device: String, command: String, parameter: String) -> String {
        let uuid = UUID().uuidString
        let myParameter = escapingUrl(url: parameter)
        let urlString = "\(server)/api/HomeAutomation/CommandParameter?id=\(uuid)&device=\(device)&command=\(command)&parameter=\(myParameter ?? "")"
        guard let url = URL(string: urlString) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")
        
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error as? URLError {
                NSLog(error.failingURL?.absoluteString ?? "")
            }
        }
        .resume()
        return uuid
    }
    
    func deleteAutomaticExecution(id: String) {
        guard let url = URL(string: "\(server)/api/HomeAutomation/AutomaticExecutions?id=" + id) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")

        let _ = URLSession.shared.dataTask(with: request)
            .resume()
    }
}

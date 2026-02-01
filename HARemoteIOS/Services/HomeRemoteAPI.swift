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
    @AppStorage("server") var server: String = ""
    @AppStorage("webserver") var webserver: String = ""
    @AppStorage("username") var username: String = ""
    @AppStorage("application") var application: String = "HARemoteIOS"
    
    static let shared = HomeRemoteAPI()
    
    private var zones: [Zone] = []
    private var remotes: [Remote] = []
    private var mainCommands: [RemoteItem] = []
    private var devices: [HABaseDevice] = []
    
    public var icons: [String] = []
    
    private var banner: Dictionary<String, String> = [:]
        
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
    
    func getAll() async throws -> [HABaseDevice] {
        if devices.count <= 0 {
            guard let url = URL(string: "\(server)/api/homeautomation") else { return [] }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("\(username)", forHTTPHeaderField: "X-User")
            request.setValue("\(application)", forHTTPHeaderField: "X-App")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            devices = try decoder.decode([HABaseDevice].self, from: data)
        }
        return devices
    }
    
    func getSpecificState(device: String?, id: String?) async throws -> HAState? {
        guard var components = URLComponents(string: "\(server)/api/homeautomation/specificstate") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "device", value: device ?? ""),
            URLQueryItem(name: "id", value: id ?? "")
        ]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        return try decoder.decode(HAState.self, from: data)
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
    
    func getRemoteStates(remoteId: String) async throws -> [HAState] {
        guard let url = URL(string: "\(server)/api/homeautomation/allremotestates?remoteId=" + remoteId) else { return [] }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode([HAState].self, from: data)
    }
    
    func sendCommand(device: String, command: String) -> String {
        let uuid = UUID().uuidString
        guard let url = URL(string: "\(server)/api/HomeAutomation?id=" + uuid + "&device=" + device + "&command=" + command) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("sendCommand error: \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                NSLog("sendCommand HTTP status \(http.statusCode) for \(request.url?.absoluteString ?? "")")
            }
        }.resume()
        return uuid
    }
    
    public func removeBanner(executionId: String) {
        self.banner.removeValue(forKey: executionId)
    }
    
    public func changeBanner(executionId: String, delay: Int) {
        if let bannerId = banner[executionId] {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [bannerId])
            removeBanner(executionId: executionId)
        }
        if delay > 5 * 60 {
            sendSystemBanner(intervalInSeconds: Double(delay) - (5 * 60), executionId: executionId)
        }
    }
    
    func sendSystemBanner(intervalInSeconds: Double, executionId: String) {
        let content = UNMutableNotificationContent()
        content.title = "5 Minute Warning"
        content.body = "The automatic execution runs in 5 minutes."
        content.sound = .default
        content.userInfo = ["executionId": executionId]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalInSeconds, repeats: false)
        let id = UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        self.banner[executionId] = id
    }
    
    func sendCommandDeferred(device: String, command: String, delay: Int, cyclic: Bool = false) -> String {
        let uuid = UUID().uuidString
        let urlString = "\(server)/api/HomeAutomation/CommandDeferred?id=\(uuid)&device=\(device)&command=\(command)&delay=\(delay)&cyclic=\((cyclic ? "true" : "false"))"
        guard let url = URL(string: urlString) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("sendCommandDeferred error: \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                NSLog("sendCommandDeferred HTTP status \(http.statusCode) for \(request.url?.absoluteString ?? "")")
            }
        }.resume()
        if delay > 5 * 60 {
            sendSystemBanner(intervalInSeconds: Double(delay) - (5 * 60), executionId: uuid)
        }
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

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("sendCommandDeferredParameter error: \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                NSLog("sendCommandDeferredParameter HTTP status \(http.statusCode) for \(request.url?.absoluteString ?? "")")
            }
        }.resume()
        if delay > 5 * 60 {
            sendSystemBanner(intervalInSeconds: Double(delay) - (5 * 60), executionId: uuid)
        }
        return uuid
    }
    
    func sendCommandAt(device: String, command: String, at: Date, repeatValue: AutomaticExecutionAtCycle) -> String {
        let uuid = UUID().uuidString
        let iso8601 = ISO8601DateFormatter()
        iso8601.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let atStr = iso8601.string(from: at)
        let repeatStr = repeatValue.description
        let encodedAt = atStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(server)/api/HomeAutomation/CommandAt?id=\(uuid)&device=\(device)&command=\(command)&at=\(encodedAt)&cycle=\(repeatStr)"
        guard let url = URL(string: urlString) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("sendCommandAt error: \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                NSLog("sendCommandAt HTTP status \(http.statusCode) for \(request.url?.absoluteString ?? "")")
            }
        }.resume()
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

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("sendCommandAtParameter error: \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                NSLog("sendCommandAtParameter HTTP status \(http.statusCode) for \(request.url?.absoluteString ?? "")")
            }
        }.resume()
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

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("deleteAutomaticExecution error: \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                NSLog("deleteAutomaticExecution HTTP status \(http.statusCode) for \(request.url?.absoluteString ?? "")")
            }
        }.resume()
        
        if let bannerId = banner[id] {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [bannerId])
            removeBanner(executionId: id)
        }
    }
    
    func automaticExecutionImmediatly(id: String) {
        let urlString = "\(server)/api/HomeAutomation/AutomaticExecutionsImmediatly?id=\(id)"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")
        
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error as? URLError {
                NSLog(error.failingURL?.absoluteString ?? "")
            }
        }
        .resume()
    }
    
    func automaticExecutionAddMinutes(id: String, minutes: Int) {
        let urlString = "\(server)/api/HomeAutomation/AutomaticExecutionsAddMinutes?id=\(id)&minutes=\(minutes)"
        guard let url = URL(string: urlString) else { return  }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")
        
        let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if data != nil {
                if let str = String(data: data!, encoding: .utf8) {
                    let delay = Int(str) ?? 0
                    self.changeBanner(executionId: id, delay: delay * 60)
                }
            }
            if let error = error as? URLError {
                NSLog(error.failingURL?.absoluteString ?? "")
            }
        }
        .resume()
    }
    
    func addStateChangeAutomaticExecution(stateDevice: String, state: String, commandDevice: String, command: String, operation: String, limit: String, parameter: String?) {
        let urlString = "\(server)/api/HomeAutomation/AddStateChangeAutomaticExecution?commandDevice=\(commandDevice)&command=\(command)&stateDevice=\(stateDevice)&state=\(state)&operation=\(operation)&limit=\(limit)"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(username)", forHTTPHeaderField: "X-User")
        request.setValue("\(application)", forHTTPHeaderField: "X-App")

        let _ = URLSession.shared.dataTask(with: request){ (data, response, error) in
            if let error = error as? URLError {
                NSLog(error.failingURL?.absoluteString ?? "")
            }
        }
        .resume()
    }
    
    func getWebStateGroups() async throws -> [String] {
        let urlString = "\(webserver)/stategroup"
        guard let url = URL(string: urlString) else { return [] }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(username)", forHTTPHeaderField: "user")

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode([String].self, from: data)
    }
    
    func getIconsWithoutCharts() async throws -> [String] {
        if icons.count <= 0 {
            guard let url = URL(string: "\(server)/api/homeautomation/AllBitmapsWithoutCharts") else { return [] }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("\(username)", forHTTPHeaderField: "X-User")
            request.setValue("\(application)", forHTTPHeaderField: "X-App")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            icons = try decoder.decode([String].self, from: data)
        }
        return icons
    }
    
    func shouldIconCached(id: String) -> Bool {
        let index = icons.firstIndex(where: { $0.caseInsensitiveCompare(id) == .orderedSame })
        if (index ?? -1) >= 0 {
            return true
        }
        return false
    }
}


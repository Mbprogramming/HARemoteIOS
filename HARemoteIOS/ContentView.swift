//
//  ContentView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 21.11.25.
//

import SwiftUI
import SwiftData
import SignalRClient


private struct MainWindowSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

private struct ZonesCollection: EnvironmentKey {
    static let defaultValue: [Zone] = []
}

private struct RemotesCollection: EnvironmentKey {
    static let defaultValue: [Remote] = []
}

private struct CommandIdCollection: EnvironmentKey {
    static let defaultValue: [String] = []
}

extension EnvironmentValues {
    var mainWindowSize: CGSize {
        get { self[MainWindowSizeKey.self] }
        set { self[MainWindowSizeKey.self] = newValue }
    }
    var zones: [Zone] {
        get { self[ZonesCollection.self] }
        set { self[ZonesCollection.self] = newValue }
    }
    var remotes: [Remote] {
        get { self[RemotesCollection.self] }
        set { self[RemotesCollection.self] = newValue }
    }
    var commandIds: [String] {
        get { self[CommandIdCollection.self] }
        set { self[CommandIdCollection.self] = newValue }
    }
}

struct ContentView: View {
    @State private var navigateToSettings: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showSmallPopup: Bool = false
    @State private var showSmallPopup2: Bool = false
    @State private var showSidePane: Bool = false
    @State private var isLoading: Bool = false

    @State private var zones: [Zone] = []
    @State private var remotes : [Remote] = []
    @State private var mainCommands: [RemoteItem] = []
    @State private var commandIds: [String] = []
    @State private var remoteStates: [IState] = []

    @State private var currentRemote: Remote? = nil
    @State private var currentRemoteItem: RemoteItem? = nil
    @State private var remoteItemStack: [RemoteItem] = []
    
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \RemoteHistoryEntry.lastUsed, order: .reverse) var remoteHistory: [RemoteHistoryEntry]

    @State private var connection: HubConnection?
    
    @State private var macroQuestionId: String = ""
    @State private var macroQuestion: String = ""
    @State private var macroYesOption: String = ""
    @State private var macroNoOption: String = ""
    @State private var macroOptions: [String] = []
    @State private var macroDefaultOption: Int = 0
    @State private var showMacroSelectionList: Bool = false
    @State private var showMacroQuestion: Bool = false
    
    private func deleteHistory(indexSet: IndexSet) {
        for i in indexSet {
            let remoteHistoryItem = remoteHistory[i]
            modelContext.delete(remoteHistoryItem)
        }
    }
    
    private func openUrl(id: String?, device: String?, command: String?, url: String?) async {
        NSLog("openUrl(\(id), \(device), \(command), \(url))")
        return
    }
    
    private func openWebsite(id: String, device: String, command: String, url: String) async {
        NSLog("openWebsite(\(id), \(device), \(command), \(url))")
        return
    }
    
    private func commandReceived(id: String, device: String, command: String, message: String) async {
        NSLog("commandReceived(\(id), \(device), \(command), \(message))")
        return
    }

    private func commandExecuted(id: String, device: String, command: String, message: String) async {
        NSLog("commandExecuted(\(id), \(device), \(command), \(message))")
        return
    }

    private func openRemote(id: String, zone: String?, remote: String, page: String) async {
        DispatchQueue.main.async {
            if let newRemote = remotes.first(where: {$0.id == remote}) {
                remoteStates = []
                currentRemote = newRemote
                currentRemoteItem = newRemote.remote
                
                let itemToUpdate = remoteHistory.first(where: { $0.remoteId == currentRemote?.id ?? "" })
                if itemToUpdate != nil {
                    itemToUpdate?.lastUsed = Date()
                } else {
                    modelContext.insert(RemoteHistoryEntry(remoteId: currentRemote?.id ?? ""))
                }
                if remoteHistory.count > 6 {
                    let indexSet = IndexSet(remoteHistory.indices.prefix(remoteHistory.count - 6))
                    deleteHistory(indexSet: indexSet)
                }
                remoteItemStack.removeAll()
                Task {
                    remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
                }
            }
        }
        return
    }
    
    private func macroSelectionTimeout(id: String) async {
        DispatchQueue.main.async {
            closeMacroSheets()
        }
    }
    
    private func macroQuestion(id: String?, question: String?, yesOption: String?, noOption: String?, defaultOption: Int, timeout: Int) async {
        macroQuestionId = id ?? ""
        macroQuestion = question ?? ""
        macroYesOption = yesOption ?? ""
        macroNoOption = noOption ?? ""
        macroDefaultOption = defaultOption
        DispatchQueue.main.async {
            showMacroQuestion = true
        }
    }
    
    private func macroSelectionList(id: String?, question: String, options: [String]?, defaultOption: Int, timeout: Int) async {
        macroQuestionId = id ?? ""
        macroQuestion = question
        macroOptions = options ?? []
        macroDefaultOption = defaultOption
        DispatchQueue.main.async {
            showMacroSelectionList  = true
        }
    }
    
    private func closeMacroSheets() {
        macroQuestionId = ""
        macroQuestion = ""
        macroYesOption = ""
        macroNoOption = ""
        macroOptions = []
        macroDefaultOption = 0
        showMacroSelectionList = false
        showMacroQuestion = false
    }
    
    private func continueMacro(index: Int) {
        let param = ContinueMacroParameter(currentTaskId: macroQuestionId, currentAnswer: index)
        let parameter = try? JSONEncoder().encode(param)
        let jsonString = String(data: parameter!, encoding: .utf8)
        let id = HomeRemoteAPI.shared.sendCommandParameter(device: "macro", command: "ContinueMacro", parameter: jsonString!)
        DispatchQueue.main.async {
            closeMacroSheets()
        }
    }

    private func stateChanged(device: String, state: String, value: String, convertedValue: String, icon: String?, color: String?, lastChange: String) async {
        // If no matching state exists, nothing to do quickly
        guard remoteStates.contains(where: { $0.device == device && $0.id == state }) else { return }
        
        DispatchQueue.main.async {
            // Rebuild the array by replacing only the matching item with a new IState instance
            let updated: [IState] = remoteStates.map { s in
                if s.device == device && s.id == state {
                    var colorIn: Int64? = nil
                    if color != nil {
                        colorIn = Int64(color!)
                    }
                    return IState(
                        id: s.id,
                        device: s.device,
                        value: value,
                        convertedValue: convertedValue,
                        color: colorIn,
                        icon: icon,
                        convertDescription: s.convertDescription,
                        nativeType: s.nativeType,
                        showValueAndIcon: s.showValueAndIcon,
                        stateToIcon: s.stateToIcon,
                        stateToColor: s.stateToColor,
                        isCombined: s.isCombined,
                        additionalText: s.additionalText
                    )
                } else {
                    return s
                }
            }
            remoteStates = updated
        }
    }

    private func setupConnection() async throws {
        guard connection == nil else {
            return
        }
        
        connection = HubConnectionBuilder()
            .withUrl(url: "http://192.168.5.106:5000/homeautomation")
            .withAutomaticReconnect()
            .withLogLevel(logLevel: LogLevel.warning)
            .build()

        await connection!.on("StateChanged", handler: stateChanged)
        await connection!.on("CommandReceived", handler: commandReceived)
        await connection!.on("CommandExecuted", handler: commandExecuted)
        await connection!.on("OpenWebsite", handler: openWebsite)
        await connection!.on("OpenRemote", handler: openRemote)
        await connection!.on("OpenUrl", handler: openUrl)
        await connection!.on("MacroSelectionTimeout", handler: macroSelectionTimeout)
        await connection!.on("MacroQuestion", handler: macroQuestion)
        await connection!.on("MacroSelectionList", handler: macroSelectionList)

        try await connection!.start()
    }
    
    var body: some View {
        GeometryReader { geo in
            if isLoading {
                ProgressView()
            }
            NavigationStack {
                TabView {
                    NavigationView {
                        if currentRemoteItem?.template == RemoteTemplate.List ||
                            currentRemoteItem?.template == RemoteTemplate.Wrap {
                            RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                                .ignoresSafeArea()
                        } else {
                            RemoteView(currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
                        }
                    }
                    .tabItem {
                        Label("Remote", systemImage: "av.remote")
                    }
                    
                    NavigationView {
                        StateView(remoteStates: $remoteStates)
                            .ignoresSafeArea()
                    }
                    .tabItem {
                        Label("States", systemImage: "flag")
                    }
                    
                    NavigationView {
                        HistoryView(commandIds: $commandIds)
                            .ignoresSafeArea()
                    }
                    .tabItem {
                        Label("History", systemImage: "checklist")
                    }
                }
                .sheet(isPresented: $showMacroSelectionList) {
                    ScrollView {
                        VStack {
                                Label("Continue Macro", systemImage: "list.triangle")
                                    .font(.title2)
                                Text(macroQuestion)
                                    .font(.title)
                            Divider()
                            ForEach(macroOptions, id: \.self) { option in
                                let isDefault = (macroOptions.firstIndex(of: option) == macroDefaultOption)
                                if isDefault {
                                    Button(action: {
                                        continueMacro(index: (macroOptions.firstIndex(of: option) ?? -1))
                                        return
                                    }){
                                        Text(option)
                                            .bold()
                                            .font(.title3)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.glass)
                                    .tint(Color.orange)
                                    .padding()
                                } else {
                                    Button(action: {
                                        continueMacro(index: (macroOptions.firstIndex(of: option) ?? -1))
                                        return
                                    }){
                                        Text(option)
                                            .font(.title3)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.glass)
                                    .padding()
                                }
                            }
                        }
                        .padding()
                    }
                    .presentationDetents([.medium])
                }
                .sheet(isPresented: $showMacroQuestion) {
                    ScrollView {
                        VStack{
                            Label("Continue Macro", systemImage: "questionmark")
                                .font(.title2)
                            Text(macroQuestion)
                                .font(.title)
                    Divider()
                    HStack {
                        if macroYesOption.isEmpty == false {
                            if macroDefaultOption == 0 {
                                Button(action: {
                                    continueMacro(index: 0)
                                    return
                                }){
                                    Text(macroYesOption)
                                        .font(.title3)
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.glass)
                                .tint(Color.orange)
                                .padding()
                            } else {
                                Button(action: {
                                    continueMacro(index: 0)
                                    return
                                }){
                                    Text(macroYesOption)
                                        .font(.title3)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.glass)
                                .padding()
                            }
                        }
                        if macroNoOption.isEmpty == false {
                            if macroDefaultOption == 1 {
                                Button(action: {
                                    continueMacro(index: 1)
                                    return
                                }){
                                    Text(macroNoOption)
                                        .bold()
                                        .font(.title3)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.glass)
                                .tint(Color.orange)
                                .padding()
                            } else {
                                Button(action: {
                                    continueMacro(index: 1)
                                    return
                                }){
                                    Text(macroNoOption)
                                        .font(.title3)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.glass)
                                .padding()
                            }
                        }
                    }
                }
                .padding()
            }
            .presentationDetents([.medium])
        }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button("Remote History", systemImage: "list.bullet.badge.ellipsis"){
                            showSmallPopup2 = true
                        }
                        .popover(isPresented: $showSmallPopup2) {
                            RemoteHistoryView(currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteStates: $remoteStates, remoteItemStack: $remoteItemStack, isVisible: $showSmallPopup2, remotes: remotes)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Main Commands", systemImage: "square.grid.3x3.square.badge.ellipsis") {
                            showSmallPopup = true
                        }
                        .popover(isPresented: $showSmallPopup) {
                            MainCommandsView(mainCommands: $mainCommands,
                                             currentRemoteItem: $currentRemoteItem,
                                             remoteItemStack: $remoteItemStack,
                                             commandIds: $commandIds,
                                             isVisible: $showSmallPopup)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Home", systemImage: "house") {
                            showSidePane = true
                        }
                        .fullScreenCover(isPresented: $showSidePane) {
                            SidePaneView(currentRemote: $currentRemote, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, remoteStates: $remoteStates, isVisible: $showSidePane)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back", systemImage: "arrow.left") {
                            if remoteItemStack.count > 0 {
                                currentRemoteItem = remoteItemStack.popLast()
                            }
                        }
                        .disabled(remoteItemStack.count <= 0)
                    }
                    ToolbarItem(placement: .principal) {
                        Text(currentRemote?.description ?? "Remote")
                            .font(.headline)
                    }
                }.ignoresSafeArea()
            }
            .task {
                isLoading = true
                do {
                    zones = try await HomeRemoteAPI.shared.getZonesComplete()
                    remotes = try await HomeRemoteAPI.shared.getRemotes()
                    mainCommands = try await HomeRemoteAPI.shared.getMainCommands()
                    if let lastRemote = remoteHistory.first {
                        if let lastRemoteItem = remotes.first(where: {$0.id == lastRemote.remoteId}){
                            remoteStates = []
                            currentRemote = lastRemoteItem
                            currentRemoteItem = lastRemoteItem.remote
                            
                            let itemToUpdate = remoteHistory.first(where: { $0.remoteId == currentRemote?.id ?? "" })
                            if itemToUpdate != nil {
                                itemToUpdate?.lastUsed = Date()
                            }
                            remoteItemStack.removeAll()
                            Task {
                                remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: currentRemote?.id ?? "")
                            }                            
                        }
                    }
                    try await setupConnection()
                } catch {
                    
                }
                isLoading = false;
            }
            // Provide window size via environment
            .environment(\.mainWindowSize, geo.size)
            .environment(\.zones, zones)
            .environment(\.remotes, remotes)
            .environment(\.commandIds, commandIds)
        }
    }
}

#Preview {
    ContentView()
}

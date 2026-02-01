//
//  ContentView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 21.11.25.
//

import SwiftUI
import SwiftData
import SignalRClient
import WebKit
import NaturalLanguage
import Fuse

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
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

enum SearchCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case remote = "Remotes"
    case command = "Commands"
    
    var id: String{ self.rawValue }
}

struct ContentView: View {
    @State private var navigateToSettings: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showSmallPopup: Bool = false
    @State private var showSmallPopup2: Bool = false
    @State private var showSidePane: Bool = false
    @State private var isLoading: Bool = false
    @State private var showSidePaneDummy: Bool = true
    
    @State private var mainModel: RemoteMainModel = RemoteMainModel()
    
    @State private var showDebug: Bool = false
    
    @State private var searchText: String = ""
    @State private var selectedScope: SearchCategory = .all
    
    @Environment(\.mainWindowSize) var mainWindowSize
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    @Query var remoteHistory: [RemoteHistoryEntry]

    @State private var connection: HubConnection?
    
    @State private var macroQuestionId: String = ""
    @State private var macroQuestion: String = ""
    @State private var macroYesOption: String = ""
    @State private var macroNoOption: String = ""
    @State private var macroOptions: [String] = []
    @State private var macroDefaultOption: Int = 0
    @State private var showMacroSelectionList: Bool = false
    @State private var showMacroQuestion: Bool = false
    @State private var showWebView: Bool = false
    @State private var url: URL? = URL(string: "https://www.createwithswift.com")
    @State private var disableScroll: Bool = false
    
    @State private var currentTab: Int = 0
    
    @State private var orientation = UIDeviceOrientation.unknown
    
    @State private var searchResults: [SearchResult] = []
    
    @AppStorage("server") var server: String = "http://192.168.5.106:5000"
    @AppStorage("username") var username: String = "mbprogramming@googlemail.com"
    @AppStorage("application") var application: String = "HARemoteIOS"
    
    private func deleteHistory(indexSet: IndexSet) {
        let tempHistory = remoteHistory.sorted { $0.lastUsed > $1.lastUsed }
        for i in indexSet {
            if i >= 0 && i < tempHistory.count {
                let remoteHistoryItem = tempHistory[i]
                modelContext.delete(remoteHistoryItem)
            }
        }
    }
    
    private func openUrl(id: String?, device: String?, command: String?, url: String?) async {
        return
    }
    
    private func showChart(id: String?, device: String?, command: String?, url: String?) async {
        guard let id = id, mainModel.existId(id: id), let url = url else { return }
        var newUrl = url.removingPercentEncoding ?? ""
        if colorScheme == .dark {
            newUrl = newUrl + "?forceDark=true"
        } else {
            newUrl = newUrl + "?forceDark=false"
        }
        self.url = URL(string: newUrl)
        DispatchQueue.main.async {
            showWebView = true
        }
    }
    
    private func commandReceived(id: String, device: String, command: String, message: String) async {
        DispatchQueue.main.async {
            mainModel.receiveExecution(id: id)
        }
    }

    private func commandExecuted(id: String, device: String, command: String, message: String) async {
        DispatchQueue.main.async {
            mainModel.finishExecution(id: id)
        }
    }

    private func openRemote(id: String, zone: String?, remote: String, page: String) async {
        if mainModel.existId(id: id) {
            DispatchQueue.main.async {
                if let newRemote = mainModel.remotes.first(where: {$0.id == remote}) {
                    mainModel.remoteStates = []
                    mainModel.currentRemote = newRemote
                    mainModel.currentRemoteItem = newRemote.remote
                    mainModel.remoteItemStack.removeAll()
                    Task {
                        mainModel.remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: mainModel.currentRemote?.id ?? "")
                    }
                }
            }
        }
    }
    
    private func macroSelectionTimeout(id: String) async {
        if mainModel.existId(id: id) {
            DispatchQueue.main.async {
                closeMacroSheets()
            }
        }
    }
    
    private func macroQuestion(id: String?, question: String?, yesOption: String?, noOption: String?, defaultOption: Int, timeout: Int) async {
        guard let id = id, mainModel.existId(id: id) else { return }
        macroQuestionId = id
        macroQuestion = question ?? ""
        macroYesOption = yesOption ?? ""
        macroNoOption = noOption ?? ""
        macroDefaultOption = defaultOption
        DispatchQueue.main.async {
            showMacroQuestion = true
        }
    }    
    private func macroSelectionList(id: String?, question: String, options: [String]?, defaultOption: Int, timeout: Int) async {
        guard let id = id, mainModel.existId(id: id) else { return }
        macroQuestionId = id
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
        guard let parameter = try? JSONEncoder().encode(param),
              let jsonString = String(data: parameter, encoding: .utf8) else {
            return
        }
        let id = HomeRemoteAPI.shared.sendCommandParameter(device: "macro", command: "ContinueMacro", parameter: jsonString)
        DispatchQueue.main.async {
            closeMacroSheets()
        }
    }    
    // FIX: make this synchronous and spawn an async Task
    private func automaticExecutionChanged() {
        Task {
            do {
                let entries = try await HomeRemoteAPI.shared.getAutomaticExecutions()
                await MainActor.run {
                    mainModel.automaticExecutions = entries
                }
            } catch {
                // Optionally log or handle the error
                // NSLog("Failed to refresh automatic executions: \(error)")
            }
        }
    }
    
    private func openAutomaticExecution(id: String?) {
        
    }

    private func stateChanged(device: String, state: String, value: String, convertedValue: String, icon: String?, color: String?, lastChange: String) async {
        // If no matching state exists, nothing to do quickly
        guard mainModel.remoteStates.contains(where: { $0.device == device && $0.id == state }) else { return }
        
        DispatchQueue.main.async {
            // Rebuild the array by replacing only the matching item with a new IState instance
            let updated: [HAState] = mainModel.remoteStates.map { s in
                if s.device == device && s.id == state {
                    var colorIn: Int64? = nil
                    if color != nil {
                        colorIn = Int64(color!)
                    }
                    return HAState(
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
                        additionalText: s.additionalText,
                        lastChange: s.lastChange
                    )
                } else {
                    return s
                }
            }
            mainModel.remoteStates = updated
        }
    }

    private func setupConnection() async throws {
        guard connection == nil else {
            return
        }
        
        connection = HubConnectionBuilder()
            .withUrl(url: "\(server)/homeautomation")
            .withAutomaticReconnect()
            .withLogLevel(logLevel: LogLevel.warning)
            .build()

        await connection!.on("StateChanged", handler: stateChanged)
        await connection!.on("CommandReceived", handler: commandReceived)
        await connection!.on("CommandExecuted", handler: commandExecuted)
        await connection!.on("ShowChart", handler: showChart)
        await connection!.on("OpenRemote", handler: openRemote)
        await connection!.on("OpenUrl", handler: openUrl)
        await connection!.on("MacroSelectionTimeout", handler: macroSelectionTimeout)
        await connection!.on("MacroQuestion", handler: macroQuestion)
        await connection!.on("MacroSelectionList", handler: macroSelectionList)
        await connection!.on("AutomaticExecutionChanged", handler: automaticExecutionChanged)
        await connection!.on("OpenAutomaticExecution", handler: openAutomaticExecution)

        try await connection!.start()
    }
    
    @ViewBuilder
    private var macroSelectionListSheet: some View {
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

    @ViewBuilder
    private var macroQuestionSheet: some View {
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

    private func doSearch() {
        if searchText.lengthOfBytes(using: .utf8) <= 0 {
            searchResults = []
            return
        }
        
        let fuse = Fuse()
        let pattern = fuse.createPattern(from: searchText)

        var tempSearchResults: [SearchResult] = []
        
        switch selectedScope {
        case .all:
            mainModel.remotes.forEach { remote in
                let result = fuse.search(pattern, in: remote.description)
                let score = result?.score
                let range = result?.ranges
                if result != nil && score != nil && score! < 0.3 {
                    tempSearchResults.append(SearchResult(remote: remote, score: score, range: range))
                }
            }
            mainModel.searchableCommands.forEach{ cmd in
                if cmd.description != nil {
                    let result = fuse.search(pattern, in: cmd.description ?? "")
                    let score = result?.score
                    let range = result?.ranges
                    if result != nil && score != nil && score! < 0.3 {
                        tempSearchResults.append(SearchResult(command: cmd, score: score, range: range))
                    }
                }
            }
            mainModel.mainCommands.forEach{ cmd in
                if cmd.description != nil {
                    let result = fuse.search(pattern, in: cmd.description ?? "")
                    let score = result?.score
                    let range = result?.ranges
                    let sc = SearchableCommand(device: cmd.device, command: cmd.command, commandType: .Push, description: cmd.description)
                    if result != nil && score != nil && score! < 0.3 {
                        tempSearchResults.append(SearchResult(command: sc, score: score, range: range, isMainCommand: true))
                    }
                }
            }
        case .remote:
            mainModel.remotes.forEach { remote in
                let result = fuse.search(pattern, in: remote.description)
                let score = result?.score
                let range = result?.ranges
                if result != nil && score != nil && score! < 0.3 {
                    tempSearchResults.append(SearchResult(remote: remote, score: score, range: range))
                }
            }
        case .command:
            mainModel.searchableCommands.forEach{ cmd in
                if cmd.description != nil {
                    let result = fuse.search(pattern, in: cmd.description ?? "")
                    let score = result?.score
                    let range = result?.ranges
                    if result != nil && score != nil && score! < 0.3 {
                        tempSearchResults.append(SearchResult(command: cmd, score: score, range: range))
                    }
                }
            }
            mainModel.mainCommands.forEach{ cmd in
                if cmd.description != nil {
                    let result = fuse.search(pattern, in: cmd.description ?? "")
                    let score = result?.score
                    let range = result?.ranges
                    let sc = SearchableCommand(device: cmd.device, command: cmd.command, commandType: .Push, description: cmd.description)
                    if result != nil && score != nil && score! < 0.3 {
                        tempSearchResults.append(SearchResult(command: sc, score: score, range: range, isMainCommand: true))
                    }
                }
            }
        }
        searchResults = tempSearchResults.sorted(by: { ($0.score ?? 1) < ($1.score ?? 1)})
    }
    
    @ViewBuilder
    private var Search: some View {
        NavigationStack {
            List {
                if searchResults.count > 0 || !searchText.isEmpty {
                    ForEach(searchResults) { result in
                        if result.remote != nil {
                            VStack (alignment: .leading) {
                                HStack {
                                    Image(systemName: "av.remote")
                                    ItemView(
                                        remote: result.remote!,
                                        currentRemote: $mainModel.currentRemote,
                                        currentRemoteItem: $mainModel.currentRemoteItem,
                                        remoteItemStack: $mainModel.remoteItemStack,
                                        remoteStates: $mainModel.remoteStates,
                                        isVisible: $showSidePaneDummy
                                    )
                                }
                                Text("\(result.score ?? -1)")
                                    .font(.footnote)
                            }
                            .listRowBackground(Color.clear)
                        } else if result.command != nil {
                            VStack (alignment: .leading) {
                                HStack {
                                    Image(systemName: "play.circle")
                                    Text(result.command?.description ?? "")
                                    Spacer()
                                    Image(systemName: "play")
                                        .font(.caption2)
                                        .bold()
                                }
                                Text("\(result.score ?? -1)")
                                    .font(.footnote)
                            }
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                let id = HomeRemoteAPI.shared.sendCommand(device: result.command?.device ?? "", command: result.command?.command ?? "")
                                mainModel.executeCommand(id: id)
                            }
                        } else if result.mainCommand != nil {
                            VStack (alignment: .leading) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text(result.mainCommand?.description ?? "")
                                    Spacer()
                                    Image(systemName: "play")
                                        .font(.caption2)
                                        .bold()
                                }
                                Text("\(result.score ?? -1)")
                                    .font(.footnote)
                            }
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                let id = HomeRemoteAPI.shared.sendCommand(device: result.mainCommand?.device ?? "", command: result.mainCommand?.command ?? "")
                                mainModel.executeCommand(id: id)
                            }
                        }
                    }
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 150)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(mainModel.remotes) {remote in
                        ItemView(
                            remote: remote,
                            currentRemote: $mainModel.currentRemote,
                            currentRemoteItem: $mainModel.currentRemoteItem,
                            remoteItemStack: $mainModel.remoteItemStack,
                            remoteStates: $mainModel.remoteStates,
                            isVisible: $showSidePaneDummy
                        )
                    }
                    if mainModel.remotes.count > 0 {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 150)
                    }
                }
            }
            .onChange(of: searchText) {
                doSearch()
            }
            .onChange(of: selectedScope) {
                doSearch()
            }
            .navigationTitle("Search")
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search...")
        .searchScopes($selectedScope) {
            ForEach(SearchCategory.allCases) { category in
                Text(category.rawValue).tag(category)
            }
        }
    }
    
    @ViewBuilder
    private var webViewSheet: some View {
        if let url = url {
            ZStack (alignment: .bottom){
                WebView(url: url)
                GlassEffectContainer {
                    HStack{
                        ShareLink(item: url)
                            .padding()
                            .glassEffect()
                        Button("Close", systemImage: "chevron.down"){
                            showWebView = false
                        }
                        .padding()
                        .glassEffect()
                    }
                }.padding()
            }
        }
    }
    
    func findSemanticSimilarity(str1: String, str2: String) -> Double {
        // Word Embedding laden (z.B. für Deutsch oder Englisch)
        if let embedding = NLEmbedding.wordEmbedding(for: .german) {
            let distance: NLDistance = embedding.distance(between: str1, and: str2)
            return distance.rounded(toPlaces: 2)
        }
        return 999
    }
    
    private func handleIntent() {
        if IntentHandleService.shared.intentType == "RunCommandIntent" {
            if IntentHandleService.shared.command != nil {
                if mainModel.mainCommands.count <= 0 || mainModel.searchableCommands.count <= 0 {
                    return
                }
                
                let temp = IntentHandleService.shared.command ?? ""

                if temp.isEmpty {
                    return
                }
                
                let fuse = Fuse()
                let pattern = fuse.createPattern(from: temp)

                var tempSearchResults: [SearchResult] = []
                
                mainModel.mainCommands.forEach { cmd in
                guard let description = cmd.description else { return }
                let result = fuse.search(pattern, in: description)
                let score = result?.score
                    let range = result?.ranges
                    if result != nil && score != nil && score! < 0.3 {
                        let sc = SearchableCommand(device: cmd.device, command: cmd.command, commandType: .Push, description: cmd.description)
                        tempSearchResults.append(SearchResult(command: sc, score: score, range: range, isMainCommand: true))
                    }
                }
                mainModel.searchableCommands.forEach { cmd in
                    guard let desc = cmd.description else { return }
                    let result = fuse.search(pattern, in: desc)
                    let score = result?.score
                    let range = result?.ranges
                    if result != nil && score != nil && score! < 0.3 {
                        tempSearchResults.append(SearchResult(command: cmd, score: score, range: range, isMainCommand: false))
                    }
                }
                
                if tempSearchResults.count <= 0 {
                    IntentHandleService.shared.command = nil
                    IntentHandleService.shared.device = nil
                    IntentHandleService.shared.remote = nil
                    IntentHandleService.shared.intentType = nil
                    return
                }
                
                let command = tempSearchResults[0]
                if command.mainCommand != nil {
                    let id = HomeRemoteAPI.shared.sendCommand(device: command.mainCommand?.device ?? "", command: command.mainCommand?.command ?? "")
                    mainModel.executeCommand(id: id)
                } else if command.command != nil {
                    let id = HomeRemoteAPI.shared.sendCommand(device: command.command?.device ?? "", command: command.command?.command ?? "")
                    mainModel.executeCommand(id: id)
                }
            }
            IntentHandleService.shared.command = nil
            IntentHandleService.shared.device = nil
            IntentHandleService.shared.remote = nil
            IntentHandleService.shared.intentType = nil
        }
        if IntentHandleService.shared.intentType == "OpenRemoteIntent" {
            if IntentHandleService.shared.remote != nil {
                if mainModel.remotes.count <= 0 {
                    return
                }
                let temp = IntentHandleService.shared.remote ?? ""

                if temp.isEmpty {
                    return
                }

                let fuse = Fuse()
                let pattern = fuse.createPattern(from: temp)

                var tempSearchResults: [SearchResult] = []
                
                mainModel.remotes.forEach { remote in
                    let result = fuse.search(pattern, in: remote.description)
                    let score = result?.score
                    let range = result?.ranges
                    if result != nil && score != nil && score! < 0.3 {
                        tempSearchResults.append(SearchResult(remote: remote, score: score, range: range))
                    }
                }
                
                if tempSearchResults.count <= 0 {
                    IntentHandleService.shared.command = nil
                    IntentHandleService.shared.device = nil
                    IntentHandleService.shared.remote = nil
                    IntentHandleService.shared.intentType = nil
                    return
                }
                
                let remote = tempSearchResults[0]

                guard let selectedRemote = remote.remote else {
                    // remote missing, clear intent and return
                    IntentHandleService.shared.command = nil
                    IntentHandleService.shared.device = nil
                    IntentHandleService.shared.remote = nil
                    IntentHandleService.shared.intentType = nil
                    return
                }

                DispatchQueue.main.async {
                    mainModel.remoteStates = []
                    mainModel.currentRemote = selectedRemote
                    mainModel.currentRemoteItem = selectedRemote.remote
                    mainModel.remoteItemStack.removeAll()
                    Task {
                        do {
                            mainModel.remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: selectedRemote.id ?? "")
                        } catch {
                            NSLog("Failed to fetch remote states for intent open: \(error)")
                        }
                    }
                }
            }
            IntentHandleService.shared.command = nil
            IntentHandleService.shared.device = nil
            IntentHandleService.shared.remote = nil
            IntentHandleService.shared.intentType = nil
        }
    }

    @ViewBuilder
    private var mainTabs: some View {
        TabView (selection: $currentTab) {
            Tab("Remote", systemImage: "av.remote", value: 0){
                NavigationStack {
                    if mainModel.currentRemoteItem?.template == RemoteTemplate.List ||
                        mainModel.currentRemoteItem?.template == RemoteTemplate.Wrap {
                        RemoteView(currentRemoteItem: $mainModel.currentRemoteItem, remoteItemStack: $mainModel.remoteItemStack, mainModel: $mainModel, remoteStates: $mainModel.remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                            .toolbar { toolbarContent }
                            .navigationBarTitleDisplayMode(.inline)
                            .ignoresSafeArea()
                            .if(mainModel.currentRemote?.defaultState != nil) { remoteView in
                                remoteView.safeAreaInset(edge: .top) {
                                    RemoteStateView(mainModel: $mainModel)
                                        .frame(height: 50)
                                        .background(.ultraThinMaterial)
                                }
                            }
                     } else {
                        RemoteView(currentRemoteItem: $mainModel.currentRemoteItem, remoteItemStack: $mainModel.remoteItemStack, mainModel: $mainModel, remoteStates: $mainModel.remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                             .if(mainModel.currentRemote?.defaultState != nil) { remoteView in
                                 remoteView.safeAreaInset(edge: .top) {
                                     RemoteStateView(mainModel: $mainModel)
                                         .frame(height: 50)
                                         .background(.ultraThinMaterial)
                                 }
                             }
                             .if(!(mainModel.currentRemote?.defaultState != nil)) { remoteView in
                                     remoteView.navigationBarTitleDisplayMode(.inline)
                             }
                             .toolbar { toolbarContent }
                    }
                }                
            }
            
            Tab("States", systemImage: "flag", value: 1){
                NavigationStack {
                    StateView(remoteStates: $mainModel.remoteStates, currentRemote: $mainModel.currentRemote)
                }
            }
            
            Tab("History", systemImage: "checklist", value: 2){
                NavigationStack {
                    HistoryView(mainModel: $mainModel)
                        .ignoresSafeArea()
                }
            }
            
            Tab("Automatic", systemImage: "calendar", value: 3){
                NavigationStack {
                    AutomaticExecutionView(automaticExecutionEntries: $mainModel.automaticExecutions, mainModel: $mainModel)
                }
            }
            .badge(mainModel.automaticExecutionCount)

            Tab("Search", systemImage: "magnifyingglass", value: 4, role: .search) {
                Search
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing){
            Button("Remote History", systemImage: "list.bullet.badge.ellipsis"){
                showSmallPopup2 = true
            }
            .popover(isPresented: $showSmallPopup2) {
                RemoteHistoryView(currentRemote: $mainModel.currentRemote, currentRemoteItem: $mainModel.currentRemoteItem, remoteStates: $mainModel.remoteStates, remoteItemStack: $mainModel.remoteItemStack, isVisible: $showSmallPopup2, orientation: $orientation, remotes: mainModel.remotes)
                    .padding()
                    .presentationCompactAdaptation(.popover)
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Main Commands", systemImage: "square.grid.3x3.square.badge.ellipsis") {
                showSmallPopup = true
            }
            .popover(isPresented: $showSmallPopup) {
                MainCommandsView(mainCommands: $mainModel.mainCommands,
                                 currentRemoteItem: $mainModel.currentRemoteItem,
                                 remoteItemStack: $mainModel.remoteItemStack,
                                 mainModel: $mainModel,
                                 isVisible: $showSmallPopup,
                                 orientation: $orientation)
                .padding()
                .presentationCompactAdaptation(.popover)
            }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Home", systemImage: "house") {
                showSidePane = true
            }
            .fullScreenCover(isPresented: $showSidePane) {
                SidePaneView(currentRemote: $mainModel.currentRemote, currentRemoteItem: $mainModel.currentRemoteItem, remoteItemStack: $mainModel.remoteItemStack, remoteStates: $mainModel.remoteStates, isVisible: $showSidePane)
            }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Back", systemImage: "arrow.left") {
                if mainModel.remoteItemStack.count > 0 {
                    mainModel.currentRemoteItem = mainModel.remoteItemStack.popLast()
                }
            }
            .disabled(mainModel.remoteItemStack.count <= 0)
        }
        ToolbarItem(placement: .principal) {
            Text(mainModel.currentRemote?.description ?? "Remote")
                .font(.headline)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                mainTabs
                    .ignoresSafeArea()
                    .sheet(isPresented: $showMacroSelectionList) { [macroQuestion, macroOptions, macroDefaultOption] in
                        macroSelectionListSheet
                    }
                    .sheet(isPresented: $showMacroQuestion) { [macroQuestion, macroYesOption, macroNoOption, macroDefaultOption] in
                        macroQuestionSheet
                    }
                    .sheet(isPresented: $showWebView) { [url] in
                        webViewSheet
                    }
                    .task {
                        isLoading = true
                        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                        do {
                            mainModel.zones = try await HomeRemoteAPI.shared.getZonesComplete()
                            mainModel.remotes = try await HomeRemoteAPI.shared.getRemotes()
                            mainModel.mainCommands = try await HomeRemoteAPI.shared.getMainCommands()
                            mainModel.automaticExecutions = try await HomeRemoteAPI.shared.getAutomaticExecutions()
                            mainModel.devices = try await HomeRemoteAPI.shared.getAll()
                            mainModel.buildSearchableCommands()
                            _ = try await HomeRemoteAPI.shared.getIconsWithoutCharts()
                            orientation = UIDevice.current.orientation

                            let tempHistory = remoteHistory.sorted { $0.lastUsed > $1.lastUsed }
                            if let lastRemote = tempHistory.first {
                                if let lastRemoteItem = mainModel.remotes.first(where: { $0.id == lastRemote.remoteId }) {
                                    mainModel.remoteStates = []
                                    mainModel.currentRemote = lastRemoteItem

                                    if let itemToUpdate = remoteHistory.first(where: { $0.remoteId == mainModel.currentRemote?.id ?? "" }) {
                                        itemToUpdate.lastUsed = Date()
                                    }
                                    mainModel.remoteItemStack.removeAll()
                                    mainModel.remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: mainModel.currentRemote?.id ?? "")
                                }
                            }

                            try await setupConnection()

                            if let mainCmd = IntentHandleService.shared.mainCommandId {
                                if let cmd = mainModel.mainCommands.first(where: { $0.id == mainCmd }) {
                                    if let device = cmd.device, let command = cmd.command {
                                        let id = HomeRemoteAPI.shared.sendCommand(device: device, command: command)
                                        mainModel.executeCommand(id: id)
                                    } else {
                                        // Missing device/command; clear to avoid retrying
                                        IntentHandleService.shared.mainCommandId = nil
                                    }
                                }
                                IntentHandleService.shared.mainCommandId = nil
                            }

                            handleIntent()
                        } catch {
                            NSLog("Failed to initialize: \(error)")
                        }
                        isLoading = false

                        DispatchQueue.main.async {
                            currentTab = 0
                            switch orientation {
                            case .unknown:
                                mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                            case .portrait:
                                mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                            case .portraitUpsideDown:
                                mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                            case .landscapeLeft:
                                if mainModel.currentRemote?.landscapeRemote != nil {
                                    mainModel.currentRemoteItem = mainModel.currentRemote?.landscapeRemote
                                } else {
                                    mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                                }
                            case .landscapeRight:
                                if mainModel.currentRemote?.landscapeRemote != nil {
                                    mainModel.currentRemoteItem = mainModel.currentRemote?.landscapeRemote
                                } else {
                                    mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                                }
                            case .faceUp:
                                mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                            case .faceDown:
                                mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                            @unknown default:
                                mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                            }
                        }
                    }
                    }
                    .onChange(of: IntentHandleService.shared.mainCommandId) {
                        if let mainCmd = IntentHandleService.shared.mainCommandId {
                            if let cmd = mainModel.mainCommands.first(where: { $0.id == mainCmd }) {
                                guard let device = cmd.device, let command = cmd.command else {
                                    IntentHandleService.shared.mainCommandId = nil
                                    return
                                }
                                let id = HomeRemoteAPI.shared.sendCommand(device: device, command: command)
                                mainModel.executeCommand(id: id)
                            }
                            IntentHandleService.shared.mainCommandId = nil
                        }
                    }
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        if newPhase == .background {
                            var items: [UIApplicationShortcutItem] = []
                            for cmd in mainModel.mainCommands {
                                let icon = UIApplicationShortcutIcon(systemImageName: cmd.clientIcon ?? "bolt.fill")
                                let item = UIApplicationShortcutItem(
                                    type: "seeb.HARemoteIOS.mainCommand",
                                    localizedTitle: cmd.description ?? "Command",
                                    localizedSubtitle: nil,
                                    icon: icon,
                                    userInfo: ["id": (cmd.id ?? "") as NSString]
                                )
                                items.append(item)
                            }
                            UIApplication.shared.shortcutItems = items
                        }
                    }
                    .onChange(of: mainModel.currentRemote) {
                        let itemToUpdate = remoteHistory.first(where: { $0.remoteId == mainModel.currentRemote?.id ?? "" })
                        if itemToUpdate != nil {
                            itemToUpdate?.lastUsed = Date()
                        } else {
                            modelContext.insert(RemoteHistoryEntry(remoteId: mainModel.currentRemote?.id ?? ""))
                        }
                        try? modelContext.save()
                        if remoteHistory.count > 6 {
                            let indexSet = IndexSet(integersIn: 6...remoteHistory.count - 1)
                            deleteHistory(indexSet: indexSet)
                        }
                        try? modelContext.save()
                    }
                    .onChange(of: IntentHandleService.shared.intentType) {
                        handleIntent()
                    }
                    .onRotate { newOrientation in
                        switch newOrientation {
                        case .unknown:
                            print("rotation unknown")
                        case .portrait:
                            if orientation != .portraitUpsideDown && orientation != .portrait {
                                print("set to portrait")
                                mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                                orientation = .portrait
                            }
                        case .portraitUpsideDown:
                            if orientation != .portraitUpsideDown && orientation != .portrait {
                                print("set to portrait")
                                mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                                orientation = .portrait
                            }
                        case .landscapeLeft:
                            if mainModel.currentRemote?.landscapeRemote != nil {
                                if orientation != .landscapeLeft && orientation != .landscapeRight {
                                    print("set to landscape")
                                    mainModel.currentRemoteItem = mainModel.currentRemote?.landscapeRemote
                                    orientation = .landscapeLeft
                                }
                            } else {
                                if orientation != .portraitUpsideDown && orientation != .portrait
                                    && orientation != .landscapeLeft && orientation != .landscapeRight {
                                    print("set to portrait")
                                    mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                                    orientation = .portrait
                                }
                            }
                        case .landscapeRight:
                            if mainModel.currentRemote?.landscapeRemote != nil {
                                if orientation != .landscapeLeft && orientation != .landscapeRight {
                                    print("set to landscape")
                                    mainModel.currentRemoteItem = mainModel.currentRemote?.landscapeRemote
                                    orientation = .landscapeLeft
                                }
                            } else {
                                if orientation != .portraitUpsideDown && orientation != .portrait
                                    && orientation != .landscapeLeft && orientation != .landscapeRight {
                                    print("set to portrait")
                                    mainModel.currentRemoteItem = mainModel.currentRemote?.remote
                                    orientation = .portrait
                                }
                            }
                        case .faceUp:
                            print("rotation faceUp")
                        case .faceDown:
                            print("rotation faceDown")
                        @unknown default:
                            print("rotation unknown default")
                        }
                    }
                // Provide window size via environment
                    .environment(\.mainWindowSize, geo.size)
                    .environment(\.zones, mainModel.zones)
                    .environment(\.remotes, mainModel.remotes)
                if isLoading {
                    VStack {
                        Image("Remote-transparent")
                            .renderingMode(.original)
                            .resizable() // Macht das Bild skalierbar
                            .scaledToFit() // Behält das Seitenverhältnis bei
                            .frame(width: 300, height: 300)
                            .padding()
                        ProgressView()
                    }
                }
            }
        }
    }
}

extension String {
    func levenshteinDistance(to other: String) -> Int {
        let sCount = self.count
        let oCount = other.count
        guard sCount > 0 else { return oCount }
        guard oCount > 0 else { return sCount }
        
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: oCount + 1), count: sCount + 1)
        for i in 0...sCount { matrix[i][0] = i }
        for j in 0...oCount { matrix[0][j] = j }
        
        for (i, char1) in self.enumerated() {
            for (j, char2) in other.enumerated() {
                let cost = char1 == char2 ? 0 : 1
                matrix[i + 1][j + 1] = Swift.min(matrix[i][j + 1] + 1, matrix[i + 1][j] + 1, matrix[i][j] + cost)
            }
        }
        return matrix[sCount][oCount]
    }
}

#Preview {
    ContentView()
}


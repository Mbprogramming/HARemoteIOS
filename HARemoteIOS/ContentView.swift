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

struct ContentView: View {
    @State private var navigateToSettings: Bool = false
    @State private var navigateToHome: Bool = false
    @State private var showSmallPopup: Bool = false
    @State private var showSmallPopup2: Bool = false
    @State private var showSidePane: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var mainModel: RemoteMainModel = RemoteMainModel()
    
    @State private var showDebug: Bool = false
    
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
        if mainModel.existId(id: id!) {
            if let url {
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
        if mainModel.existId(id: id!) {
            macroQuestionId = id ?? ""
            macroQuestion = question ?? ""
            macroYesOption = yesOption ?? ""
            macroNoOption = noOption ?? ""
            macroDefaultOption = defaultOption
            DispatchQueue.main.async {
                showMacroQuestion = true
            }
        }
    }
    
    private func macroSelectionList(id: String?, question: String, options: [String]?, defaultOption: Int, timeout: Int) async {
        if mainModel.existId(id: id!) {
            macroQuestionId = id ?? ""
            macroQuestion = question
            macroOptions = options ?? []
            macroDefaultOption = defaultOption
            DispatchQueue.main.async {
                showMacroSelectionList  = true
            }
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
    
    private func handleIntent() {
        if IntentHandleService.shared.intentType == "RunMainCommandIntent" {
            if IntentHandleService.shared.command != nil {
                if mainModel.mainCommands.count <= 0 {
                    return
                }
                if let mainCmd  = mainModel.mainCommands.first(where: { $0.description?.caseInsensitiveCompare(IntentHandleService.shared.command ?? "") == .orderedSame }) {
                    let id = HomeRemoteAPI.shared.sendCommand(device: mainCmd.device!, command: mainCmd.command!)
                    mainModel.executeCommand(id: id)
                }
            }
        }
        IntentHandleService.shared.command = nil
        IntentHandleService.shared.device = nil
        IntentHandleService.shared.remote = nil
        IntentHandleService.shared.intentType = nil
    }
    
    var body: some View {
        GeometryReader { geo in
            if isLoading {
                ProgressView()
            }
            NavigationStack {
                TabView (selection: $currentTab) {
                    Tab("Remote", systemImage: "av.remote", value: 0){
                        NavigationView {
                            if mainModel.currentRemoteItem?.template == RemoteTemplate.List ||
                                mainModel.currentRemoteItem?.template == RemoteTemplate.Wrap {
                                RemoteView(currentRemoteItem: $mainModel.currentRemoteItem, remoteItemStack: $mainModel.remoteItemStack, mainModel: $mainModel, remoteStates: $mainModel.remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                                        .ignoresSafeArea()
                            } else {
                                RemoteView(currentRemoteItem: $mainModel.currentRemoteItem, remoteItemStack: $mainModel.remoteItemStack, mainModel: $mainModel, remoteStates: $mainModel.remoteStates, orientation: $orientation, disableScroll: $disableScroll)
                            }
                        }
                    }
                    
                    Tab("States", systemImage: "flag", value: 1){
                        NavigationView {
                            StateView(remoteStates: $mainModel.remoteStates, currentRemote: $mainModel.currentRemote)
                        }
                    }

                    Tab("History", systemImage: "checklist", value: 2){
                        NavigationView {
                            HistoryView(mainModel: $mainModel)
                                .ignoresSafeArea()
                        }
                    }
                    
                    Tab("Automatic", systemImage: "calendar", value: 3){
                            NavigationView {
                                AutomaticExecutionView(automaticExecutionEntries: $mainModel.automaticExecutions, mainModel: $mainModel)
                            }
                        }
                    .badge(mainModel.automaticExecutionCount)
                }
                .sheet(isPresented: $showMacroSelectionList) { [macroQuestion, macroOptions, macroDefaultOption] in
                    macroSelectionListSheet
                }
                .sheet(isPresented: $showMacroQuestion) { [macroQuestion, macroYesOption, macroNoOption, macroDefaultOption] in
                    macroQuestionSheet
                }
                .sheet(isPresented: $showWebView) { [url] in
                    webViewSheet
                }
                .toolbar {
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
                }.ignoresSafeArea()
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
                    _ = try await HomeRemoteAPI.shared.getIconsWithoutCharts()
                    orientation = UIDevice.current.orientation
                    let tempHistory = remoteHistory.sorted { $0.lastUsed > $1.lastUsed }
                    if let lastRemote = tempHistory.first {
                        if let lastRemoteItem = mainModel.remotes.first(where: {$0.id == lastRemote.remoteId}){
                            mainModel.remoteStates = []
                            mainModel.currentRemote = lastRemoteItem
                            
                            let itemToUpdate = remoteHistory.first(where: { $0.remoteId == mainModel.currentRemote?.id ?? "" })
                            if itemToUpdate != nil {
                                itemToUpdate?.lastUsed = Date()
                            }
                            mainModel.remoteItemStack.removeAll()
                            Task {
                                mainModel.remoteStates = try await HomeRemoteAPI.shared.getRemoteStates(remoteId: mainModel.currentRemote?.id ?? "")
                            }
                        }
                    }
                    try await setupConnection()
                    if let mainCmd = IntentHandleService.shared.mainCommandId {
                        if let cmd = mainModel.mainCommands.first(where: { $0.id == mainCmd }) {
                            let id = HomeRemoteAPI.shared.sendCommand(device: cmd.device!, command: cmd.command!)
                            mainModel.executeCommand(id: id)
                        }
                        IntentHandleService.shared.mainCommandId = nil
                    }
                    handleIntent()
                } catch {
                    
                }
                isLoading = false;
            }
            .onChange(of: mainModel.currentRemote) {
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
            .onChange(of: IntentHandleService.shared.mainCommandId) {
                if let mainCmd = IntentHandleService.shared.mainCommandId {
                    if let cmd = mainModel.mainCommands.first(where: { $0.id == mainCmd }) {
                        let id = HomeRemoteAPI.shared.sendCommand(device: cmd.device!, command: cmd.command!)
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
        }
    }
}

#Preview {
    ContentView()
}


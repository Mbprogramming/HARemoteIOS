//
//  AutomaticExecutionView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 17.12.25.
//

import SwiftUI

struct AutomaticExecutionEntryView : View {
    @Binding var automaticExecutionEntry: AutomaticExecutionEntry
    
    var body: some View {
        VStack {
            HStack {
                switch automaticExecutionEntry.automaticExecutionType {
                case .deferred:
                    Image(systemName: "clock")
                    Text("Deferred")
                        .font(.headline)
                        .padding()
                    Spacer()
                case .executeAt:
                    Image(systemName: "calendar")
                    Text("At")
                        .font(.headline)
                        .padding()
                    Spacer()
                case .stateChange:
                    Image(systemName: "flag")
                    Text("State Change")
                        .font(.headline)
                        .padding()
                    Spacer()
                case .unknown( _):
                    Image(systemName: "questionmark")
                    Text("Unknown")
                        .font(.headline)
                        .padding()
                    Spacer()
                case .none:
                    Image(systemName: "questionmark")
                    Text("Unknown")
                        .font(.headline)
                        .padding()
                    Spacer()
                }
                switch automaticExecutionEntry.automaticExecutionAtCycle {
                case .none:
                    EmptyView()
                case .daily:
                    Image(systemName: "1.calendar")
                case .weekly:
                    Image(systemName: "7.calendar")
                case .monthly:
                    Image(systemName: "31.calendar")
                case .unknown(_):
                    EmptyView()
                case .some(.none):
                    EmptyView()
                }
                if let cyclic = automaticExecutionEntry.cyclic, cyclic {
                    Image(systemName: "repeat")
                }
            }
            HStack {
                Text(automaticExecutionEntry.commandDescription ?? "Unknown")
                Spacer()
            }
            if let hp = automaticExecutionEntry.hasParameter, hp {
                HStack {
                    if let pm = automaticExecutionEntry.decodedParameter {
                        Text(pm)
                            .font(.caption)
                    } else {
                        if let p = automaticExecutionEntry.parameter {
                            Text(p)
                                .font(.caption)
                        }
                    }
                    Spacer()
                }
            }
            switch automaticExecutionEntry.automaticExecutionType {
            case .deferred:
                if let ne = automaticExecutionEntry.nextExecutionString {
                    HStack {
                        Text(ne)
                            .bold()
                        Spacer()
                    }
                }
            case .executeAt:
                if let ne = automaticExecutionEntry.nextExecutionString {
                    HStack {
                        Text(ne)
                            .bold()
                        Spacer()
                    }
                }
            case .stateChange:
                HStack {
                    Text(automaticExecutionEntry.compareDescription)
                        .bold()
                    Spacer()
                }
            case .unknown( _):
                Spacer()
            case .none:
                Spacer()
            }
        }
    }
}

struct AutomaticExecutionView: View {
    @Binding var automaticExecutionEntries: [AutomaticExecutionEntry]
    @Binding var mainModel: RemoteMainModel
    
    @State private var currentFilter: Int = 0
    @State private var automaticCount: Int = 2
    @State private var stateChangeCount: Int = 0
    
    @State private var addVisible: Bool = false
    @State private var deferredDate: Date = Date()
    @State private var deferredAddId: String = ""
    @State private var addStateVisible: Bool = false
    @State private var selectedStateDevice: String? = nil
    @State private var selectedState: String? = nil
    @State private var selectedCommandDevice: String? = nil
    @State private var selectedCommandGroup: String? = nil
    @State private var selectedCommand: String? = nil
    @State private var selectedOperationNum: OperationNum? = nil
    @State private var selectedOperationString: OperationString? = nil
    @State private var selectedOperationBool: OperationBool? = nil
    @State private var limit: String = ""
    @State private var limitBool: String? = nil
    @FocusState private var isFocused: Bool

    @State private var currentWizardStep: Int = 0
    
    @State private var currentStateValue: HAState? = nil
    
    private var devicesForState: [HABaseDevice] {
        return mainModel.devicesWithStates
    }
    
    private var states: [HAState] {
        return mainModel.deviceStates(device: selectedStateDevice)
    }
    
    private var devicesForCommands: [HABaseDevice] {
        return mainModel.devicesWithCommands
    }
    
    private var commandGroups: [String] {
        return mainModel.deviceCommandGroups(device: selectedCommandDevice)
    }
    
    private var commands: [HACommand] {
        return mainModel.deviceCommands(device: selectedCommandDevice, group: selectedCommandGroup)
    }
    
    private var currentSelectedState: HAState? {
        if let device = mainModel.devices.first(where: { $0.id == selectedStateDevice }) {
            if let state = device.states?.first(where: { $0.id == selectedState }) {
                return state
            }
        }
        return nil
    }
    
    private var currentSelectedCommand: HACommand? {
        if let device = mainModel.devices.first(where: { $0.id == selectedCommandDevice }) {
            if let command = device.commands?.first(where: { $0.id == selectedCommand }) {
                return command
            }
        }
        return nil
    }

    private var currentSelectedDevice: HABaseDevice? {
        if let device = mainModel.devices.first(where: { $0.id == selectedStateDevice }) {
            return device
        }
        return nil
    }
    
    private var currentOperation: String? {
        if currentSelectedState?.nativeTypeValue != nil {
            switch currentSelectedState!.nativeTypeValue {
            case "String":
                return selectedOperationString?.rawValue
            case "Int32":
                return selectedOperationNum?.rawValue
            case "Double":
                return selectedOperationNum?.rawValue
            case "Bool":
                return selectedOperationBool?.rawValue
            default:
                return nil
            }
        }
        return nil
    }
    
    private var currentLimit: String? {
        if currentSelectedState?.nativeTypeValue != nil {
            switch currentSelectedState!.nativeTypeValue {
            case "String":
                return limit
            case "Int32":
                return limit
            case "Double":
                return limit
            case "Bool":
                return limitBool
            default:
                return nil
            }
        }
        return nil
    }

    private var filter1: [AutomaticExecutionEntry] {
        return automaticExecutionEntries.filter { entry in
            guard let t = entry.automaticExecutionType else { return false }
            return t == .deferred || t == .executeAt
        }
    }

    private var filter2: [AutomaticExecutionEntry] {
        return automaticExecutionEntries.filter { entry in
            guard let t = entry.automaticExecutionType else { return false }
            return t == .stateChange
        }
    }

    private func filterEntries() -> [AutomaticExecutionEntry] {
        switch currentFilter {
        case 0:
            return filter1
        case 1:
            return filter2
        case 2:
            return automaticExecutionEntries
        default:
            return automaticExecutionEntries
        }
    }
    
    @ViewBuilder
    private var pickerContent: some View {
        Text("Not selected").tag(nil as String?)
        ForEach(devicesForState, id: \.id) { (device: HABaseDevice) in
            Text(device.name ?? "")
                .tag(device.id)
        }
    }

    @ViewBuilder
    private var step1: some View {
        Picker("Device for state:", selection: $selectedStateDevice) {
            pickerContent
        }
        .pickerStyle(.menu)
    }
    
    @ViewBuilder
    private var pickerContent2: some View {
        Text("Not selected").tag(nil as String?)
        ForEach(states, id: \.id) { (state: HAState) in
            Text(state.id ?? "")
                .tag(state.id)
        }
    }

    @ViewBuilder
    private var step12: some View {
        Picker("State", selection: $selectedState) {
            pickerContent2
        }
        .pickerStyle(.menu)
    }

    @ViewBuilder
    private var pickerContent3: some View {
        Text("Not selected").tag(nil as String?)
        ForEach(devicesForCommands, id: \.id) { (device: HABaseDevice) in
            Text(device.name ?? "")
                .tag(device.id)
        }
    }

    @ViewBuilder
    private var step3: some View {
        Picker("Device for command", selection: $selectedCommandDevice) {
            pickerContent3
        }
        .pickerStyle(.menu)
    }

    @ViewBuilder
    private var pickerContent4: some View {
        Text("Not selected").tag(nil as String?)
        ForEach(commandGroups, id: \.self) { (group: String) in
            Text(group)
                .tag(group)
        }
    }

    @ViewBuilder
    private var step31: some View {
        Picker("Group for command", selection: $selectedCommandGroup) {
            pickerContent4
        }
        .pickerStyle(.menu)
    }

    @ViewBuilder
    private var pickerContent5: some View {
        Text("Not selected").tag(nil as String?)
        ForEach(commands, id: \.self) { (command: HACommand) in
            Text(command.description ?? "")
                .tag(command.id)
        }
    }

    @ViewBuilder
    private var step32: some View {
        Picker("Command", selection: $selectedCommand) {
            pickerContent5
        }
        .pickerStyle(.menu)
    }

    @ViewBuilder
    private var pickerNum: some View {
        Picker("Operation", selection: $selectedOperationNum) {
            Text("Not selected").tag(nil as OperationNum?)
            ForEach(OperationNum.allCases) { operation in
                Text(operation.showValue)
                    .tag(operation) // Wichtig für die korrekte Zuordnung
            }
        }
        .pickerStyle(.menu)
    }

    @ViewBuilder
    private var pickerString: some View {
        Picker("Operation", selection: $selectedOperationString) {
            Text("Not selected").tag(nil as OperationString?)
            ForEach(OperationString.allCases) { operation in
                Text(operation.showValue)
                    .tag(operation) // Wichtig für die korrekte Zuordnung
            }
        }
        .pickerStyle(.menu)
    }

    @ViewBuilder
    private var pickerBool: some View {
        Picker("Operation", selection: $selectedOperationBool) {
            Text("Not selected").tag(nil as OperationBool?)
            ForEach(OperationBool.allCases) { operation in
                Text(operation.showValue)
                    .tag(operation) // Wichtig für die korrekte Zuordnung
            }
        }
        .pickerStyle(.menu)
    }
    
    @ViewBuilder
    private var step2: some View {
        if currentSelectedState?.nativeTypeValue != nil {
            switch currentSelectedState!.nativeTypeValue {
            case "String":
                pickerString
                TextField("Limit", text: $limit)
                    .focused($isFocused)
                    .keyboardType(.asciiCapable)
                    .textFieldStyle(.roundedBorder) // Fügt Rahmen hinzu
            case "Int32":
                pickerNum
                TextField("Limit", text: $limit)
                    .focused($isFocused)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder) // Fügt Rahmen hinzu
            case "Double":
                pickerNum
                TextField("Limit", text: $limit)
                    .focused($isFocused)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder) // Fügt Rahmen hinzu
            case "Bool":
                pickerBool
                Picker("Select a value", selection: $limitBool) {
                    Text("Not selected").tag(nil as String?)
                    Text("True").tag("true" as String?)
                    Text("False").tag("false" as String?)
                }.pickerStyle(.segmented)
            default:
                Text("Unknown")
            }
        }
    }
    
    @ViewBuilder
    private var step4Operation: some View {
        if currentSelectedState?.nativeTypeValue != nil {
            switch currentSelectedState!.nativeTypeValue {
            case "String":
                Text("\(selectedOperationString?.showValue ?? "") \(limit)")
                    .font(.headline)
            case "Int32":
                Text("\(selectedOperationNum?.showValue ?? "") \(limit)")
                    .font(.headline)
            case "Double":
                Text("\(selectedOperationNum?.showValue ?? "") \(limit)")
                    .font(.headline)
            case "Bool":
                Text("\(selectedOperationBool?.showValue ?? "") \(limitBool ?? "")")
                    .font(.headline)
            default:
                Text("Unknown")
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing){
            Button("Add State Execution", systemImage: "plus"){
                selectedStateDevice = nil
                addStateVisible.toggle()
            }
        }
    }
    
    var body: some View {
        List {
            let entries = filterEntries()
            if entries.count > 0 {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 150)
                    .listRowBackground(Color.clear)
            }
            ForEach(entries) { entry in
                if let sourceIndex = automaticExecutionEntries.firstIndex(where: { $0.id == entry.id }) {
                    let type = automaticExecutionEntries[sourceIndex].automaticExecutionType
                    AutomaticExecutionEntryView(automaticExecutionEntry: $automaticExecutionEntries[sourceIndex])
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash") {
                                if let id = automaticExecutionEntries[sourceIndex].id {
                                    // Run off the main actor if you want to avoid blocking UI
                                    Task {
                                        HomeRemoteAPI.shared.deleteAutomaticExecution(id: id)
                                    }
                                }
                            }
                            .tint(.red)
                        }
                        .if(type == .executeAt) { view in
                            view.swipeActions(edge: .leading) {
                                Button("Run", systemImage: "play") {
                                    if let id = automaticExecutionEntries[sourceIndex].id {
                                        // Run off the main actor if you want to avoid blocking UI
                                        Task {
                                            HomeRemoteAPI.shared.automaticExecutionImmediatly(id: id)
                                        }
                                    }
                                }
                                .tint(.blue)
                            }
                        }
                        .if(type == .deferred) { view in
                            view.swipeActions(edge: .leading) {
                                Button("Run", systemImage: "play") {
                                    if let id = automaticExecutionEntries[sourceIndex].id {
                                        // Run off the main actor if you want to avoid blocking UI
                                        Task {
                                            HomeRemoteAPI.shared.automaticExecutionImmediatly(id: id)
                                        }
                                    }
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .leading) {
                                Button("Add", systemImage: "plus") {
                                    if let id = automaticExecutionEntries[sourceIndex].id {
                                        var components = DateComponents()
                                        components.hour = 0
                                        components.minute = 5
                                        
                                        deferredDate = Calendar.current.date(from: components) ?? .now
                                        deferredAddId = id
                                        addVisible.toggle()
                                    }
                                }
                                .tint(.orange)
                            }
                        }
                } else {
                    // Fallback: render read-only if the item is no longer in the source array
                    AutomaticExecutionEntryView(automaticExecutionEntry: .constant(entry))
                }
            }
            if entries.count > 0 {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 150)
                    .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .ignoresSafeArea()
        .safeAreaInset(edge: .top) {
            Picker("Filter", selection: $currentFilter) {
                Text("Automatic (\(filter1.count))")
                    .tag(0)
                Text("State Change (\(filter2.count))")
                    .tag(1)
                Text("All (\(automaticExecutionEntries.count))")
                    .tag(2)
           }
            .pickerStyle(.segmented)
            .padding()
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $addStateVisible) {
            // Build list of devices that have states
          
            TabView(selection: $currentWizardStep){
                Tab("Step 1", systemImage: "1.circle", value: 0) {
                    VStack {
                        Text("Select device and state")
                            .font(.title)
                            .padding()
                        Form {
                            Section("State"){
                                step1
                                    .padding()
                                step12
                                    .padding()
                            }
                            Section ("Current State Value"){
                                HStack {
                                    Text("\(currentSelectedState?.value ?? "None")")
                                        .font(.caption2)
                                        .padding()
                                    Text("\(currentSelectedState?.convertedValue ?? "None")")
                                        .font(.caption2)
                                        .padding()
                                    Text("(\(currentSelectedState?.nativeTypeValue ?? "None"))")
                                        .font(.caption2)
                                        .padding()
                                }
                                .padding()
                            }.muted()
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                currentWizardStep = 1
                            }) {
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .glassEffect()
                        }
                        .padding()
                    }
                }
                Tab("Step 2", systemImage: "2.circle", value: 1) {
                    VStack {
                        Text("Compare to")
                            .font(.title)
                            .padding()
                        Form {
                            Section("Current State") {
                                HStack {
                                    Text("\(currentSelectedDevice?.name ?? "")-\(currentSelectedState?.id ?? "")")
                                        .font(.headline)
                                        .bold()
                                }
                                HStack {
                                    Text("\(currentSelectedState?.value ?? "None")")
                                        .font(.caption2)
                                        .padding()
                                    Text("\(currentSelectedState?.convertedValue ?? "None")")
                                        .font(.caption2)
                                        .padding()
                                    Text("(\(currentSelectedState?.nativeTypeValue ?? "None"))")
                                        .font(.caption2)
                                        .padding()
                                }
                            }.muted()
                            Section("Operation and Limit") {
                                step2.padding()
                            }
                        }
                        Spacer()
                        HStack {
                            Button(action: {
                                currentWizardStep = 0
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            .padding()
                            .glassEffect()
                            Spacer()
                            Button(action: {
                                currentWizardStep = 2
                            }) {
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .glassEffect()
                        }
                        .padding()
                    }
                }
                Tab("Step 3", systemImage: "3.circle", value: 2) {
                    VStack {
                        Text("Select device and command")
                            .font(.title)
                            .padding()

                        Form {
                            Section("Current state") {
                                HStack {
                                    Text("\(currentSelectedDevice?.name ?? "")-\(currentSelectedState?.id ?? "")")
                                        .font(.headline)
                                        .bold()
                                }
                                HStack {
                                    Text("\(currentSelectedState?.value ?? "None")")
                                        .font(.caption2)
                                        .padding()
                                    Text("\(currentSelectedState?.convertedValue ?? "None")")
                                        .font(.caption2)
                                        .padding()
                                    Text("(\(currentSelectedState?.nativeTypeValue ?? "None"))")
                                        .font(.caption2)
                                        .padding()
                                }
                                .padding()
                            }.muted()
                            Section("Current operation") {
                                step4Operation
                            }.muted()

                            Section("Command") {
                                step3
                                    .padding()
                                step31
                                    .padding()
                                step32
                                    .padding()
                            }
                        }
                        Spacer()
                        HStack {
                            Button(action: {
                                currentWizardStep = 1
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            .padding()
                            .glassEffect()
                            Spacer()
                            Button(action: {
                                currentWizardStep = 3
                            }) {
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .glassEffect()
                        }
                        .padding()
                    }
                }
                Tab("Step 4", systemImage: "4.circle", value: 3) {
                    VStack {
                        Text("Summary")
                            .font(.title)
                            .padding()
                        Form {
                            Section("Current state") {
                                HStack {
                                    Text("\(currentSelectedDevice?.name ?? "")-\(currentSelectedState?.id ?? "")")
                                        .font(.headline)
                                        .bold()
                                }
                                HStack {
                                    Text("\(currentSelectedState?.value ?? "None")")
                                        .font(.caption2)
                                        .padding()
                                    Text("\(currentSelectedState?.convertedValue ?? "None")")
                                        .font(.caption2)
                                        .padding()
                                    Text("(\(currentSelectedState?.nativeTypeValue ?? "None"))")
                                        .font(.caption2)
                                        .padding()
                                }
                                .padding()
                            }.muted()
                            Section("Current operation") {
                                step4Operation
                            }.muted()
                            Section("Current command") {
                                Text("\(currentSelectedCommand?.device ?? "")-\(currentSelectedCommand?.id ?? "")")
                                    .font(.headline)
                                    .bold()
                            }.muted()
                            Section("Create") {
                                HStack {
                                    Button("Cancel") {
                                        addStateVisible.toggle()
                                    }
                                    .buttonStyle(.glass)
                                    Spacer()
                                    Button("Create automatic execution") {
                                        let stateDevice = currentSelectedState?.device ?? ""
                                        let state = currentSelectedState?.id ?? ""
                                        let commandDevice = currentSelectedCommand?.device ?? ""
                                        let command = currentSelectedCommand?.id ?? ""
                                        let operation = currentOperation ?? ""
                                        let limit = currentLimit ?? ""
                                        
                                        try? HomeRemoteAPI.shared.addStateChangeAutomaticExecution(stateDevice: stateDevice, state: state, commandDevice: commandDevice, command: command, operation: operation, limit: limit, parameter: "")
                                        
                                        addStateVisible.toggle()
                                    }
                                    .buttonStyle(.glass)
                                }
                            }
                        }
                        Spacer()
                        HStack {
                            Button(action: {
                                currentWizardStep = 2
                            }) {
                                Image(systemName: "chevron.left")
                            }
                            .padding()
                            .glassEffect()
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .sheet(isPresented: $addVisible) {
            VStack{
                DatePicker(
                    "",
                    selection: $deferredDate,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .padding()
                HStack {
                    Button("Cancel", systemImage: "xmark.circle") {
                        addVisible.toggle()
                    }
                    .padding()
                    Spacer()
                    Button("OK", systemImage: "checkmark.circle") {
                        
                        let hour = Calendar.current.component(.hour, from: deferredDate)
                        let minute = Calendar.current.component(.minute, from: deferredDate)
                        let delay = (hour * 60) + minute
                        
                        addVisible.toggle()
                        
                        Task {
                            HomeRemoteAPI.shared.automaticExecutionAddMinutes(id: deferredAddId, minutes: delay)
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .presentationDetents([.medium])
        }
        .refreshable {
            Task {
                do {
                    let entries = try await HomeRemoteAPI.shared.getAutomaticExecutions()
                    await MainActor.run {
                        automaticExecutionEntries = entries
                    }
                } catch {
                    // handle error if needed
                }
            }
        }
        .toolbar { toolbarContent }
        .onChange(of: selectedState) {
            selectedOperationNum = nil
            selectedOperationBool = nil
            selectedOperationString = nil
            limit = ""
            Task {
                do {
                    if currentSelectedState != nil {
                        currentStateValue = try? await HomeRemoteAPI.shared.getSpecificState(device: currentSelectedState!.device, id: currentSelectedState!.id)
                    }
                } catch {
                    // handle error if needed
                }
            }
        }
        .onChange(of: currentWizardStep) {
            isFocused = false
        }
        .onChange(of: selectedStateDevice) {
            selectedState = nil
        }
        .onChange(of: selectedCommandDevice) {
            selectedCommandGroup = nil
            selectedCommand = nil
        }
        .onChange(of: selectedCommandGroup) {
            selectedCommand = nil
        }
        .onAppear {
            Task {
                do {
                    let entries = try await HomeRemoteAPI.shared.getAutomaticExecutions()
                    await MainActor.run {
                        automaticExecutionEntries = entries
                    }
                } catch {
                    // handle error if needed
                }
            }
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    func muted(_ isMuted: Bool = true) -> some View {
        self
            .opacity(isMuted ? 0.4 : 1.0)
            .saturation(isMuted ? 0.2 : 1.0)
            .allowsHitTesting(!isMuted) // Verhindert Klicks im muted-Zustand
    }
}

#Preview {
    @Previewable @State var automaticExecutionEntries: [AutomaticExecutionEntry] = []
    @Previewable @State var mainModel: RemoteMainModel = RemoteMainModel()
    
    AutomaticExecutionView(automaticExecutionEntries: $automaticExecutionEntries, mainModel: $mainModel)
}


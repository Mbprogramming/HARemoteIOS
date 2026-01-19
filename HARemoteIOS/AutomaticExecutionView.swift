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

    @State private var currentWizardStep: Int = 0
    
    private var devicesForState: [IBaseDevice] {
         return mainModel.devices.filter { device in
            !(device.states?.isEmpty ?? true)
        }
    }
    
    private var states: [IState] {
        return devicesForState.first{ $0.id == selectedStateDevice }?.states ?? []
    }
    
    private func filterEntries() -> [AutomaticExecutionEntry] {
        switch currentFilter {
        case 0:
            return automaticExecutionEntries.filter { entry in
                guard let t = entry.automaticExecutionType else { return false }
                return t == .deferred || t == .executeAt
            }
        case 1:
            return automaticExecutionEntries.filter { entry in
                guard let t = entry.automaticExecutionType else { return false }
                return t == .stateChange
            }
        case 2:
            return automaticExecutionEntries
        default:
            return automaticExecutionEntries
        }
    }
    
    @ViewBuilder
    private var pickerContent: some View {
        Text("Not selected").tag(nil as String?)
        ForEach(devicesForState, id: \.id) { (device: IBaseDevice) in
            Text(device.name ?? "")
                .tag(device.id)
        }
    }

    @ViewBuilder
    private var step1: some View {
        Picker("Select a device for state", selection: $selectedStateDevice) {
            pickerContent
        }
        .pickerStyle(.wheel)
    }
    
    @ViewBuilder
    private var pickerContent2: some View {
        ForEach(states, id: \.id) { (state: IState) in
            Text(state.id ?? "")
                .tag(state.id)
        }
    }

    @ViewBuilder
    private var step12: some View {
        Picker("Select a state", selection: $selectedState) {
            pickerContent2
        }
        .pickerStyle(.wheel)
    }
    
    var body: some View {
        ZStack (alignment: .bottomTrailing) {
            VStack {
                Picker("Filter", selection: $currentFilter) {
                    Text("Automatic ").tag(0)
                    Text("State Change").tag(1)
                    Text("All").tag(2)
                }
                .pickerStyle(.segmented)
                Spacer()
                
                List {
                    let entries = filterEntries()
                    ForEach(entries) { entry in
                        if let sourceIndex = automaticExecutionEntries.firstIndex(where: { $0.id == entry.id }) {
                            let type = automaticExecutionEntries[sourceIndex].automaticExecutionType
                            AutomaticExecutionEntryView(automaticExecutionEntry: $automaticExecutionEntries[sourceIndex])
                            
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
                }
                HStack {
                    Spacer()
                    Button(action: {
                        selectedStateDevice = nil
                        addStateVisible.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                    .padding()
                    .glassEffect()
                }
                .padding()
            }
            .sheet(isPresented: $addStateVisible) {
                // Build list of devices that have states
              
                TabView(selection: $currentWizardStep){
                    Tab("Step 1", systemImage: "1.circle", value: 0) {
                        VStack {
                            Text("Select device and state")
                                .font(.headline)
                                .padding()
                            Spacer()
                            step1
                                .padding()
                            step12
                                .padding()
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
                        Text("Step 2")
                    }
                    Tab("Step 3", systemImage: "3.circle", value: 2) {
                        Text("Step 3")
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

#Preview {
    @Previewable @State var automaticExecutionEntries: [AutomaticExecutionEntry] = []
    @Previewable @State var mainModel: RemoteMainModel = RemoteMainModel()
    
    AutomaticExecutionView(automaticExecutionEntries: $automaticExecutionEntries, mainModel: $mainModel)
}


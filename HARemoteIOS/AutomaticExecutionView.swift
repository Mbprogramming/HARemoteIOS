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
    
    @State private var currentFilter: Int = 0
    @State private var automaticCount: Int = 2
    @State private var stateChangeCount: Int = 0
        
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
    
    var body: some View {
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
                                Button("Delete", systemImage: "trash.circle") {
                                    if let id = automaticExecutionEntries[sourceIndex].id {
                                        // Run off the main actor if you want to avoid blocking UI
                                        Task {
                                            HomeRemoteAPI.shared.deleteAutomaticExecution(id: id)
                                        }
                                    }
                                }
                                .tint(.red)
                            }
                            .if(type == .deferred || type == .executeAt) { view in
                                view.swipeActions(edge: .leading) {
                                    Button("Run", systemImage: "play.circle") {
                                        return
                                    }
                                    .tint(.blue)
                                }
                                .swipeActions(edge: .leading) {
                                    Button("Add", systemImage: "plus.circle") {
                                        return
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
    
    AutomaticExecutionView(automaticExecutionEntries: $automaticExecutionEntries)
}

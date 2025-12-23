//
//  RemoteToggle.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 08.12.25.
//

import SwiftUI

struct RemoteToggle: View {
    private var _compareValues: [StringStringTuple] = []
    private var _remoteItem: RemoteItem?
    
    var remoteItem: RemoteItem? {
        get {
            return _remoteItem
        }
        set {
            _remoteItem = newValue
            if let newValue {
                if newValue.steps != nil && newValue.steps!.count > 0 {
                    _compareValues = newValue.steps!
                }
            }
        }
    }
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var commandIds: [String]
    @Binding var remoteStates: [IState]
    
    @State private var isOn: Bool = false
    @State private var hasInitializedFromState: Bool = false
    
    init(remoteItem: RemoteItem?, currentRemoteItem: Binding<RemoteItem?>, remoteItemStack: Binding<[RemoteItem]>, commandIds: Binding<[String]>, remoteStates: Binding<[IState]>) {
        self._currentRemoteItem = currentRemoteItem
        self._remoteItemStack = remoteItemStack
        self._commandIds = commandIds
        self._remoteStates = remoteStates
        self.remoteItem = remoteItem
    }
    
    // Compute the current IState for this toggle, if available
    private var currentState: IState? {
        guard let item = remoteItem else { return nil }
        return remoteStates.first(where: { $0.device == item.stateDevice && $0.id == item.state })
    }
    
    // Determine the "true" compare value based on steps or default to "True"
    private var trueCompareValue: String {
        if let match = _compareValues.first(where: { ($0.item2 ?? "").lowercased() == "true" }) {
            return match.item1 ?? "True"
        }
        return "True"
    }
    
    // Whether the underlying state is currently "on"
    private var isStateOn: Bool {
        guard let stateValue = currentState?.value else { return false }
        // Accept common true-ish values
        if stateValue == trueCompareValue { return true }
        return false
    }
    
    var body: some View {
        VStack {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .onAppear {
                    isOn = isStateOn
                }
                .onChange(of: isOn) { _, _ in
                    if isOn != isStateOn {
                        let id = HomeRemoteAPI.shared.sendCommand(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "")
                        commandIds.append(id)
                    }
                }
                .onChange(of: remoteStates) {
                    isOn = isStateOn
                }
            
            Text(remoteItem?.description ?? "")
                .truncationMode(.middle)
                .allowsTightening(true)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .font(.title)
        }
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var commandIds: [String] = []
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    RemoteToggle(remoteItem: remoteItem, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, commandIds: $commandIds, remoteStates: $remoteStates)
}

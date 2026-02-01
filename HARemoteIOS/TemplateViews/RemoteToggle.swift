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
    var targetHeight: CGFloat = 220
    
    var remoteItem: RemoteItem? {
        get { _remoteItem }
        set { _remoteItem = newValue }
    }
    
    @Binding var currentRemoteItem: RemoteItem?
    @Binding var remoteItemStack: [RemoteItem]
    @Binding var mainModel: RemoteMainModel
    @Binding var remoteStates: [HAState]
    
    @State private var isOn: Bool = false
    @State private var hasInitializedFromState: Bool = false
    
    init(remoteItem: RemoteItem?, targetHeight: CGFloat, currentRemoteItem: Binding<RemoteItem?>, remoteItemStack: Binding<[RemoteItem]>, mainModel: Binding<RemoteMainModel>, remoteStates: Binding<[HAState]>) {
        self._currentRemoteItem = currentRemoteItem
        self.targetHeight = targetHeight
        self._remoteItemStack = remoteItemStack
        self._mainModel = mainModel
        self._remoteStates = remoteStates
        self.remoteItem = remoteItem
        if let rv = remoteItem, let steps = rv.steps, !steps.isEmpty {
            self._compareValues = steps
        }
    }
    
    // Compute the current IState for this toggle, if available
    private var currentState: HAState? {
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
                    hasInitializedFromState = false
                    isOn = isStateOn
                    hasInitializedFromState = true
                }
                .onChange(of: isOn) { _, _ in
                    if hasInitializedFromState && isOn != isStateOn {
                        let id = HomeRemoteAPI.shared.sendCommand(device: remoteItem?.device ?? "", command: remoteItem?.command ?? "")
                        mainModel.executeCommand(id: id)
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
        .frame(height: targetHeight)
        .padding(3)
    }
}

#Preview {
    @Previewable @State var remoteItemStack: [RemoteItem] = []
    @Previewable @State var currentRemoteItem: RemoteItem? = nil
    @Previewable @State var mainModel = RemoteMainModel()
    @Previewable @State var remoteStates: [HAState] = []
    var remoteItem: RemoteItem? = nil
    var targetHeight: CGFloat = 60
    
    RemoteToggle(remoteItem: remoteItem, targetHeight: targetHeight, currentRemoteItem: $currentRemoteItem, remoteItemStack: $remoteItemStack, mainModel: $mainModel, remoteStates: $remoteStates)
}

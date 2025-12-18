//
//  RemoteBaseButton.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 16.12.25.
//

import SwiftUI

struct RemoteBaseButton: View {
    @Binding var remoteStates: [IState]
    
    private let action: () -> Void
    private let actionDeferred: ((Date, Int) -> Void)?
    private var remoteItem: RemoteItem?

    init(remoteItem: RemoteItem?,
         action: @escaping () -> Void,
         actionDeferred: ((Date, Int) -> Void)? = nil,
         remoteStates: Binding<[IState]>) {
        self.remoteItem = remoteItem
        self.action = action
        self.actionDeferred = actionDeferred
        self._remoteStates = remoteStates
    }
    
    @State private var showDeferred: Bool = false
    @State private var deferredType: Int = 0
    @State private var deferredDate: Date = Date()
    @State private var atDate: Date = Date()
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.mainWindowSize) var mainWindowSize
    
    var body: some View {
        // Derive current state without side effects
        let currentState = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice })
        // Compute background color from the state (use IState.calculatedColor if available)
        let backgroundColor: Color = {
            if let currentState {
                // If you want to use the provided calculatedColor:
                return currentState.calculatedColor.opacity(0.9)
            } else {
                return Color.primary.opacity(0.3)
            }
        }()
        let background = RoundedRectangle(cornerRadius: 10)
            .fill(.ultraThinMaterial)
            .background(backgroundColor)
            .cornerRadius(10)
        Button(action: {}) {
            HStack {
                ButtonTextAndIcon(currentRemoteItem: remoteItem, currentState: currentState)
                if remoteItem?.template == RemoteTemplate.List
                    || remoteItem?.template == RemoteTemplate.Wrap
                    || remoteItem?.template == RemoteTemplate.Grid3X4
                    || remoteItem?.template == RemoteTemplate.Grid4X5
                    || remoteItem?.template == RemoteTemplate.Grid5x3 {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .font(.footnote)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            if remoteItem?.template == RemoteTemplate.List
                || remoteItem?.template == RemoteTemplate.Wrap
                || remoteItem?.template == RemoteTemplate.Grid3X4
                || remoteItem?.template == RemoteTemplate.Grid4X5
                || remoteItem?.template == RemoteTemplate.Grid5x3 {
                self.action()
            } else {
                var components = DateComponents()
                components.hour = 0
                components.minute = 5
                
                deferredDate = Calendar.current.date(from: components) ?? .now
                atDate = Date.now.addingTimeInterval(86400)
                
                deferredType = 0
                showDeferred = true
            }
        })
        /*
        .simultaneousGesture(TapGesture(count: 2).onEnded {
        }
        */
        .simultaneousGesture(TapGesture().onEnded {
            self.action()
        })
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .background(background)
        .cornerRadius(10)
        .shadow(radius: 3)
        .popover(isPresented: $showDeferred,
                 attachmentAnchor: .point(.center), // Ankerpunkt des Popovers relativ zum Button
                 arrowEdge: .top) {
            Picker("Deferred", selection: $deferredType) {
                Text("Delay").tag(0)
                Text("Cyclic").tag(1)
                Text("At").tag(2)
                Text("Daily").tag(3)
                Text("Weekly").tag(4)
                Text("Monthly").tag(5)
            }
            .pickerStyle(.menu)
            Divider()
            VStack {
                if deferredType == 0 {
                    DatePicker(
                            "Delay",
                            selection: $deferredDate,
                            displayedComponents: [.hourAndMinute]
                    )
                    HStack {
                        Spacer()
                        Button("OK", systemImage: "checkmark.circle") {
                            showDeferred = false
                            if actionDeferred != nil {
                                actionDeferred!(deferredDate, 0)
                            }
                        }
                    }
                } else {
                    if deferredType == 1 {
                        DatePicker(
                            "Delay",
                            selection: $deferredDate,
                            displayedComponents: [.hourAndMinute]
                        )
                        HStack {
                            Spacer()
                            Button("OK", systemImage: "checkmark.circle") {
                                showDeferred = false
                                if actionDeferred != nil {
                                    actionDeferred!(deferredDate, 1)
                                }
                            }
                        }
                    } else {
                        if deferredType == 2 {
                            DatePicker(
                                "At",
                                selection: $atDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            HStack {
                                Spacer()
                                Button("OK", systemImage: "checkmark.circle") {
                                    showDeferred = false
                                    if actionDeferred != nil {
                                        actionDeferred!(atDate, 2)
                                    }
                                }
                            }
                        } else {
                            if deferredType == 3 {
                                DatePicker(
                                    "At",
                                    selection: $atDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                HStack {
                                    Spacer()
                                    Button("OK", systemImage: "checkmark.circle") {
                                        showDeferred = false
                                        if actionDeferred != nil {
                                            actionDeferred!(atDate, 3)
                                        }
                                    }
                                }
                            } else {
                                if deferredType == 4 {
                                    DatePicker(
                                        "At",
                                        selection: $atDate,
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    HStack {
                                        Spacer()
                                        Button("OK", systemImage: "checkmark.circle") {
                                            showDeferred = false
                                            if actionDeferred != nil {
                                                actionDeferred!(atDate, 4)
                                            }
                                        }
                                    }
                                } else {
                                    if deferredType == 5 {
                                        DatePicker(
                                            "At",
                                            selection: $atDate,
                                            displayedComponents: [.date, .hourAndMinute]
                                        )
                                        HStack {
                                            Spacer()
                                            Button("OK", systemImage: "checkmark.circle") {
                                                showDeferred = false
                                                if actionDeferred != nil {
                                                    actionDeferred!(atDate, 5)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(minWidth: mainWindowSize.width - 20)
            .presentationCompactAdaptation(.popover)
        }
    }
}

#Preview {
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil
    
    
    RemoteBaseButton(remoteItem: remoteItem, action: { return }, actionDeferred: nil, remoteStates: $remoteStates)
}

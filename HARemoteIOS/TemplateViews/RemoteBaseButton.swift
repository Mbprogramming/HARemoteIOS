//
//  RemoteBaseButton.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 16.12.25.
//

import SwiftUI

struct RemoteBaseButton: View {
    @Binding var remoteStates: [HAState]
    
    private let action: () -> Void
    private let actionDeferred: ((Date, Int) -> Void)?
    private var remoteItem: RemoteItem?
    public var targetHeight: CGFloat = 200

    init(remoteItem: RemoteItem?,
         targetHeight: CGFloat,
         action: @escaping () -> Void,
         actionDeferred: ((Date, Int) -> Void)? = nil,
         remoteStates: Binding<[HAState]>) {
        self.remoteItem = remoteItem
        self.targetHeight = targetHeight
        self.action = action
        self.actionDeferred = actionDeferred
        self._remoteStates = remoteStates
    }
    
    @State private var showDeferred: Bool = false
    @State private var deferredType: Int = 0
    @State private var deferredDate: Date = Date()
    @State private var atDate: Date = Date()
    @State private var parentHeight: CGFloat = 60.0
    
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
                ButtonTextAndIcon(currentRemoteItem: remoteItem, currentState: currentState, targetHeight: targetHeight, parentHeight: $parentHeight)
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
            .onGeometryChange(for: CGSize.self) { proxy in
                            proxy.size
                        } action: {
                            parentHeight = $0.height
                        }
            .padding(5)
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
        .padding(3)
        .sheet(isPresented: $showDeferred) {
            VStack {
                Text("Delayed Execution")
                    .font(.headline)
                    .padding()
                HStack{
                    Text("Delay Type:")
                    Spacer()
                    Picker("Delay Type:", selection: $deferredType) {
                        Text("Delay").tag(0)
                        Text("Cyclic").tag(1)
                        Text("At").tag(2)
                        Text("Daily").tag(3)
                        Text("Weekly").tag(4)
                        Text("Monthly").tag(5)
                    }
                    .pickerStyle(.menu)
                    .padding()
                }
                .padding()
            Divider()
                @ViewBuilder
                func deferredPicker(_ date: Binding<Date>, label: String, components: DatePickerComponents, tag: Int) -> some View {
                    DatePicker(label, selection: date, displayedComponents: components)
                        .padding()
                    Spacer()
                    HStack {
                        Button("Cancel", systemImage: "xmark.circle") {
                            showDeferred.toggle()
                        }
                        .padding()
                        Spacer()
                        Button("OK", systemImage: "checkmark.circle") {
                            showDeferred = false
                            if let actionDeferred = actionDeferred {
                                actionDeferred(date.wrappedValue, tag)
                            }
                        }
                    }
                    .padding()
                }

                switch deferredType {
                case 0:
                    deferredPicker($deferredDate, label: "Delay", components: [.hourAndMinute], tag: 0)
                case 1:
                    deferredPicker($deferredDate, label: "Delay", components: [.hourAndMinute], tag: 1)
                case 2:
                    deferredPicker($atDate, label: "At", components: [.date, .hourAndMinute], tag: 2)
                case 3:
                    deferredPicker($atDate, label: "At", components: [.date, .hourAndMinute], tag: 3)
                case 4:
                    deferredPicker($atDate, label: "At", components: [.date, .hourAndMinute], tag: 4)
                case 5:
                    deferredPicker($atDate, label: "At", components: [.date, .hourAndMinute], tag: 5)
                default:
                    EmptyView()
                }
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    @Previewable @State var remoteStates: [HAState] = []
    var remoteItem: RemoteItem? = nil
    var targetHeight: CGFloat = 60
    
    RemoteBaseButton(remoteItem: remoteItem, targetHeight: targetHeight, action: { return }, actionDeferred: nil, remoteStates: $remoteStates)
}

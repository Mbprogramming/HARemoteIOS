//
//  RemoteState.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 02.12.25.
//

import SwiftUI

struct RemoteStateItemView: View {
    var state: IState
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    func uiColorFromHex(rgbValue: Int64) -> UIColor {
        
        // &  binary AND operator to zero out other color values
        // >>  bitwise right shift operator
        // Divide by 0xFF because UIColor takes CGFloats between 0.0 and 1.0
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var body: some View {
        let color = state.color != nil ? Color(uiColorFromHex(rgbValue: Int64(state.color!))).opacity(0.3) : Color.primary.opacity(0.3)
        HStack {
            if state.icon != nil && !(state.icon?.isEmpty ?? false) {
                if colorScheme == .light {
                    let iconUrl = "http://192.168.5.106:5000/api/homeautomation/Bitmap?width=40&height=40&id=\(state.icon!)"
                    AsyncImage(url: URL(string: iconUrl))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                } else {
                    let iconUrl = "http://192.168.5.106:5000/api/homeautomation/Bitmap?inverted=true&width=40&height=40&id=\(state.icon!)"
                    AsyncImage(url: URL(string: iconUrl))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
            }
            Spacer()
            VStack {
                HStack {
                    Spacer()
                    Text("\(state.device ?? "") \(state.id ?? "")")
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .font(.footnote)
                }
                HStack{
                    Spacer()
                    Text(state.convertedValue ?? "")
                        .bold()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
        )
    }
}

struct RemoteState: View {
    var remoteItem: RemoteItem?
    var height: CGFloat = 150
    
    @Binding var remoteStates: [IState]
    
    var body: some View {
        let currentState = remoteStates.first(where: { $0.id == remoteItem?.state && $0.device == remoteItem?.stateDevice })
        if currentState != nil {
            RemoteStateItemView(state: currentState!)
                .frame(maxWidth: .infinity, maxHeight: height)
        }
    }
}

#Preview {
    @Previewable @State var remoteStates: [IState] = []
    var remoteItem: RemoteItem? = nil

    RemoteState(remoteItem: remoteItem, height: 150, remoteStates: $remoteStates)
}

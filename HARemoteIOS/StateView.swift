//
//  StateView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

struct StateItemView: View {
    var state: IState
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        HStack {
            if state.showImage {
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(state.calculatedColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
        )
    }
}

struct StateView: View {
    @Binding var remoteStates: [IState]
    
    var body: some View {
        ScrollView {
            VStack{
                ForEach(remoteStates){state in
                    StateItemView(state: state)
                }
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var remoteStates: [IState] = []
    
    StateView(remoteStates: $remoteStates)
}

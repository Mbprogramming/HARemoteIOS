//
//  StateView.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 24.11.25.
//

import SwiftUI

struct StateItemView: View {
    var state: IState
    
    var body: some View {
        HStack {
            if state.showImage {
                AsyncServerImage(imageWidth: 40, imageHeight: 40, imageId: state.icon!)
                    .frame(width: 40, height: 40)
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
    @Environment(\.mainWindowSize) var mainWindowSize
    
    var body: some View {
        ScrollView {
            VStack{
                let height = mainWindowSize.height * 0.2
                Spacer(minLength: height)
                ForEach(remoteStates){state in
                    StateItemView(state: state)
                }
                Spacer(minLength: height)
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var remoteStates: [IState] = []
    
    StateView(remoteStates: $remoteStates)
}

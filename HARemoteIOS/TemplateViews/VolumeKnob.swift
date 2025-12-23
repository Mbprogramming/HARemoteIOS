//
//  VolumeKnob.swift
//  HARemoteIOS
//
//  Created by Markus Bach on 15.12.25.
//

import SwiftUI

/// The `GaugeStyle` of the `OverallView`.
struct OverallGaugeStyle<Content: View>: GaugeStyle {
  // MARK: - Properties
  
  /// The `View` contained by the gauge.
  var content: Content
  
  /// The `LinearGradient` used to style the gauge.
  private var gradient = LinearGradient(
    colors:
      [
        Color.blue.opacity(0.3),
        Color.blue
      ],
    startPoint: .trailing,
    endPoint: .leading
  )
  
  // MARK: - Init
  
  /// The `init` of the `OverallGaugeStyle`.
  /// - Parameter content: The `View` contained by the gauge.
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  func makeBody(configuration: Configuration) -> some View {
    VStack {
      ZStack {
        content
        
        Circle()
          .trim(from: 0, to: configuration.value * 0.75)
          .stroke(gradient, style: StrokeStyle(lineWidth: 20, lineCap: .round))
          .rotationEffect(.degrees(135))
          .frame(width: 250, height: 250)
      }
      
      configuration.currentValueLabel
        .fontWeight(.bold)
        .font(.title2)
        .foregroundColor(Color.black)
    }
  }
}

struct VolumeKnob: View {
    @Binding var minValue: Int
    @Binding var maxValue: Int
    @Binding var angleForStep: Int
    @Binding var currentValue: Int
    @Binding var step: Int
    
    @State private var angle = Angle(degrees: 0.0)
    @State private var lastAngle = Angle(degrees: 0.0)
    @State private var difference = Double(0.0)
    
    @State private var currentValueString: String = "0dB"
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var rotation: some Gesture {
        DragGesture()
        .onChanged { value in
            lastAngle = angle
            // Vektor vom Zentrum (100, 100) zur Fingerposition
            let deltaX = value.location.x - 100
            let deltaY = value.location.y - 100
            
            // Aktuellen Winkel berechnen
            let radians = atan2(deltaY, deltaX)
            angle = Angle(radians: Double(radians))
            difference += lastAngle.degrees - angle.degrees
            if abs(difference) > Double(angleForStep) {
                if difference < 0.0 {
                    if currentValue + step <= maxValue {
                        currentValue += step
                    } else {
                        currentValue = maxValue
                    }
                } else {
                    if currentValue - step >= minValue {
                        currentValue -= step
                    } else {
                        currentValue = minValue
                    }
                }
                difference = 0.0
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("", systemImage: "speaker.minus") {
                    if currentValue - step >= minValue {
                        currentValue -= step
                    } else {
                        currentValue = minValue
                    }
                }
                .buttonStyle(.plain)
                ZStack {
                    Circle()
                        .fill(
                            AngularGradient(colors: [
                                .gray, .white, .gray, .white,
                                .gray, .white, .gray, .gray,
                                .white, .gray, .white, .white,
                                .gray
                            ], center: .center)
                        )
                        .rotationEffect(angle)
                        .frame(width: 100, height: 100)
                        .shadow(radius: 5)
                    Gauge(value: Double(currentValue), in: Double(minValue)...Double(maxValue)) {
                        Text("")
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(colorScheme == .dark ? Color.white : Color.black)
                    .scaleEffect(CGSize(width: 3, height: 3))
                    .frame(width: 200, height: 200)
                }
                Button("", systemImage: "speaker.plus") {
                    if currentValue + step <= maxValue {
                        currentValue += step
                    } else {
                        currentValue = maxValue
                    }
                }
                .buttonStyle(.plain)
            }
            Text(currentValueString)
                .font(.headline)
        }
        .gesture(rotation)
        .onChange(of: currentValue) {
            let val = Double(currentValue) / 10.0 - 80.0
            let roundedVal = val.rounded(toPlaces: 1)
            currentValueString = "\(roundedVal)dB"
        }
        .onAppear(){
            let val = Double(currentValue) / 10.0 - 80.0
            let roundedVal = val.rounded(toPlaces: 1)
            currentValueString = "\(roundedVal)dB"
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

#Preview {
    @Previewable @State var min: Int = 0
    @Previewable @State var max: Int = 100
    @Previewable @State var angleForStep: Int = 10
    @Previewable @State var currentValue: Int = 0
    @Previewable @State var step: Int = 1
    
    VolumeKnob(minValue: $min, maxValue: $max, angleForStep: $angleForStep, currentValue: $currentValue, step: $step)
}

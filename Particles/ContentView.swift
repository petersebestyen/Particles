//
//  ContentView.swift
//  Particles
//
//  Created by Péter Sebestyén on 2024.10.04.
//

import SwiftUI

struct ParticleModifier<T: Hashable>: ViewModifier {
    var trigger: T
    @State var angle = Angle.degrees(.random(in: 0...360))
    var distance: Double = 40
    
    var offset: CGSize {
        .init(width: cos(angle.radians) * distance,
              height: sin(angle.radians) * distance)
    }
    
    var t: AnyTransition {
        .asymmetric(insertion: .identity, removal:
                .offset(offset)
                .combined(with: .opacity)
                    )
                    
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .transition(t)
                .id(trigger)

        }
        .animation(.default.speed(0.2), value: trigger)
        .onChange(of: trigger) { _ in
            angle = Angle.degrees(.random(in: 0...360))
        }
    }
}
extension View {
    func sprayEffect<Trigger: Hashable>(trigger: Trigger) -> some View {
        self.background {
            ZStack {
                ForEach(0..<30) { _ in
                    self
                        .modifier(ParticleModifier(trigger: trigger))
                }
            }
        }
    }
}
struct ContentView: View {
    @ScaledMetric var dividerHeight: CGFloat = 18
    @State private var trigger = 0
    var body: some View {
        VStack {
            Button(action: { trigger += 1 }) {
                HStack {
                    Image(systemName: "star.fill")
                        .sprayEffect(trigger: trigger)
                    Divider()
                        .frame(height: dividerHeight)
                    Text("Favourite")
                }
                .contentShape(.rect)
            }
        }
        .buttonStyle(.link)
        .padding()
    }
}

#Preview {
    ContentView()
        .padding(50)
}

//
//  ContentView.swift
//  Particles
//
//  Created by Péter Sebestyén on 2024.10.04.
//

import SwiftUI



struct KeyframeModifier: ViewModifier, Animatable {
    var progress: Double
    var endOffset: CGSize
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    struct Value {
        var offset: CGSize
        var opacity: CGFloat
        var angle: Angle = .zero
    }
    
    func body(content: Content) -> some View {
        let timeline = KeyframeTimeline(initialValue: Value(offset: .zero, opacity: 0)) {
            KeyframeTrack(\.offset) {
                CubicKeyframe(endOffset * 0.5, duration: 0.3)
                CubicKeyframe(endOffset * 0.2, duration: 0.2)
                CubicKeyframe(endOffset, duration: 0.5)
            }
            KeyframeTrack(\.opacity) {
                CubicKeyframe(1, duration: 0.2)
                CubicKeyframe(0, duration: 0.8)
            }
            KeyframeTrack(\.angle) {
                CubicKeyframe(.degrees(360), duration: 0.7)
            }
        }
        let value = timeline.value(progress: progress)
        content
            .rotationEffect(value.angle)
            .offset(value.offset)
            .opacity(value.opacity)
    }
}

struct ParticleModifier<T: Hashable>: ViewModifier {
    var trigger: T
    
    @State var angle = Angle.degrees(.random(in: 0...360))
    @State var distance: Double = .random(in: 10...50)
    
    var offset: CGSize {
        .init(width: cos(angle.radians) * distance,
              height: sin(angle.radians) * distance)
    }
    
    var t: AnyTransition {
        .asymmetric(insertion: .identity,
                    removal:  .keyframe(offset: offset)
                    )
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .transition(t)
                .id(trigger)

        }
        .animation(.default.speed(0.1), value: trigger)
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

extension AnyTransition {
    static func keyframe(offset: CGSize) -> AnyTransition {
        modifier(active: KeyframeModifier(progress: 1, endOffset: offset),
                 identity: KeyframeModifier(progress: 0, endOffset: offset)
        )
    }
}

extension Animatable {
    static func *(lhs: Self, rhs: CGFloat) -> Self {
        var copy = lhs
        copy.animatableData.scale(by: rhs)
        return copy
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

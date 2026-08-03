import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject private var model = GameModel()
    @State private var scene: SCNScene?
    @State private var crown: Double = 0

    private let accent = Color(red: 0.984, green: 0.62, blue: 0.235)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let scene {
                SceneView(scene: scene, options: [.rendersContinuously])
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(model.score))")
                        .font(.system(size: 26, weight: .ultraLight, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text("PTS")
                        .font(.system(size: 9, weight: .light))
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                    Text(String(format: "%.1f", model.speedPct * 3.3))
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(accent)
                }
                .padding(.horizontal, 8)

                Spacer()

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.12))
                        Capsule()
                            .fill(accent)
                            .frame(width: max(4, geo.size.width * model.speedPct))
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 10)
                .padding(.bottom, 4)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .contentShape(Rectangle())
        .onTapGesture { model.tapImpulse() }
        .focusable(true)
        .digitalCrownRotation(
            $crown,
            from: -1_000_000, through: 1_000_000, by: 0.1,
            sensitivity: .high, isContinuous: true, isHapticFeedbackEnabled: false
        )
        .onChange(of: crown) { oldValue, newValue in
            model.crownDelta(newValue - oldValue)
        }
        .onAppear {
            scene = DrumFactory.makeScene(
                drumNode: model.drumNode,
                coinSystem: model.coinSystem,
                pileNode: model.pileNode
            )
            model.start()
        }
        .onDisappear { model.stop() }
    }
}

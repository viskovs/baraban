import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject private var model = GameModel()
    @State private var scene: SCNScene?
    @State private var crown: Double = 0

    private let accent = Color(red: 0.357, green: 0.553, blue: 0.937)
    private let textDark = Color(red: 0.114, green: 0.153, blue: 0.2)

    var body: some View {
        ZStack {
            Color(red: 0.902, green: 0.925, blue: 0.953).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(model.score))")
                        .font(.system(size: 28, weight: .ultraLight, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(textDark)
                        .contentTransition(.numericText())
                    Text("PTS")
                        .font(.system(size: 9, weight: .light))
                        .foregroundStyle(textDark.opacity(0.4))
                    Spacer()
                    Text(String(format: "%.1f", model.speedPct * 3.3))
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(accent)
                }
                .padding(.horizontal, 6)

                if let scene {
                    SceneView(scene: scene, options: [.rendersContinuously])
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Spacer()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(textDark.opacity(0.1))
                        Capsule()
                            .fill(accent)
                            .frame(width: max(4, geo.size.width * model.speedPct))
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 8)
                .padding(.bottom, 2)
            }
        }
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
            scene = DrumFactory.makeScene(drumNode: model.drumNode)
            model.start()
        }
        .onDisappear { model.stop() }
    }
}

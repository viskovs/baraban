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
            }

            CoinPile(count: min(Int(model.score / 40), 170))
                .ignoresSafeArea()
                .allowsHitTesting(false)

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
            scene = DrumFactory.makeScene(drumNode: model.drumNode, coinSystem: model.coinSystem)
            model.start()
        }
        .onDisappear { model.stop() }
    }
}

struct CoinPile: View {
    let count: Int

    var body: some View {
        Canvas { ctx, size in
            guard count > 0 else { return }
            let d: CGFloat = 22
            let perRow = Int(size.width / (d * 0.86)) + 1
            for i in 0..<count {
                let row = i / perRow
                let col = i % perRow
                let jx = jitter(i, salt: 12.9898) * 6
                let jy = jitter(i, salt: 78.233) * 4
                let xOffset = row % 2 == 1 ? d * 0.43 : 0
                let x = CGFloat(col) * d * 0.86 + xOffset - d * 0.4 + jx
                let y = size.height - CGFloat(row) * d * 0.62 - d * 0.8 + jy
                let rect = CGRect(x: x, y: y, width: d, height: d * 0.92)
                ctx.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        Gradient(colors: [
                            Color(red: 1.0, green: 0.91, blue: 0.54),
                            Color(red: 1.0, green: 0.84, blue: 0.0),
                            Color(red: 0.91, green: 0.58, blue: 0.36),
                        ]),
                        center: CGPoint(x: rect.midX - 4, y: rect.midY - 5),
                        startRadius: 1,
                        endRadius: d * 0.62
                    )
                )
            }
        }
    }

    private func jitter(_ i: Int, salt: Double) -> CGFloat {
        let v = sin(Double(i) * salt) * 43758.5453
        return CGFloat(v - v.rounded(.down) - 0.5)
    }
}

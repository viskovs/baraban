import Foundation
import SceneKit
import WatchKit

final class GameModel: ObservableObject {
    static let baseFriction = 0.993
    static let swipePower = 0.15
    static let maxSwipe = 0.8
    static let minVelocity = 0.03
    static let maxVelocity = 5.0

    @Published var score: Double = 0
    @Published var speedPct: Double = 0

    let drumNode = SCNNode()

    private var velocity: Double = 0
    private var angle: Double = 0
    private var lastFace = 0
    private var lastHaptic = Date.distantPast
    private var timer: Timer?

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.step(frames: 2)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func crownDelta(_ delta: Double) {
        let power = min(abs(delta) * Self.swipePower * 4, Self.maxSwipe)
        let next = velocity + power * (delta < 0 ? -1 : 1)
        velocity = max(-Self.maxVelocity, min(Self.maxVelocity, next))
    }

    private func step(frames: Double) {
        velocity *= pow(Self.baseFriction + 0.001, frames)
        if abs(velocity) < Self.minVelocity { velocity = 0 }

        angle += velocity * 2.2 * frames
        drumNode.eulerAngles.y = Float(angle * .pi / 180)

        let absV = abs(velocity)
        speedPct = min(absV / Self.maxVelocity, 1)
        if absV > Self.minVelocity {
            score += absV * 0.0175 * 25 * frames
        }

        let normalized = (angle.truncatingRemainder(dividingBy: 360) + 360)
            .truncatingRemainder(dividingBy: 360)
        let face = Int(normalized / 22.5)
        if face != lastFace {
            lastFace = face
            if absV > 0.4, Date().timeIntervalSince(lastHaptic) > 0.12 {
                WKInterfaceDevice.current().play(.click)
                lastHaptic = Date()
            }
        }
    }
}

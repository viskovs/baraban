import SceneKit
import UIKit

enum DrumFactory {
    static func makeScene(drumNode: SCNNode, coinSystem: SCNParticleSystem, pileNode: SCNNode) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black

        let faceWidth: CGFloat = 0.42
        let faceHeight: CGFloat = 3.4
        let radius = faceWidth / (2 * tan(.pi / 16))

        for i in 0..<16 {
            let plane = SCNPlane(width: faceWidth * 0.95, height: faceHeight)
            let material = SCNMaterial()
            let brightness: CGFloat = i % 2 == 0 ? 0.96 : 0.82
            material.diffuse.contents = UIColor(hue: 28.0 / 360.0, saturation: 0.82, brightness: brightness, alpha: 1)
            material.lightingModel = .lambert
            material.isDoubleSided = false
            plane.materials = [material]

            let node = SCNNode(geometry: plane)
            let faceAngle = CGFloat(i) * (.pi / 8)
            node.position = SCNVector3(radius * sin(faceAngle), 0, radius * cos(faceAngle))
            node.eulerAngles = SCNVector3(0, faceAngle, 0)
            drumNode.addChildNode(node)
        }
        scene.rootNode.addChildNode(drumNode)

        configureCoins(coinSystem)
        let emitter = SCNNode()
        emitter.position = SCNVector3(0, 0.2, -1.5)
        emitter.addParticleSystem(coinSystem)
        scene.rootNode.addChildNode(emitter)

        pileNode.position = SCNVector3(0, 0, -1.6)
        scene.rootNode.addChildNode(pileNode)

        let camera = SCNCamera()
        camera.fieldOfView = 45
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 5.6)
        scene.rootNode.addChildNode(cameraNode)

        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.intensity = 900
        let keyNode = SCNNode()
        keyNode.light = keyLight
        keyNode.eulerAngles = SCNVector3(-0.25, 0.35, 0)
        scene.rootNode.addChildNode(keyNode)

        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 450
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        return scene
    }

    private static func configureCoins(_ system: SCNParticleSystem) {
        system.particleImage = coinImage()
        system.birthRate = 0
        system.particleLifeSpan = 1.6
        system.particleLifeSpanVariation = 0.4
        system.emitterShape = SCNCylinder(radius: 1.2, height: 2.4)
        system.birthDirection = .surfaceNormal
        system.particleVelocity = 1.6
        system.particleVelocityVariation = 0.8
        system.acceleration = SCNVector3(0, -5.0, 0)
        system.particleSize = 0.15
        system.particleSizeVariation = 0.06
        system.particleAngularVelocity = 260
        system.particleAngularVelocityVariation = 220
        system.orientationMode = .billboardScreenAligned
        system.blendMode = .alpha
        system.isLightingEnabled = false
    }

    private static let coinMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = coinImage()
        material.lightingModel = .constant
        material.isDoubleSided = false
        return material
    }()

    static func pileCoinNode(index i: Int) -> SCNNode {
        let plane = SCNPlane(width: 0.46, height: 0.42)
        plane.materials = [coinMaterial]
        let node = SCNNode(geometry: plane)
        let perRow = 11
        let row = i / perRow
        let col = i % perRow
        let xOffset: Float = row % 2 == 1 ? 0.22 : 0
        let x = -2.3 + Float(col) * 0.45 + xOffset + jitter(i, salt: 12.9898) * 0.14
        let y = -2.85 + Float(row) * 0.3 + jitter(i, salt: 78.233) * 0.08
        let z = jitter(i, salt: 39.425) * 0.1
        node.position = SCNVector3(x, y, z)
        return node
    }

    private static func jitter(_ i: Int, salt: Double) -> Float {
        let v = sin(Double(i) * salt) * 43758.5453
        return Float(v - v.rounded(.down) - 0.5)
    }

    private static func coinImage() -> UIImage {
        let size = CGSize(width: 32, height: 32)
        UIGraphicsBeginImageContextWithOptions(size, false, 2)
        defer { UIGraphicsEndImageContext() }
        guard let cg = UIGraphicsGetCurrentContext() else { return UIImage() }

        let colors = [
            UIColor(red: 1.0, green: 0.91, blue: 0.54, alpha: 1).cgColor,
            UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1).cgColor,
            UIColor(red: 0.91, green: 0.58, blue: 0.36, alpha: 1).cgColor,
        ]
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: [0, 0.45, 1]
        ) else { return UIImage() }

        cg.addEllipse(in: CGRect(origin: .zero, size: size))
        cg.clip()
        cg.drawRadialGradient(
            gradient,
            startCenter: CGPoint(x: 12, y: 10), startRadius: 1,
            endCenter: CGPoint(x: 16, y: 16), endRadius: 17,
            options: .drawsAfterEndLocation
        )
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}

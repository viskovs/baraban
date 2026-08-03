import SceneKit
import UIKit

enum DrumFactory {
    static func makeScene(drumNode: SCNNode, coinSystem: SCNParticleSystem) -> SCNScene {
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
        emitter.position = SCNVector3(0, 0.2, 0)
        emitter.addParticleSystem(coinSystem)
        scene.rootNode.addChildNode(emitter)

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
        system.emitterShape = SCNSphere(radius: 0.35)
        system.birthDirection = .surfaceNormal
        system.particleVelocity = 2.4
        system.particleVelocityVariation = 1.4
        system.acceleration = SCNVector3(0, -5.0, 0)
        system.particleSize = 0.15
        system.particleSizeVariation = 0.06
        system.particleAngularVelocity = 260
        system.particleAngularVelocityVariation = 220
        system.orientationMode = .billboardScreenAligned
        system.blendMode = .alpha
        system.isLightingEnabled = false
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

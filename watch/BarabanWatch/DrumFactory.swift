import SceneKit
import UIKit

enum DrumFactory {
    static func makeScene(drumNode: SCNNode) -> SCNScene {
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
}

import SceneKit
import UIKit

enum DrumFactory {
    static func makeScene(drumNode: SCNNode) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(red: 0.902, green: 0.925, blue: 0.953, alpha: 1)

        let faceWidth: CGFloat = 0.42
        let faceHeight: CGFloat = 3.2
        let radius = faceWidth / (2 * tan(.pi / 16))

        for i in 0..<16 {
            let plane = SCNPlane(width: faceWidth * 0.95, height: faceHeight)
            let material = SCNMaterial()
            let brightness: CGFloat = i % 2 == 0 ? 0.88 : 0.93
            material.diffuse.contents = UIColor(hue: 214.0 / 360.0, saturation: 0.08, brightness: brightness, alpha: 1)
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
        camera.fieldOfView = 42
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 6.4)
        scene.rootNode.addChildNode(cameraNode)

        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.intensity = 850
        let keyNode = SCNNode()
        keyNode.light = keyLight
        keyNode.eulerAngles = SCNVector3(-0.25, 0.35, 0)
        scene.rootNode.addChildNode(keyNode)

        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 550
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        return scene
    }
}

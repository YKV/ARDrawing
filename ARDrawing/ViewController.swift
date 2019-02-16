//
//  ViewController.swift
//  ARDrawing
//
//  Created by Eugene on 2019-02-14.
//  Copyright © 2019 Eugene. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var drawButton: UIButton!
    
    let configuration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        drawButton.layer.cornerRadius = 15
        drawButton.layer.borderColor = UIColor.white.cgColor
        drawButton.layer.borderWidth = 2
    }
    
    
    func draw(currentPosition: SCNVector3) {
        let sphereNode = SCNNode.init(geometry: SCNSphere.init(radius: 0.02))
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        sphereNode.position = currentPosition
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
    }
}


// MARK: ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
    // This will help everytime render scene
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // get point of view of scene view
        guard let pointOfView = sceneView.pointOfView else {
            return
        }
        // the pointOfView contains the current location of the camera view
        // the location of camera view in encoded in transform matrix
        // to get transform matrix do next:
        
        let transform = pointOfView.transform
        
        //extract current location of camera
        //the orientation is always encoded such as its x always a third column and row1, y is third column row2, z is third column row3
        //orientation value is reversed, so to irreversed we need to make x,y,z negative values
        let orientation = SCNVector3.init(-transform.m31, -transform.m32, -transform.m33)
        
        // the location is encoded in x always a 4th column and row1, y is 4th column row2, z is 4th column row3
        let location = SCNVector3.init(transform.m41, transform.m42, transform.m43)
        
        let currentPositionOfCamera = orientation + location
        
        DispatchQueue.main.async {
            if self.drawButton.isHighlighted {
                self.draw(currentPosition: currentPositionOfCamera)
            } else {
                let pointer = SCNNode.init(geometry: SCNSphere.init(radius: 0.01))
                pointer.name = "pointer"
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                pointer.position = currentPositionOfCamera
                
                self.sceneView.scene.rootNode.enumerateChildNodes({(node,_) in
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                })
                self.sceneView.scene.rootNode.addChildNode(pointer)
            }
        }
        
    }
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

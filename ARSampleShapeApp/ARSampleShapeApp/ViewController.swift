//
//  ViewController.swift
//  ARSampleShapeApp
//
//  Created by 尾原徳泰 on 2020/10/09.
//  Copyright © 2020 尾原徳泰. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private let device = MTLCreateSystemDefaultDevice()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        sceneView.delegate = self
        // シーンを作成
        sceneView.scene = SCNScene()
        // 特徴点を描写
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // 平面を検出
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    // 平面検出時の処理
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { fatalError() }
        
        // 平面ジオメトリの作成
        let planeGeometry = ARSCNPlaneGeometry(device: device)!
        planeGeometry.update(from: planeAnchor.geometry)
        planeGeometry.materials.first?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        
        // 平面のノード作成
        let planeNode = SCNNode()
        planeNode.geometry = planeGeometry
        
        // ノードの追加
        node.addChildNode(planeNode)
    }

    // 平面の形状が更新された時に呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        guard let planeGeometry = node.childNodes.first!.geometry as? ARSCNPlaneGeometry else { return }
        
        // 平面の形状をアップデート
        planeGeometry.update(from: planeAnchor.geometry)
    }
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

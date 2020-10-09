//
//  ViewController.swift
//  ARSampleMarkerApp
//
//  Created by 尾原徳泰 on 2020/10/09.
//  Copyright © 2020 尾原徳泰. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        sceneView.delegate = self
        // シーンを作成
        sceneView.scene = SCNScene()
        
        // ライトの追加
        sceneView.automaticallyUpdatesLighting = true
        
        // 画像認識用の参照画像を取得
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        
        sceneView.session.run(configuration)
    }
    
    // マーカーが検出された時に呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // ノードの作成
        let boxNode = SCNNode()
        // ジオメトリの位置を設定
        boxNode.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        boxNode.position.y += 0.025
        
        // 子要素に登録
        node.addChildNode(boxNode)
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

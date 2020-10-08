//
//  ViewController.swift
//  ARSphereApp
//
//  Created by 尾原徳泰 on 2020/10/08.
//  Copyright © 2020 尾原徳泰. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // デリゲートの起動先を自身に設定
        sceneView.delegate = self
        // シーンを作成して登録
        sceneView.scene = SCNScene()
        // 特徴点の表示
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // ライトの追加
        sceneView.autoenablesDefaultLighting = true
        //　平面検出
        // ARWorldTrackingConfigurationインスタンス作成
        let configuration = ARWorldTrackingConfiguration()
        // 探す面を水平面に設定
        configuration.planeDetection = .horizontal
        // セッションスタート
        sceneView.session.run(configuration)
    }
    
    // 平面が検出された時に呼ばれる関数
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 球ようのノードを作成
        let sphereNode = SCNNode()
        
        // ノードにGeometryとTransformを設定する
        sphereNode.geometry = SCNSphere(radius: 0.05)
        sphereNode.position.y += Float(0.05)
        
        // 検出面の子要素にする
        node.addChildNode(sphereNode)
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

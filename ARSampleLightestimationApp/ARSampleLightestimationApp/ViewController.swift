//
//  ViewController.swift
//  ARSampleLightestimationApp
//
//  Created by 尾原徳泰 on 2020/10/09.
//  Copyright © 2020 尾原徳泰. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var omniLight: SCNLight!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        sceneView.delegate = self
        // シーンを登録
        sceneView.scene = SCNScene()
        // 特徴点を表示
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // ライトの追加
        // インスタンスの作成
        let omniLinghtNode = SCNNode()
        omniLinghtNode.light = SCNLight()
        omniLinghtNode.light!.type = .omni
        omniLinghtNode.position = SCNVector3(0, 10, 10)
        omniLinghtNode.light!.color = UIColor.white
        self.sceneView.scene.rootNode.addChildNode(omniLinghtNode)
        
        // ライトをメンバ変数に保存
        omniLight = omniLinghtNode.light
        // 平面の検出
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // 光原推定を有効化
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration)
    }
    
    // 平面検出時の処理
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // scnファイルからシーンの読み込み
        let scene = SCNScene(named: "art.scnassets/field.scn")
        // シーンからノードを検索
        let fieldNode = (scene?.rootNode.childNode(withName: "field", recursively: false))!
        // 検出面の子要素にする
        node.addChildNode(fieldNode)
    }

    // 平面更新時の処理
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // 光原推定が有効かどうか調べる
        guard let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate else { return }
        
        // ライトの推定値で更新する
        omniLight?.intensity = (self.sceneView.session.currentFrame!.lightEstimate?.ambientIntensity)!
        omniLight?.temperature = (self.sceneView.session.currentFrame!.lightEstimate?.ambientColorTemperature)!
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

//
//  ViewController.swift
//  ARSampleLazerApp
//
//  Created by 尾原徳泰 on 2020/10/10.
//  Copyright © 2020 尾原徳泰. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var label: UILabel!
    
    var centerPos = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //　デリゲートの設定
        sceneView.delegate = self
        // シーンの作成
        sceneView.scene = SCNScene()
        // 画面中央の座標を保存
        centerPos = sceneView.center
        // セッションの開始
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    // マイフレーム呼ばれる関数
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // 画面中央と特徴点の当たり判定
        let hitResults = sceneView.hitTest(centerPos, types: [.featurePoint])
        
        // 結果取得に成功しているか
        if !hitResults.isEmpty {
            if let hitResult = hitResults.first {
                let distance = hitResult.distance
                
                // 当たっていたら距離を表示
                DispatchQueue.main.async {
                    self.label.text = String(format: "%.1f", distance * 100) + " cm"
                }
            }
        }
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

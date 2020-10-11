//
//  ViewController.swift
//  ARSampleMeasureApp
//
//  Created by 尾原徳泰 on 2020/10/11.
//  Copyright © 2020 尾原徳泰. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!
    
    var centerPos = CGPoint(x: 0, y: 0)
    var tapCount = 0
    var startPos = float3(0, 0, 0)
    var currentPos = float3(0, 0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        sceneView.delegate = self
        // シーンを作成
        sceneView.scene = SCNScene()
        // 画面中央の座標を保存
        centerPos = sceneView.center
        // セッションの開始
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    // 球の描画
    private func putSphere(at pos: float3) {
        let node = SCNNode()
        node.geometry = SCNSphere(radius: 0.003)
        node.position = SCNVector3(pos.x, pos.y, pos.z)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    // タップされた時の処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 球の配置
        putSphere(at: currentPos)
        
        if tapCount == 0 { // 1度目のタップ
            startPos = currentPos
            tapCount = 1
        } else { // 2度目のタップ
            tapCount = 0
            let lineNode = drawLine(from: SCNVector3(startPos), to: SCNVector3(currentPos))
            sceneView.scene.rootNode.addChildNode(lineNode)
        }
    }
    
    // 直線を描画
    func drawLine(from: SCNVector3, to: SCNVector3) -> SCNNode {
        // 直線を描画する
        let source = SCNGeometrySource(vertices: [from, to])
        let element = SCNGeometryElement(data: Data.init(bytes: [0, 1]), primitiveType: .line, primitiveCount: 1, bytesPerIndex: 1)
        
        let geometry = SCNGeometry(sources: [source], elements: [element])
        
        // 直線ノードの作成
        let node = SCNNode()
        node.geometry = geometry
        node.geometry?.materials.first?.diffuse.contents = UIColor.white
        return node
    }
    
    // マイフレーム呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // タップされた位置を取得する
        let hitResults = sceneView.hitTest(centerPos, types: [.featurePoint])
        // 結果取得に成功しているかどうか
        if !hitResults.isEmpty {
            if let hitResult = hitResults.first {
                // 現実の座標をSCNVectorで返す
                currentPos = float3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
                
                // まだ一度しかタップされていない場合
                if tapCount == 1 {
                    // 始点から現在の長さの計測
                    let len = distance(startPos, currentPos)
                    DispatchQueue.main.async {
                        // ラベルに反映する
                        self.label.text = String(format: "%.1f", len * 100) + " cm"
                    }
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

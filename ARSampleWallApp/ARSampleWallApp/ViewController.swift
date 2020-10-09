//
//  ViewController.swift
//  ARSampleWallApp
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
        // デリゲートの設定
        sceneView.delegate = self
        // シーンを登録
        sceneView.scene = SCNScene()
        // 特徴点を表示する
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // 垂直面を検出する
        // インスタンスの生成
        let confiuration = ARWorldTrackingConfiguration()
        confiuration.planeDetection = .vertical
        sceneView.session.run(confiuration)
    }
    
    // 平面を検出した時に呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // anchorの検出があるかどうかでエラー処理
        guard let planeAnchor = anchor as? ARPlaneAnchor else { fatalError() }
        // ノードの作成
        let planeNode = SCNNode()
        // ジオメトリの作成
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        geometry.materials.first?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        
        // ノードにジオメトリとトランスフォームを指定
        planeNode.geometry = geometry
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        // 検出したアンカーに対応するノードに子ノードとして持たせる
        node.addChildNode(planeNode)
    }
    
    // 平面が更新された時に呼ばれる処理
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // エラー処理
        guard let planeAnchor = anchor as? ARPlaneAnchor else { fatalError() }
        guard let geometryPlaneNode = node.childNodes.first, let planeGeometory = geometryPlaneNode.geometry as? SCNPlane else { fatalError() }
        
        // ジオメトリをアップデート
        planeGeometory.width = CGFloat(planeAnchor.extent.x)
        planeGeometory.height = CGFloat(planeAnchor.extent.z)
        geometryPlaneNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
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

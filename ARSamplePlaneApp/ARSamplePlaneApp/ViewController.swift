//
//  ViewController.swift
//  ARSamplePlaneApp
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
        //　デリゲート先を自身に設定
        sceneView.delegate = self
        // シーンを作成して尊く
        sceneView.scene = SCNScene()
        // 特徴点を表示する
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // 平面検出
        let configuartion = ARWorldTrackingConfiguration()
        configuartion.planeDetection = .horizontal
        sceneView.session.run(configuartion)
        
    }
    
    // 平面検出時の処理
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //　anchorがあるかどうかの判別とエラー処理
        guard let planeAnchor = anchor as? ARPlaneAnchor else { fatalError() }
        // ノードの作成
        let planeNode = SCNNode()
        // ジオメトリの作成
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        geometry.materials.first?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        
        // ノードにgeometryとtransformを設定
        planeNode.geometry = geometry
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        // 検出したアンカーに対応するノードの子ノードに追加
        node.addChildNode(planeNode)
    }
    
    // 平面が更新された時に呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //　anchorがあるかどうかの判別とエラー処理
        guard let planeAnchor = anchor as? ARPlaneAnchor else { fatalError() }
        guard let geometoryPlaneNode = node.childNodes.first, let planeGeometory = geometoryPlaneNode.geometry as? SCNPlane else { fatalError() }
        
        // ジオメトリをアップデートする
        planeGeometory.width = CGFloat(planeAnchor.extent.x)
        planeGeometory.height = CGFloat(planeAnchor.extent.z)
        geometoryPlaneNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
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

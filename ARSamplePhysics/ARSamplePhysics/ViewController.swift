//
//  ViewController.swift
//  ARSamplePhysics
//
//  Created by 尾原徳泰 on 2020/10/10.
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
        // シーンを作成して登録
        sceneView.scene = SCNScene()
        // 特徴点を描写
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // ライトの追加
        sceneView.automaticallyUpdatesLighting = true
        // 平面を検出
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    // 球を追加する
    func addSphere(hitResult: ARHitTestResult) {
        // ノードの生成
        let spherelNode = SCNNode()
        
        // GeometryとTransformの設定
        let sphereGeometry = SCNSphere(radius: 0.03)
        spherelNode.geometry = sphereGeometry
        spherelNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + 0.05, hitResult.worldTransform.columns.3.z)
        
        // ノードの追加
        sceneView.scene.rootNode.addChildNode(spherelNode)
        
    }
    
    // 平面が検出された時に呼ばる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { fatalError() }
        
        // ノードの作成
        let planeNode = SCNNode()
        // ジオメトリの作成
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        geometry.materials.first?.diffuse.contents = UIColor.black.withAlphaComponent(0.5)
        
        // ノードの設定
        planeNode.geometry = geometry
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        node.addChildNode(planeNode)
    }
    
    // 平面の更新時に呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { fatalError() }
        guard let geometryPlaneNode = node.childNodes.first, let planeGeometory = geometryPlaneNode.geometry as? SCNPlane else { fatalError() }
        // ジオメトリをアップデートする
        planeGeometory.width = CGFloat(planeAnchor.extent.x)
        planeGeometory.height = CGFloat(planeAnchor.extent.z)
        geometryPlaneNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 最初にタップした座標を取り出す
        guard let touch = touches.first else { return }
        // スクリーン座標に変換する
        let touchPos = touch.location(in: sceneView)
        // 検出した平面との当たり判定
        let hitTestResult = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            if let hitResult = hitTestResult.first {
                // 平面と当たっていたら球を追加する
                addSphere(hitResult: hitResult)
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

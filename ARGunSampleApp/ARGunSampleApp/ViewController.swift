//
//  ViewController.swift
//  ARGunSampleApp
//
//  Created by 尾原徳泰 on 2021/06/07.
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
        // 特徴点を表示する
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        // ライトの追加
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 最初にタップした座標を取り出す
        guard let touch = touches.first else { return }
        
        // スクリーン座標に変換する
        let touchPos = touch.location(in: sceneView)
        
        // タップされた位置のアンカーを探す
        let hitTest = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
        
        if !hitTest.isEmpty {
            let anchor = ARAnchor(transform: hitTest.first!.worldTransform)
            sceneView.session.add(anchor: anchor)
        }
    }
    
    // 平面を検出した時に呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        
        //球のノードの作成
        let sphereNode = SCNNode()
        // ノードにgeometryとtransformを設定
        sphereNode.geometry = SCNSphere(radius: 0.05)
        sphereNode.position.y += Float(0.05)
        
        // 検出の子要素にする
        node.addChildNode(sphereNode)
    }
    
}

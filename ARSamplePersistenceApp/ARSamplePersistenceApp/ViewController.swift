//
//  ViewController.swift
//  ARSamplePersistenceApp
//
//  Created by 尾原徳泰 on 2020/10/10.
//  Copyright © 2020 尾原徳泰. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("worldMapURL")
        } catch {
            fatalError("No such file")
        }
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        sceneView.delegate = self
        // シーンを作成
        sceneView.scene = SCNScene()
        // 特徴点を表示
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // ライトの追加
        sceneView.automaticallyUpdatesLighting = true
        // 平面の検出
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        
    }
    
    // タッチされた実行
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 最初にタップした座標を取り出す
        guard let touch = touches.first else { return }
        // スクリーン座標に変換する
        let touchPos = touch.location(in: sceneView)
        // タッチされた位置のARアンカーを探す
        let hitTest = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            // タップした箇所が取得できればアンカーを追加
            let anchor = ARAnchor(transform: hitTest.first!.worldTransform)
            sceneView.session.add(anchor: anchor)
        }
    }
    
    // 平面やアンカーが追加された時に呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        // scnファイルから読み込み
        let scene = SCNScene(named: "art.scnassets/testRed.scn")
        // シーンからノードを検索
        let testRedNode = (scene?.rootNode.childNode(withName: "testRed", recursively: false))!
        // 検出面の子要素として追加する
        node.addChildNode(testRedNode)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // 現在のARWorldMapを取得
        sceneView.session.getCurrentWorldMap { worldMap, error in
        guard let map = worldMap else { return }
        // シリアライズ
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else { return }
        // ローカルに保存
        guard ((try? data.write(to: self.worldMapURL)) != nil) else { return }
        }
    }
    
    @IBAction func loadButtonPressed(_ sender: Any) {
        // 保存したARWorldMapの読み出し
        var data: Data? = nil
        do {
            try data = Data(contentsOf: self.worldMapURL)
        } catch {
            return
        }
        // デシリアライズ
        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data!) else { return }
        // worldMapの再設定
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.initialWorldMap = worldMap
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
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

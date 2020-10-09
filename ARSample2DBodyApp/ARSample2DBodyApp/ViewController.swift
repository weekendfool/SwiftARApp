//
//  ViewController.swift
//  ARSample2DBodyApp
//
//  Created by 尾原徳泰 on 2020/10/10.
//  Copyright © 2020 尾原徳泰. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        sceneView.session.delegate = self
        // コンフィグレーションの設定
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = .bodyDetection
        
        sceneView.session.run(configuration)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // レイヤをクリア
        sceneView.layer.sublayers?.compactMap { $0 as? CAShapeLayer }.forEach { $0.removeFromSuperlayer() }
        
        guard let interfaceOrientation = sceneView.window?.windowScene?.interfaceOrientation else { return }
        
        let transform = frame.displayTransform(for: interfaceOrientation, viewportSize: sceneView.frame.size)
            
        if let detectedBody = frame.detectedBody {
            // 右手の位置を取得
            guard let rightHandPos = detectedBody.skeleton.landmark(for: ARSkeleton.JointName.rightHand) else { return }
            // ディスプレイ座標に変換
            let normalizedCenter = CGPoint(x: CGFloat(rightHandPos.x), y: CGFloat(rightHandPos.y)).applying(transform)
            let center = normalizedCenter.applying(CGAffineTransform.identity.scaledBy(x: sceneView.frame.width, y: sceneView.frame.height))
            
            // 円を描画
            let radius:CGFloat = 8.0
            let rect = CGRect(origin: CGPoint(x: center.x - radius, y: center.y - radius), size: CGSize(width: radius * 2, height: radius * 2))
            
            let circleLayer = CAShapeLayer()
            circleLayer.fillColor = UIColor.red.cgColor
            circleLayer.path = UIBezierPath(ovalIn: rect).cgPath
            sceneView.layer.addSublayer(circleLayer)
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

//
//  ViewController.swift
//  ARSampleShare
//
//  Created by 尾原徳泰 on 2020/10/10.
//  Copyright © 2020 尾原徳泰. All rights reserved.
//


import UIKit
import SceneKit
import ARKit
import MultipeerConnectivity

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    static let serviceType = "ar-multi-sample"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var mpsession: MCSession!
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    private var serviceBrowser: MCNearbyServiceBrowser!
    var otherPeerID: MCPeerID?
    let colorTable = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green,
                      UIColor.blue, UIColor.purple,UIColor.white, UIColor.black]
    var myColorIdx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 自分のチームカラー
        myColorIdx = Int(arc4random_uniform(UInt32(colorTable.count)))
        
        // MultipeerConnectiveityの初期化
        initMultipeerSession(receivedDataHandler: receivedData)
        
        // デリゲートを設定
        sceneView.delegate = self
        
        // シーンを作成
        sceneView.scene = SCNScene()
        
        // デバッグ用のポイントクラウド表示
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // ライトをONにする
        sceneView.autoenablesDefaultLighting = true;
        
        // 平面検出
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if(( anchor as? ARPlaneAnchor ) != nil) { return }
        
        // ノードの作成
        let sphereNode = SCNNode()
        let sphereGeometry = SCNSphere(radius: 0.03)
        
        // 球の色の決定
        if let name = anchor.name{
            sphereGeometry.materials.first?.diffuse.contents = colorTable[Int(name)!];
        }
        
        // ジオメトリの登録
        sphereNode.geometry = sphereGeometry
        sphereNode.position.y += 0.03
        
        // アンカーの子要素にする
        node.addChildNode( sphereNode )
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // タッチされた座標を取得
        guard let touch = touches.first else {return}
        
        // スクリーン座標に変換する
        let touchPos = touch.location(in: sceneView)
        
        // タップされた位置のARアンカーを探す
        let hitTest = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
        
        // 平面をタップした場合
        if !hitTest.isEmpty {
            // アンカーの名前に色のインデックスを指定する
            let anchor = ARAnchor(name: String(myColorIdx), transform: hitTest.first!.worldTransform)
            sceneView.session.add(anchor: anchor)
            
            
            // 相手にアンカーの追加情報を送信する
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject:  anchor, requiringSecureCoding: true)
                else { fatalError("can’t encode anchor") }
            self.sendToAllPeers(data)
        }
    }
    
    @IBAction func shareButtonPressed(_ button: UIButton) {
        // ワールドマップを取得する
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else { return }
            // データをシリアライズする
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("can’t encode map") }
            // 相手の端末に送信する
            self.sendToAllPeers(data)
        }
    }
    
    func receivedData(_ data: Data, from peer: MCPeerID) {
        do {
            // 受信データがARWorldMapだった場合
            if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                // Run the session with the received world map.
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = .horizontal
                configuration.initialWorldMap = worldMap
                sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                otherPeerID = peer
            }
        } catch {}
        do{
            // 受信データがARAnchorだった場合
            if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
                sceneView.session.add(anchor: anchor)
            }
        } catch {}
    }
}

extension ViewController: MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate{
    
    func initMultipeerSession(receivedDataHandler: @escaping (Data, MCPeerID) -> Void ) {
        mpsession = MCSession(peer: myPeerID, securityIdentity: nil,  encryptionPreference: .required)
        mpsession.delegate = self
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: ViewController.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: ViewController.serviceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    func sendToAllPeers(_ data: Data) {
        do {
            try mpsession.send(data, toPeers: mpsession.connectedPeers, with: .reliable)
        } catch {
            print("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    var connectedPeers: [MCPeerID] {
        return mpsession.connectedPeers
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        receivedData(data, from: peerID)
    }
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        browser.invitePeer(peerID, to: mpsession, withContext: nil, timeout: 10)
    }
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.mpsession)
    }
}

//import UIKit
//import SceneKit
//import ARKit
//import MultipeerConnectivity
//
//class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
//
//    @IBOutlet var sceneView: ARSCNView!
//
//    static let serviceType = "ar-multi-sample"
//
//    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
//    private var mpsession:MCSession!
//    private var serviceAdvertiser:MCNearbyServiceAdvertiser!
//    private var serviceBrowser: MCNearbyServiceBrowser!
//
//    var otherPeerID:MCPeerID?
//    let colorTable = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple, UIColor.white, UIColor.black]
//    var myColorIdx = 0
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // 自分のチームカラーを設定
//        myColorIdx = Int(arc4random_uniform(UInt32(colorTable.count)))
//        // MultipeerConnectiveityの初期化
//        initMultipeerSession(receivedDataHandler: recivedData)
//        // デリゲートの設定
//        sceneView.delegate = self
//        // シーンを作成
//        sceneView.scene = SCNScene()
//        // 特徴点を表示
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
//        // ライトを設定
//        sceneView.automaticallyUpdatesLighting = true
//
//        // 平面検出
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//        configuration.isCollaborationEnabled = true
//        sceneView.session.run(configuration)
//    }
//
//    // 平面検出時の処理
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        if ((anchor as? ARPlaneAnchor) != nil) { return }
//        // nodeの作成
//        let sphereNode = SCNNode()
//        let sphereGeometry = SCNSphere(radius: 0.03)
//
//        // 球の色決定
//        if let name = anchor.name {
//            sphereGeometry.materials.first?.diffuse.contents = colorTable[Int(name)!]
//        }
//        // ジオメトリの登録
//        sphereNode.geometry = sphereGeometry
//        sphereNode.position.y += 0.03
//
//        // アンカーの子要素にする
//        node.addChildNode(sphereNode)
//    }
//
//    // タッチされたら実行
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // タッチした座標を取得
//        guard let touch = touches.first else { return }
//        // スクリーン座標に変換する
//        let touchPos = touch.location(in: sceneView)
//        // タップされた位置のアンカーを探す
//        let hitTest = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
//
//        // 平面をタップしていた場合
//        if !hitTest.isEmpty {
//            // アンカーの名前に色のインデックスを指定する
//            let anchor = ARAnchor(name: String(myColorIdx), transform: hitTest.first!.worldTransform)
//            sceneView.session.add(anchor: anchor)
//
//            // 相手にアンカー情報を送信
//            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true) else { fatalError(" can't encode anchor") }
//            self.sendToAllPeers(data)
//        }
//    }
//
//    @IBAction func shareButtonPressed(_ sender: Any) {
//        // ワールドマップを取得
//        sceneView.session.getCurrentWorldMap { worldMap, error in
//            guard let map = worldMap else { return }
//            // データをシリアライズする
//            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else { fatalError("can't encode map") }
//            // 相手の端末に送信する
//            self.sendToAllPeers(data)
//        }
//    }
//
//    func receivedData(_ data: Data, from peer: MCPeerID) {
//        do {
//            // 受信データがARWorldMapだった場合
//            if let worldMap = try NSKeyedArchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
//            let configuration = ARWorldTrackingConfiguration()
//            configuration.planeDetection = .horizontal
//            configuration.initialWorldMap = worldMap
//            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//            otherPeerID = peer
//            }
//        } catch {}
//    do {
//        if let anchor = try NSKeyedArchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
//            sceneView.session.add(anchor: anchor)
//        }
//    } catch {}
//    }
//}
//
//extension ViewController: MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceBrowserDelegate {
//
//    func initiMultipeerSession(receivedDataHandler: @escaping (Data, MCPeerID) -> Void) {
//        mpsession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
//        mpsession.delegate = self
//
//        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: ViewController.serviceType)
//        serviceAdvertiser.delegate = self
//        serviceAdvertiser.startAdvertisingPeer()
//
//        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: ViewController.serviceType)
//        serviceBrowser.delegate = self
//        serviceBrowser.startBrowsingForPeers()
//    }
//
//    func sendToAllPeers(_ data: Data) {
//        do {
//            try mpsession.send(data, toPeers: mpsession.connectedPeers, with: .reliable)
//        } catch {
//            print("error sending data to peers:\(error.localizedDescription)")
//        }
//    }
//
//    var connectedPeers: [MCPeerID] {
//        return mpsession.connectedPeers
//    }
//
//    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        receivedData(data, from: peerID)
//    }
//
//    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}
//    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
//    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
//    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
//    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
//    browser.invitePeer(peerID, to: mpsession, withContext: nil, timeout: 10)
//    }
//    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//    invitationHandler(true, self.mpsession) }
//    }
//
//    // MARK: - ARSCNViewDelegate
//
///*
//    // Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        let node = SCNNode()
//
//        return node
//    }
//*/
//
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        // Present an error message to the user
//
//    }
//
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay
//
//    }
//
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required
//
//    }
//}
//

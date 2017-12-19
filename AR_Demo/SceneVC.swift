//
//  SceneVC.swift
//  AR_Demo
//
//  Created by Cemal Bayrı on 8.12.2017.
//  Copyright © 2017 Cemal Bayrı. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVKit

class SceneVC: UIViewController, ARSessionDelegate  {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var lblSessionStatus: UILabel!
    @IBOutlet weak var imgChristmas: UIImageView!
    
    let planeIdentifiers = [UUID]()
    var anchors = [ARAnchor]()
    var nodes = [SCNNode]()
    var configuration : ARWorldTrackingConfiguration?
    var spideyNode: SCNNode?
    var isPlaneSelected = false
    let planeHeight: CGFloat = 0
    var planeGeometry: SCNPlane!
    var myPlaneAnchor: ARPlaneAnchor?
    var planeNode = SCNNode()
    var planeNodesCount = 0
    var player: AVAudioPlayer?
    var myNodes = [SCNNode]()
    var newNode = SCNNode()
    var isShown = false
    
    
    /// Use average of recent virtual object distances to avoid rapid changes in object scale.
    private var recentVirtualObjectDistances = [Float]()
    
    /// Resets the objects poisition smoothing.
    func reset() {
        recentVirtualObjectDistances.removeAll()
    }
    
    var planePosition: SCNVector3! = SCNVector3(x:0,y:0,z:-1)
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        initializeSceneView()
//        loadNodeObject()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        /*
         Start the view's AR session with a configuration that uses the rear camera,
         device position and orientation tracking, and plane detection.
         */
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Show debug UI to view performance metrics (e.g. frames per second).
        sceneView.showsStatistics = true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let location = touch?.location(in: sceneView)
        
        if(touch?.view == self.sceneView){
            print("touch working")
            let viewTouchLocation:CGPoint = touch!.location(in: sceneView)
            guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {
                return
            }
            
            if result.node.name == "plane" {
                print("plane e girdi")
                let hitResults = sceneView.hitTest(location!, types: .existingPlaneUsingExtent)
                if hitResults.count > 0 {
                    let result: ARHitTestResult = hitResults.first!
                    
                    let newLocation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                    let node = createObject(position: newLocation)
                    
                }
                
            }
            else {
                print("sound a girdi")
                self.playSound()
            }
            
        }
    
    }
    
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "Im SpiderMan", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
  
    
    func setUI() {
        btnLeft.layer.cornerRadius = btnLeft.frame.size.height / 2
        btnRight.layer.cornerRadius = btnRight.frame.size.height / 2
        
        btnLeft.layer.borderColor = UIColor.white.cgColor
        btnLeft.layer.borderWidth = 0.5
        
        btnRight.layer.borderColor = UIColor.white.cgColor
        btnRight.layer.borderWidth = 0.5
    }
    
    func createObject(position: SCNVector3) -> SCNNode {
 
        let node =  SCNNode()
        let scene = SCNScene(named: "art.scnassets/Spider-Man_Modern.dae")
        let nodeArray = scene?.rootNode.childNodes
        for childNode in nodeArray! {
            node.addChildNode(childNode as SCNNode)
        }
        sceneView.scene.rootNode.addChildNode(node)
        
//        let action = SCNAction.rotateBy(x: 0, y: CGFloat(-Double.pi/2), z: 0, duration: 1)
//        node.runAction(action, forKey: "rotate")
        
        node.name = "spider"
        node.position = position
        myNodes.append(node)
    
        return node
    }
    
    func initializeSceneView() {
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.showsStatistics = true
        // Create new scene and attach the scene to the sceneView
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
    }
       
    
    func loadNodeObject() {
        // get access to scene from scene assets and parse for the lamp model
        let tempScene = SCNScene(named: "art.scnassets/Spider-Man_Modern.dae")!
        
        sceneView.scene = tempScene
    }
 
    @IBAction func btnLeftAction(_ sender: Any) {
        if !isShown {
            UIView.animate(withDuration: 0.5) {
                self.imgChristmas.alpha = 1
                self.isShown = true
            }
        }
        else {
            UIView.animate(withDuration: 0.5) {
                self.imgChristmas.alpha = 0
                self.isShown = false
            }
        }
        
    }
    
    @IBAction func bvtnPlayLeftAction(_ sender: Any) {
        self.playSound()
    }
    @IBAction func btnResetAction(_ sender: Any) {
        self.resetTracking()
    }
    
    /**
     Set the object's position based on the provided position relative to the `cameraTransform`.
     If `smoothMovement` is true, the new position will be averaged with previous position to
     avoid large jumps.
     
     - Tag: VirtualObjectSetPosition
     */
    func setPosition(_ newPosition: float3, relativeTo cameraTransform: matrix_float4x4, smoothMovement: Bool) {
        let cameraWorldPosition = cameraTransform.translation
        var positionOffsetFromCamera = newPosition - cameraWorldPosition
        
        // Limit the distance of the object from the camera to a maximum of 10 meters.
        if simd_length(positionOffsetFromCamera) > 10 {
            positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera)
            positionOffsetFromCamera *= 10
        }
        
    }
    
    /// - Tag: AdjustOntoPlaneAnchor
    func adjustOntoPlaneAnchor(_ anchor: ARPlaneAnchor, using node: SCNNode) {
        // Get the object's position in the plane's coordinate system.
        
        if let node = spideyNode {
            let planePosition = node.convertPosition(node.position, from: planeNode)
        }
        
//        let planePosition = node.convertPosition((spideyNode?.position)!, from: parent)
        
        // Check that the object is not already on the plane.
        guard planePosition.y != 0 else { return }
        
        // Add 10% tolerance to the corners of the plane.
        let tolerance: Float = 0.1
        
        let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
        let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
        let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
        
        guard (minX...maxX).contains(planePosition.x) && (minZ...maxZ).contains(planePosition.z) else {
            return
        }
        
        // Move onto the plane if it is near it (within 5 centimeters).
        let verticalAllowance: Float = 0.05
        let epsilon: Float = 0.001 // Do not update if the difference is less than 1 mm.
        let distanceToPlane = abs(planePosition.y)
        if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(distanceToPlane * 500) // Move 2 mm per second.
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            spideyNode?.position.y = anchor.transform.columns.3.y
            SCNTransaction.commit()
        }
    }
    
}

extension SceneVC: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planePosition = planeNode.position
        self.myPlaneAnchor = planeAnchor
        /*
         `SCNPlane` is vertically oriented in its local coordinate space, so
         rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
         */
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.name = "plane"
        // Make the plane visualization semitransparent to clearly show real-world placement.
        planeNode.opacity = 0.25
        
        /*
         Add the plane visualization to the ARKit-managed node so that it tracks
         changes in the plane anchor as plane estimation continues.
         */
        node.addChildNode(planeNode)
        myNodes.append(planeNode)
    }
    
    
    // Called when a new node has been mapped to the given anchor
    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        /*
         Plane estimation may extend the size of the plane, or combine previously detected
         planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
         corresponding node for one plane, then calls this method to update the size of
         the remaining plane.
         */
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal surfaces."
            
        case .normal:
            // No feedback needed when tracking is normal and planes are visible.
            message = ""
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        }
        
        lblSessionStatus.text = message
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        lblSessionStatus.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        lblSessionStatus.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        lblSessionStatus.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
 
}

extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
     */
    var translation: float3 {
        let translation = columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

// MARK: - CGPoint extensions

extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
    init(_ vector: SCNVector3) {
        x = CGFloat(vector.x)
        y = CGFloat(vector.y)
    }
    
    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}

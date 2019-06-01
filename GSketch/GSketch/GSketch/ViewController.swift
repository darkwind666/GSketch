//
//  ViewController.swift
//  GSketch
//
//  Created by user on 11/24/18.
//  Copyright © 2018 user. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate {

    static let selectedImageKey = "SimulatedStartDate"
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var sceneView2: ARSCNView!
    
    @IBOutlet weak var isVRSwitch: UISwitch!
    @IBOutlet weak var isVerticalPlane: UISwitch!
    @IBOutlet weak var galleryButton: UIButton!
    fileprivate lazy var session = ARSession()
    fileprivate lazy var sessionConfiguration = ARWorldTrackingConfiguration()
    var nodeWeCanChange: SCNNode?
    private var originalRotation: SCNVector3?
    //lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        setupScene()
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        //sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        //panGesture.delegate = self
        //sceneView.addGestureRecognizer(panGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(viewRotated))
        sceneView.addGestureRecognizer(rotationGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView2.scene = scene
        sceneView2.isPlaying = true
        
        if isVRSwitch.isOn == true {
            sceneView2.isHidden = true
        }
    }
    
    fileprivate func setupScene() {
        sceneView.delegate = self
        sceneView.session = session
        session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @IBAction func switchVR(_ sender: Any) {
        if isVRSwitch.isOn == true {
            sceneView2.isHidden = true
            galleryButton.isHidden = false
        } else {
            sceneView2.isHidden = false
            galleryButton.isHidden = true
        }
    }
    
    @IBAction func switchPlaneType(_ sender: Any) {
        
        nodeWeCanChange = nil
        
        if isVerticalPlane.isOn == true {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .vertical
            sceneView.session.run(configuration)
        } else {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            sceneView.session.run(configuration)
        }
    }
    
    @IBAction func selectPaintPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let subscriptionyVC = storyboard.instantiateViewController(withIdentifier: "SketchListViewController") as! SketchListViewController
        subscriptionyVC.modalPresentationStyle = .overCurrentContext
        subscriptionyVC.viewController = self
        DispatchQueue.main.async {
            self.present(subscriptionyVC, animated: true, completion: nil)
        }
    }
    
    func selectImage(imageName: String) {
        nodeWeCanChange?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)?.image(alpha: 0.5)
    }
    
    @objc
    func didTap(_ gesture: UIPanGestureRecognizer) {
        guard let _ = nodeWeCanChange else { return }
        
        let tapLocation = gesture.location(in: sceneView)
        let results = sceneView.hitTest(tapLocation, types: .featurePoint)
        
        if let result = results.first {
            let translation = result.worldTransform.translation
            nodeWeCanChange?.position = SCNVector3Make(translation.x, translation.y, translation.z)
            //sceneView.scene.rootNode.addChildNode(object)
        }
    }
    
    @objc
    func didPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        switch gesture.state {
        case .began:
            // Choose the node to move
            print("")
            
        case .changed:
            // Move the node based on the real world translation
            guard let result = sceneView.hitTest(location, types: .existingPlaneUsingExtent).first else { return }
            
            let transform = result.worldTransform
            let newPosition = float3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            nodeWeCanChange?.simdPosition = newPosition
        default:
            // Remove the reference to the node
            print("")
        }
    }
    
    @objc private func viewRotated(_ gesture: UIRotationGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        guard let node = nodeWeCanChange else { return }
        
        switch gesture.state {
        case .began:
            originalRotation = node.eulerAngles
        case .changed:
            guard var originalRotation = originalRotation else { return }
            originalRotation.y -= Float(gesture.rotation)
            node.eulerAngles = originalRotation
        default:
            originalRotation = nil
        }
    }
    
    @objc
    func didPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let _ = nodeWeCanChange else { return }
        var originalScale = nodeWeCanChange?.scale
        
        switch gesture.state {
        case .began:
            originalScale = nodeWeCanChange?.scale
            gesture.scale = CGFloat((nodeWeCanChange?.scale.x)!)
        case .changed:
            guard var newScale = originalScale else { return }
            if gesture.scale < 0.5{ newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5) }else if gesture.scale > 2{
                newScale = SCNVector3(2, 2, 2)
            }else{
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            nodeWeCanChange?.scale = newScale
        case .ended:
            guard var newScale = originalScale else { return }
            if gesture.scale < 0.5{ newScale = SCNVector3(x: 0.5, y: 0.5, z: 0.5) }else if gesture.scale > 2{
                newScale = SCNVector3(2, 2, 2)
            }else{
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            nodeWeCanChange?.scale = newScale
            gesture.scale = CGFloat((nodeWeCanChange?.scale.x)!)
        default:
            gesture.scale = 1.0
            originalScale = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if nodeWeCanChange == nil{
            
            //a. Check We Have Detected An ARPlaneAnchor
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            //b. Get The Size Of The ARPlaneAnchor
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            
            //c. Create An SCNPlane Which Matches The Size Of The ARPlaneAnchor
            nodeWeCanChange = SCNNode(geometry: SCNPlane(width: width, height: height))
            
            //d. Rotate It
            nodeWeCanChange?.eulerAngles.x = -.pi/2
            
            
            
            //e. Set It's Colour To Red
            //nodeWeCanChange?.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            nodeWeCanChange?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "guse")?.image(alpha: 0.5)
            
            
            //f. Add It To Our Node & Thus The Hiearchy
            node.addChildNode(nodeWeCanChange!)
            
            //VirtualObject(anchor)
            
            
            
//            virtualObjectInteraction.translate(virtualObject, basedOn: screenCenter, infinitePlane: false, allowAnimation: false)
//            virtualObjectInteraction.selectedObject = virtualObject
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            self.updateFrame()
        }
        
    }
    
    func updateFrame() {
        
        // Clone pointOfView for Second View
        let pointOfView : SCNNode = (sceneView.pointOfView?.clone())!
        
        // Determine Adjusted Position for Right Eye
        let orientation : SCNQuaternion = pointOfView.orientation
        let orientationQuaternion : GLKQuaternion = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)
        let eyePos : GLKVector3 = GLKVector3Make(1.0, 0.0, 0.0)
        let rotatedEyePos : GLKVector3 = GLKQuaternionRotateVector3(orientationQuaternion, eyePos)
        let rotatedEyePosSCNV : SCNVector3 = SCNVector3Make(rotatedEyePos.x, rotatedEyePos.y, rotatedEyePos.z)
        
        let mag : Float = 0.066 // This is the value for the distance between two pupils (in metres). The Interpupilary Distance (IPD).
        pointOfView.position.x += rotatedEyePosSCNV.x * mag
        pointOfView.position.y += rotatedEyePosSCNV.y * mag
        pointOfView.position.z += rotatedEyePosSCNV.z * mag
        
        // Set PointOfView for SecondView
        sceneView2.pointOfView = pointOfView
        
    }
}

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

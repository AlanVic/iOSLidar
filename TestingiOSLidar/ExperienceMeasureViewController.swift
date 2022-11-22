//
//  ExperienceMeasureViewController.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 22/11/22.
//

import Foundation
import ARKit
import RealityKit

class ExperienceMeasureViewController: UIViewController, ARSessionDelegate {
    @IBOutlet weak var augmentedView: ARView!
    
    lazy var circleView: UIView = {
        let circleView = UIView(frame: CGRect(x:-10, y: -10, width: 10, height: 10))
        circleView.layer.cornerRadius = circleView.frame.width / 2
        circleView.backgroundColor = .red
        return circleView
    }()
    
    override func viewDidLoad() {
        augmentedView.addSubview(circleView)
    }
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        print("did tap view", sender)
        let location = sender.location(in: augmentedView)
        print("the location is: ", location)
        print("the transformation is: " , convertCGPointToLidarRelation(location: location))
        addACircleToView(onLocation: location)
    }
    
    func setupARConfiguration() -> ARConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics = .sceneDepth
        }
        
        return configuration
    }
    
    func convertCGPointToLidarRelation(location: CGPoint) -> CGPoint {
        let x = location.x * 192 / augmentedView.frame.width
        let y = location.y * 256 / augmentedView.frame.height
        return CGPoint(x: x, y: y)
    }
    
    func addACircleToView(onLocation location: CGPoint) {
        circleView.layer.position = location
        augmentedView.layoutSubviews()
    }
}

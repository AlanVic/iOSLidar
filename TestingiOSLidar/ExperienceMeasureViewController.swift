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
    
    @IBOutlet weak var resultLabel: UILabel!
    
    lazy var circleView: UIView = {
        let circleView = UIView(frame: CGRect(x:-10, y: -10, width: 10, height: 10))
        circleView.layer.cornerRadius = circleView.frame.width / 2
        circleView.backgroundColor = .red
        return circleView
    }()
    
    var session: ARSession!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        augmentedView.addSubview(circleView)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] _ in
            self?.getDataLidar()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = setupARConfiguration()
        session.run(configuration)
        
        augmentedView.session = session
        
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
    
    func getDataLidar() {
        if let currentFrame = session.currentFrame {
            let depthData = currentFrame.sceneDepth?.depthMap
            
            if let depth = depthData {
                let depthWidth = CVPixelBufferGetWidth(depth)
                print("DepthWidth: ", depthWidth)
                let depthHeight = CVPixelBufferGetHeight(depth)
                print("DepthHeight: " , depthHeight)
                CVPixelBufferLockBaseAddress(depth, CVPixelBufferLockFlags(rawValue: 0))
                let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depth),
                                                to: UnsafeMutablePointer<Float32>.self)
                var depthArray = [[Float32]]()
                for y in 0...depthHeight-1 {
                    var distancesLine = [Float32]()
                    for x in 0...depthWidth-1 {
                        let distanceAtXYPoint = floatBuffer[y * depthWidth + x]
                        distancesLine.append(distanceAtXYPoint)
//                        print("Depth in (\(x),\(y)): \(distanceAtXYPoint)")
                    }
                    depthArray.append(distancesLine)
                }
                let locationCircle = circleView.layer.position
                let distance = depthArray[Int(locationCircle.y)][Int(locationCircle.x)]
                print("O ponto tem a distancia: ", distance)
                resultLabel.text = "Distância medida: \(distance)"
                
            }
            
            func getStringFrom2DimArray(array: [[Float32]], height: Int, width: Int) -> String {
                var arrayStr: String = ""
                for y in 1...height-1 {
                    var lineStr = "";
                    for x in 1...width-1 {
                        lineStr += String(array[y][x])
                        if x != width-1 {
                            lineStr += ","
                        }
                    }
                    lineStr += "\n"
                    arrayStr += lineStr
                }
                return arrayStr
            }
        }
    }
}

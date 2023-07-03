//
//  ExperienceMeasureViewController.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 22/11/22.
//

import Foundation
import ARKit
import RealityKit

class ExperienceViewController: UIViewController, ARSessionDelegate {
    @IBOutlet weak var sliderTarget: UISlider!
    @IBOutlet weak var augmentedView: ARView!
    @IBOutlet weak var relativeAngleResult: UILabel!
    @IBOutlet weak var distanceResult: UILabel!
    @IBOutlet weak var representationLidarImage: UIImageView!
    
    private let axisWidthAngle: CGFloat = 81.273
    private let axisHeightAngle: CGFloat = 57.874
    
    lazy var circleView: TargetView = {
        let circleView = TargetView()
        return circleView
    }()
    
    var session: ARSession!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderTarget.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))

        augmentedView.addSubview(circleView)
        
        augmentedView.session.delegate = self
        
        session = ARSession()
        session.delegate = self
        
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
    
    func removingView() {
        self.augmentedView?.session.pause()            // there's no session on macOS
        self.augmentedView?.session.delegate = nil     // there's no session on macOS
        self.augmentedView?.scene.anchors.removeAll()
        self.augmentedView?.removeFromSuperview()
        self.augmentedView?.window?.resignKey()
        self.augmentedView = nil
    }
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
//        print("did tap view", sender)
        let location = sender.location(in: augmentedView)
//        print("the location is: ", location)
//        print("the transformation is: " , convertCGPointToLidarRelation(location: location))
        addACircleToView(onLocation: location)
    }
    @IBAction func sliderActionTarget(_ sender: UISlider) {
        circleView.setSizeTarget(CGFloat(30*sender.value))
        print(sender.value)
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
//        circleView.layoutSubviews()
        //augmentedView.layoutSubviews()
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
                
                //Distancia do ponto marcado
                let locationCircle = circleView.layer.position
                let relationPosition = convertCGPointToLidarRelation(location: locationCircle)
                let distance = depthArray[Int(relationPosition.x)][Int(relationPosition.y)]
                distanceResult.text = "\(distance)m"
                
                //Angulo relativo
                let angleCenterPoint = CGPoint(x: axisWidthAngle/2, y: axisHeightAngle/2)
                let angleRelationPoint = CGPoint(x: (axisWidthAngle * relationPosition.x) / CGFloat(depthWidth),
                                                    y: (axisHeightAngle * relationPosition.y) / CGFloat(depthHeight))
                let distanceAngle = sqrt(pow(angleCenterPoint.x - angleRelationPoint.x,2) + pow(angleCenterPoint.y - angleRelationPoint.y,2))
                relativeAngleResult.text = "\(distanceAngle)º"
                
                let depthSize = CGSize(width: depthWidth, height: depthHeight)
                let ciImage = CIImage(cvPixelBuffer: depth)
                let context = CIContext.init(options: nil)
                guard let cgImageRef = context.createCGImage(ciImage, from:
                                                                CGRect(x: 0, y: 0, width: depthSize.width, height: depthSize.height)) else { return }
                let uiImage = UIImage(cgImage: cgImageRef)
                representationLidarImage.image = uiImage
                representationLidarImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                
                
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

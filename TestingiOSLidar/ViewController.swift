//
//  ViewController.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 16/09/22.
//

//import UIKit
import ARKit
import RealityKit

class ViewController: UIViewController, ARSessionDelegate {

    var session: ARSession!
    
    var frames: [ARFrame] = [] {
        didSet {
            obsevableFrameLabel(frames.count)
        }
    }
    
    @IBOutlet weak var augmentedView: ARView!
    @IBOutlet weak var saveFramesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearTempFolder()
        
        augmentedView.session.delegate = self
        
        session = ARSession()
        session.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = setupARConfiguration()
        session.run(configuration)
        
        augmentedView.session = session
    }
    
    func setupARConfiguration() -> ARConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics = .sceneDepth
        }
        
        return configuration
    }
    
    func obsevableFrameLabel(_ framesCount: Int) {
        saveFramesLabel.text = "Frames salvos: \(framesCount)"
    }
    
    @IBAction func didTapSaveFrame(_ sender: Any) {
        if let currentFrame = session.currentFrame {
            let frameImage = currentFrame.capturedImage
            frames.append(currentFrame)
            let depthData = currentFrame.sceneDepth?.depthMap

            // Process obtained data
            // Prepare RGB image to save
            let imageSize = CGSize(width: CVPixelBufferGetWidth(frameImage),
                                   height: CVPixelBufferGetHeight(frameImage))
            let ciImage = CIImage(cvPixelBuffer: frameImage)
            let context = CIContext.init(options: nil)
            
            guard let cgImageRef = context.createCGImage(ciImage, from:
                                                            CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)) else { return }
            let uiImage = UIImage(cgImage: cgImageRef)
            
            // Save image
            try! saveImage(uiImage, folder: getTempFolder(), frameCount: frames.count, extensionPathComponents: nil)
            
            // Prepare normalized grayscale image with DepthMap
            if let depth = depthData {
                let depthWidth = CVPixelBufferGetWidth(depth)
                let depthHeight = CVPixelBufferGetHeight(depth)
                CVPixelBufferLockBaseAddress(depth, CVPixelBufferLockFlags(rawValue: 0))
                let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depth),
                                                to: UnsafeMutablePointer<Float32>.self)
                var depthArray = [[Float32]]()
                for y in 0...depthHeight-1 {
                    var distancesLine = [Float32]()
                    for x in 0...depthWidth-1 {
                        let distanceAtXYPoint = floatBuffer[y * depthWidth + x]
                        distancesLine.append(distanceAtXYPoint)
                        print("Depth in (\(x),\(y)): \(distanceAtXYPoint)")
                    }
                    depthArray.append(distancesLine)
                }
                
                let depthSize = CGSize(width: depthWidth, height: depthHeight)
                
                let ciImage = CIImage(cvPixelBuffer: depth)
                let context = CIContext.init(options: nil)
                guard let cgImageRef = context.createCGImage(ciImage, from:
                                                                CGRect(x: 0, y: 0, width: depthSize.width, height: depthSize.height)) else { return }
                let uiImage = UIImage(cgImage: cgImageRef)
                
                // Save image (the same for depth)
                try! saveImage(uiImage, folder: getTempFolder(), frameCount: frames.count, extensionPathComponents: "ImageDepth")
                
                
                // Save depth map as txt with float numbers
                let depthTxtPath = try! getTempFolder().appendingPathComponent("\(frames.count)_depth.txt")
                let depthString:String = getStringFrom2DimArray(array: depthArray, height: depthHeight, width: depthWidth)
                try! depthString.write(to: depthTxtPath, atomically: false, encoding: .utf8)
                
                // Auxiliary function to make String from depth map array
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
        } else {
            print ("Não conseguiu o frame")
        }
    }
    
    func getTempFolder() throws -> URL {
        let path = try FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: true).appendingPathComponent("tmp", isDirectory: true)
        
        if (!FileManager.default.fileExists(atPath: path.path)) {
            do {
                try FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        return path
    }
    
    func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = try! getTempFolder().path
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempFolderPath + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func saveImage(_ image: UIImage, folder: URL, frameCount: Int, extensionPathComponents: String?) throws {
        let imagePath: URL
        if let extensionPath = extensionPathComponents {
            imagePath = folder.appendingPathComponent("\(frameCount)_\(extensionPath).jpg")
        } else {
            imagePath = folder.appendingPathComponent("\(frameCount).jpg")
        }
        try image.jpegData(compressionQuality: 1.0)?.write(to: imagePath)
    }
}

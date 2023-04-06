//
//  ViewController.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 16/09/22.
//

//import UIKit
import ARKit
import RealityKit
import Zip
import CoreMotion

class ViewController: UIViewController, ARSessionDelegate {

    var session: ARSession!
    
    var framesCount: Int = 0 {
        didSet {
            obsevableFrameLabel(framesCount)
        }
    }
    
    @IBOutlet weak var xDegreeMeasured: UILabel!
    @IBOutlet weak var yDegreeMeasured: UILabel!
    @IBOutlet weak var zDegreeMeasured: UILabel!
    @IBOutlet weak var augmentedView: ARView!
    @IBOutlet weak var saveFramesLabel: UILabel!

    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearTempFolder()
        
        augmentedView.session.delegate = self
        
        session = ARSession()
        session.delegate = self

        motionManager.startGyroUpdates()
        motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in

            if let data = self.motionManager.deviceMotion {

                let pitch = data.attitude.pitch
                let roll = data.attitude.roll
                let yaw = data.attitude.yaw


                var xDegree = acos(data.gravity.x/1) * 180 / .pi
                var yDegree = acos(data.gravity.y/1) * 180 / .pi
                var zDegree = acos(data.gravity.z/1) * 180 / .pi
                print("--------------------------")
                print("x:" + "\(data.gravity.x)")
                print("y:" + "\(data.gravity.y)")
                print("z:" + "\(data.gravity.z)")
                if (data.gravity.y > 0) {
                    xDegree = 180 + (180 - xDegree)
                }
                if (data.gravity.z > 0) {
                    yDegree = 180 + (180 - yDegree)
                }
                if (data.gravity.x > 0) {
                    zDegree = 180 + (180 - zDegree)
                }

                self.xDegreeMeasured.text = "x: " + "\(xDegree)º"
                self.yDegreeMeasured.text = "y: " + "\(yDegree)º"
                self.zDegreeMeasured.text = "z: " + "\(zDegree)º"

            }
        }
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
            framesCount += 1
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
            try! saveImage(uiImage, folder: getTempFolder(), frameCount: framesCount, extensionPathComponents: nil)
            
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
                
                // Create CI image normalized grayscale
                let ciImage = CIImage(cvPixelBuffer: depth)
                let context = CIContext.init(options: nil)
                guard let cgImageRef = context.createCGImage(ciImage, from:
                                                                CGRect(x: 0, y: 0, width: depthSize.width, height: depthSize.height)) else { return }
                let uiImage = UIImage(cgImage: cgImageRef)
                
                // Save image (the same for depth)
                try! saveImage(uiImage, folder: getTempFolder(), frameCount: framesCount, extensionPathComponents: "ImageDepth")
                
                
                // Save depth map as txt with float numbers
                let depthTxtPath = try! getTempFolder().appendingPathComponent("\(framesCount)_depth.txt")
                let depthString:String = getStringFrom2DimArray(array: depthArray, height: depthHeight, width: depthWidth)
                try! depthString.write(to: depthTxtPath, atomically: false, encoding: .utf8)
                
                // Auxiliary function to make String from depth map array
                func getStringFrom2DimArray(array: [[Float32]], height: Int, width: Int) -> String {
                    var arrayStr: String = ""
                    //possivelmente o erro está aqui
                    for y in 0...height-1 {
                        var lineStr = "";
                        for x in 0...width-1 {
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
    
    @IBAction func exportPack(_ sender: Any) {
        do {
            let zipFilePath = try Zip.quickZipFiles(getAllFilePathsToExport(), fileName: "file")
            print(zipFilePath)
            var fileToShare = [Any]()
            fileToShare.append(zipFilePath)
            let activityViewController = UIActivityViewController(activityItems: fileToShare, applicationActivities: nil)
            self.present(activityViewController, animated: true)
        } catch {
            print("Something went wrong")
        }
    }

    func getAllFilePathsToExport() -> [URL] {
        var filePaths: [URL] = []
        do {
            let path = try getTempFolder()
            print(path)

            if let enumerator = FileManager.default.enumerator(at: path, includingPropertiesForKeys: nil) {
                for case let fileURL as URL in enumerator {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        filePaths.append(fileURL)
                    }
                }
            }
        } catch {
            print(error)
            return filePaths
        }
        return filePaths
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
                try fileManager.removeItem(atPath: tempFolderPath + "/" + filePath)
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

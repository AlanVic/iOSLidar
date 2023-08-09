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

struct AnglesMeasured {
    let xDegree: Double
    let yDegree: Double
    let zDegree: Double

    func toArray() -> Array<Double> {
        return [xDegree,yDegree,zDegree]
    }
}

class SaveFrameViewController: UIViewController, ARSessionDelegate {
    
    var session: ARSession!
    
    var orientationLast = UIInterfaceOrientation.portrait {
        willSet {
            rotateShareButton(lastOrientation: orientationLast, newOrientation: newValue)
        }
    }
    
    func rotateShareButton(lastOrientation: UIInterfaceOrientation, newOrientation: UIInterfaceOrientation ) {
        var angleRotate:CGFloat = .zero
        if(lastOrientation == .landscapeLeft && newOrientation == .portrait
           || lastOrientation == .portrait && newOrientation == .landscapeRight
           || lastOrientation == .landscapeRight && newOrientation == .portraitUpsideDown) {
            angleRotate = -.pi/2
        } else if(lastOrientation == .landscapeRight && newOrientation == .portrait
                  || lastOrientation == .portrait && newOrientation == .landscapeLeft
                  || lastOrientation == .landscapeLeft && newOrientation == .portraitUpsideDown) {
            angleRotate = .pi/2
        } else if(lastOrientation == .portraitUpsideDown && newOrientation == .portrait
                  || lastOrientation == .portrait && newOrientation == .portraitUpsideDown
                  || lastOrientation == .landscapeLeft && newOrientation == .landscapeRight
                  || lastOrientation == .landscapeRight && newOrientation == .landscapeLeft) {
            angleRotate = .pi
        }
        
        
        UIView.animate(withDuration: 0.2, animations: ( {
            self.shareButton.transform = CGAffineTransformRotate(self.shareButton.transform, angleRotate)
        }))
    }
    
    var framesCount: Int = 0 {
        didSet {
            obsevableFrameLabel(framesCount)
        }
    }
    
    @IBOutlet weak var augmentedView: ARView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveFramesLabel: UILabel!
    
    var motionManager: CMMotionManager?
    
    deinit {
        removingView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium, scale: .large)
        let largeBoldDoc = UIImage(systemName: "square.and.arrow.up.circle", withConfiguration: largeConfig)
        
        
        shareButton.setImage(largeBoldDoc, for: .normal)
        
        
        clearTempFolder()
        //        UIButton().imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        
        augmentedView.session.delegate = self
        
        session = ARSession()
        session.delegate = self
        
        initializeMotionManager()
    }
    
    private func initializeMotionManager() {
        motionManager = CMMotionManager()
        motionManager?.accelerometerUpdateInterval = 0.2
        motionManager?.gyroUpdateInterval = 0.2
        motionManager?.deviceMotionUpdateInterval = 0.2
        motionManager?.startAccelerometerUpdates(to: (OperationQueue.current)!, withHandler: {
            [weak self] (accelerometerData, error) -> Void in
            if error == nil {
                self?.outputAccelerationData((accelerometerData?.acceleration)!)
            } else {
                print("\(error!)")
            }
        })
    }
    
    private func outputAccelerationData(_ acceleration: CMAcceleration) {
        var orientationNew: UIInterfaceOrientation
        if acceleration.x >= 0.75 {
            orientationNew = .landscapeRight
            print("landscapeRight")
        }
        else if acceleration.x <= -0.75 {
            orientationNew = .landscapeLeft
            print("landscapeLeft")
        }
        else if acceleration.y <= -0.75 {
            orientationNew = .portrait
            print("portrait")
            
        }
        else if acceleration.y >= 0.75 {
            orientationNew = .portraitUpsideDown
            print("portraitUpsideDown")
        }
        else {
            // Consider same as last time
            return
        }
        
        if orientationNew == orientationLast {
            return
        }
        orientationLast = orientationNew
    }
    
    
    private func measureAngles(fromDataAcceleration acceleration: CMAcceleration) -> AnglesMeasured {
        var xDegree = acos(acceleration.x/1) * 180 / .pi
        var yDegree = acos(acceleration.y/1) * 180 / .pi
        var zDegree = acos(acceleration.z/1) * 180 / .pi
        
        //        print("--------------------------")
        //        print("x:" + "\(acceleration.x)")
        //        print("y:" + "\(acceleration.y)")
        //        print("z:" + "\(acceleration.z)")
        if (acceleration.y > 0) {
            xDegree = 180 + (180 - xDegree)
        }
        if (acceleration.z > 0) {
            yDegree = 180 + (180 - yDegree)
        }
        if (acceleration.x > 0) {
            zDegree = 180 + (180 - zDegree)
        }
        
        return AnglesMeasured(xDegree: xDegree, yDegree: yDegree, zDegree: zDegree)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = setupARConfiguration()
        session.run(configuration)
        
        augmentedView.session = session
    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        timer?.invalidate()
    //    }
    
    func removingView() {
        self.augmentedView?.session.pause()            // there's no session on macOS
        self.augmentedView?.session.delegate = nil     // there's no session on macOS
        self.augmentedView?.scene.anchors.removeAll()
        self.augmentedView?.removeFromSuperview()
        self.augmentedView?.window?.resignKey()
        self.augmentedView = nil
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
        var jsonDict: Dictionary<String, Any> = Dictionary()
        if let currentFrame = session.currentFrame {
            let frameImage = currentFrame.capturedImage.rotateRelatively(withOrientation: orientationLast)
            framesCount += 1
            
            // Process obtained data
            // Prepare RGB image to save
            let ciImage = CIImage(cvPixelBuffer: frameImage)
            
            let uiImage = UIImage(ciImage: ciImage)
            
            // Save image
            try! saveImage(uiImage, folder: getTempFolder(), frameCount: framesCount, extensionPathComponents: nil)
            
            //Measure relative angle from three axis
            if let data = self.motionManager?.deviceMotion {
                let measuredAngles = measureAngles(fromDataAcceleration:data.gravity)
                jsonDict["RelativeAngles"] = measuredAngles.toArray()
            }
            
            // Prepare normalized grayscale image with DepthMap
            if let depth = currentFrame.sceneDepth?.depthMap {
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
                
                let saveDepthArray = rotate(matrix: depthArray, withOrientation: orientationLast)
                
                // Create CI image normalized grayscale
                let ciImage = CIImage(cvPixelBuffer: depth.rotateRelatively(withOrientation: orientationLast))
                let uiImage = UIImage(ciImage: ciImage)
                
                // Save image (the same for depth)
                try! saveImage(uiImage, folder: getTempFolder(), frameCount: framesCount, extensionPathComponents: "ImageDepth")
                
                
                // Save depth map as txt with float numbers
                let depthTxtPath = try! getTempFolder().appendingPathComponent("\(framesCount)_depth.txt")
                let depthString:String = getStringFrom2DimArray(array: saveDepthArray, height: depthHeight, width: depthWidth)
                try! depthString.write(to: depthTxtPath, atomically: false, encoding: .utf8)
                
                //Add LIDAR data to Json
                jsonDict["LIDARData"] = saveDepthArray
                
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
        if let json = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted]) {
            let jsonPath = try! getTempFolder().appendingPathComponent("\(framesCount).json")
            try! json.write(to: jsonPath)
            
            if let jsonString = String(data: json, encoding: .utf8) {
                print(jsonString)
            }
        }
    }
    
    func nameFile() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              let hour = components.hour,
              let minutes = components.minute,
              let seconds = components.second else {
            return "file"
        }
        return String(format: "%04d-%02d-%02d_%02d-%02d-%02d", year,month,day,hour,minutes,seconds)
    }
    
    @IBAction func exportPack(_ sender: Any) {
        do {
            let zipFilePath = try Zip.quickZipFiles(getAllFilePathsToExport(), fileName: nameFile())
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
    
    func rotate(matrix: [[Float32]],
                withOrientation orientation: UIInterfaceOrientation) -> Array<Array<Float32>> {
        
        switch orientation {
        case .portrait:
            return matrix.reversed().transposed()
        case .landscapeRight:
            return matrix.reversed()
        default:
            return matrix
        }
    }

    func randomFloat() -> Float32 {
        Float32([1.223,3.222,6.234,6.6254,3.567].randomElement() ?? 8.345)
    }
}

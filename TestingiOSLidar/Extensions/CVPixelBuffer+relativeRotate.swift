//
//  CVPixelBuffer+relativeRotate.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 27/06/23.
//

import UIKit

extension CVPixelBuffer {
    func rotateRelatively() -> CVPixelBuffer {

        var newPixelBuffer: CVPixelBuffer?
        let size = relativeCGSize()
        let error = CVPixelBufferCreate(kCFAllocatorDefault,
                                        Int(size.width),
                                        Int(size.height),
                                        kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                                        nil,
                                        &newPixelBuffer)
        guard error == kCVReturnSuccess else {
            return self
        }
        let ciImage: CIImage
        if let orientation = analiseOrientation() {
            ciImage = CIImage(cvPixelBuffer: self).oriented(orientation)
        } else {
            ciImage = CIImage(cvPixelBuffer: self)
        }
        let context = CIContext(options: nil)
        context.render(ciImage, to: newPixelBuffer!)
        return newPixelBuffer!
    }

    private func relativeCGSize() -> CGSize {
        let tempCGSize = CGSize(width: CVPixelBufferGetWidth(self), height: CVPixelBufferGetHeight(self))
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown:
            return CGSize(width: tempCGSize.height, height: tempCGSize.width)
        default:
            return tempCGSize
        }
    }

    private func analiseOrientation() -> CGImagePropertyOrientation? {
        switch UIDevice.current.orientation {
        case .portrait:
            return .right
        case .landscapeRight:
            return .down
        default:
            return nil
        }
    }
}

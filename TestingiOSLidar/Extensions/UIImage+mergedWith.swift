//
//  UIImage+mergedWith.swift
//  TestingiOSLidar
//
//  Created by Alan Paulino on 04/07/23.
//

import UIKit

extension UIImage {
    func mergeWith(viewToRender view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let topImage = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        let bottomImage = self
        
        UIGraphicsBeginImageContext(size)
        
        
        let areaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height)
        bottomImage.draw(in: areaSize)
        
        topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return mergedImage
    }
}

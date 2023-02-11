//
//  Compress.swift
//  TrollBoard
//
//  Created by Анохин Юрий on 05.02.2023.
//
// Licensed under GPLv3
// also thanks to chatgpt

import UIKit

// compresssssssss
extension UIImage {
    func resizeToApprox(allowedSizeInBytes: Int) throws -> Data {

        var left:CGFloat = 0.0, right: CGFloat = 1.0
        var mid = (left + right) / 2.0
        
        var closestImage: Data?
        guard var newResImage = self.jpegData(compressionQuality: mid) else { throw NSError(domain: "UIImage", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not compress image"]) }

        for i in 0...13 {
            print("mid = \(mid), i = \(i), closestImage->count = \(closestImage?.count ?? 0), newResImage->count = \(newResImage.count)")
            
            if abs(newResImage.count - allowedSizeInBytes) <= 100 {
                // If the difference is within 100 bytes, return the current compression
                return newResImage
            }
            
            if newResImage.count < allowedSizeInBytes {
                left = mid
            } else if newResImage.count > allowedSizeInBytes {
                right = mid
            }
            
            mid = (left + right) / 2.0
            guard let newData = self.jpegData(compressionQuality: mid) else { throw NSError(domain: "UIImage", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not compress image"]) }
            if newData.count < allowedSizeInBytes {
                closestImage = newData
            }
            newResImage = newData
        }
        guard closestImage != nil else { throw NSError(domain: "UIImage", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not compress image low enough to fit inside original \(allowedSizeInBytes) bytes"]) }
        return closestImage!
    }
}

// resize image function, we need it so we can compress the image itself
func resizeAndSaveImage(imageData: Data, path: String) throws {
    let image = UIImage(data: imageData)
    let targetSize = CGSize(width: 120, height: 120)
    
    let size = image?.size
    let widthRatio  = targetSize.width  / (size?.width ?? 1)
    let heightRatio = targetSize.height / (size?.height ?? 1)
    let newSize = widthRatio > heightRatio ?  CGSize(width: (size?.width ?? 1) * heightRatio, height: (size?.height ?? 1) * heightRatio) : CGSize(width: (size?.width ?? 1) * widthRatio,  height: (size?.height ?? 1) * widthRatio)
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image?.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if let resizedImageData = newImage?.jpegData(compressionQuality: 0.75) {
        try resizedImageData.write(to: URL(fileURLWithPath: path))
    } else {
        throw NSError(domain: "Error", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to resize image"])
    }
}

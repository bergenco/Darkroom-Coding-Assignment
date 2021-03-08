//
//  ThumbnailScaleConverter.swift
//  PixelRoom
//
//  Created by Ross Kimes on 3/7/21.
//

import UIKit

class ThumbnailScaleConverter {
    private let context = CIContext()
    private let internalFilter = CIFilter(name: "CILanczosScaleTransform")
    
    func thumbnail(fromImage image: UIImage) -> UIImage? {
        
        guard let inputCGImage = image.cgImage,
              let filter = internalFilter else {
            return nil
        }
        let inputImage = CIImage(cgImage: inputCGImage)
        
        let targetSize = 150 * UIScreen.main.scale
        let scale = max(targetSize / inputImage.extent.height, targetSize / inputImage.extent.width)
        let aspectRatio = inputImage.extent.width / inputImage.extent.height
        
        filter.setValue(inputImage, forKey: "inputImage")
        filter.setValue(NSNumber(value: Float(scale)), forKey: "inputScale")
        filter.setValue(NSNumber(value: Float(aspectRatio)), forKey: "inputAspectRatio")
        
        let scaledExtent = CGRect(x: 0, y: 0, width: inputImage.extent.width * scale, height: inputImage.extent.height * scale)
        guard let outputImage = filter.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: scaledExtent)
        else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
}

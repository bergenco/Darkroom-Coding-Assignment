//
//  PixellateFilter.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

class PixellateFilter {
    
    static let minInputScale: Float = 1.0
    
    private let context = CIContext()
    private let internalFilter = CIFilter(name: "CIPixellate")

    func pixelate(image: UIImage, inputScale: Float) -> UIImage? {
        guard let inputCGImage = image.cgImage,
              let filter = internalFilter else {
            return nil
        }
        let inputImage = CIImage(cgImage: inputCGImage)
        let center = CGPoint(x: inputImage.extent.width / 2, y: inputImage.extent.height / 2)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(NSNumber(value: inputScale), forKey: "inputScale")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let insetX = abs(outputImage.extent.minX)
        let insetY = abs(outputImage.extent.minY)
        
        guard let outputCGImage = context.createCGImage(outputImage, from: inputImage.extent.insetBy(dx: insetX, dy: insetY)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
}

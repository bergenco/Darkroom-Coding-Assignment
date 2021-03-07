//
//  PixellateFilter.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

class PixellateFilter {
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
        
        // CIPixellate's inputScale only works for values >= 1.
        let validatedScale = max(inputScale, 1)
        filter.setValue(NSNumber(value: validatedScale), forKey: "inputScale")
        
        guard let outputImage = filter.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: inputImage.extent)
        else {
            return nil
        }
        return UIImage(cgImage: outputCGImage)
    }
}

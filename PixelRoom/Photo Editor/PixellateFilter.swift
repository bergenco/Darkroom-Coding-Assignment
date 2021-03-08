//
//  PixellateFilter.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

// Given time, I would create a `FilterProtocol` a `LanczosScaleTransform` and `Pixellate` struct could conform to.
// Those filter types would have values for all the parameters that were available for that filter.
// They could also perform input validation and provide the API to test against.
// The class below would be generic over `FilterProtocol` and would just handle holding the context and getting the CIFilter ready.
//
// Example code below that gives a rough idea. It would need to be fleshed out quite a bit to cover all use cases.
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

// MARK: - Example stub code, not used

protocol FilterProtocol {
    static var name: String { get }
    
    func configure(ciFilter: CIFilter)
}

struct PixellateFilterConfiguration: FilterProtocol {
    static let name = "CIPixellate"
    
    var scale: Float = 0
    
    func configure(ciFilter: CIFilter) {
        let validatedScale = max(1, scale)
        ciFilter.setValue(NSNumber(value: validatedScale), forKey: "inputScale")
    }
}

class FilterClass<Filter: FilterProtocol> {
    
    private let context = CIContext()
    private let internalFilter: CIFilter?
    
    init(filter: Filter) {
        internalFilter = CIFilter(name: Filter.name)
    }
    
    func run(filter: Filter, image: UIImage) -> UIImage? {
        guard let inputCGImage = image.cgImage,
              let internalFilter = internalFilter else {
            return nil
        }
        
        let inputImage = CIImage(cgImage: inputCGImage)
        
        filter.configure(ciFilter: internalFilter)
        
        guard let outputImage = internalFilter.outputImage,
              let outputCGImage = context.createCGImage(outputImage, from: inputImage.extent)
        else {
            return nil
        }
        return UIImage(cgImage: outputCGImage)
    }
}

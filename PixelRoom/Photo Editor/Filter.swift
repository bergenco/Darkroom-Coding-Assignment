//
//  Filter.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

class Filter {
    enum FilterType: Int, Codable {
        case pixellate
        case hexagonalPixellate
        case pointillize
    }
    
    private let context = CIContext()
    private let filters: [FilterType: CIFilter?] = [
        .pixellate: CIFilter(name: "CIPixellate"),
        .hexagonalPixellate: CIFilter(name: "CIHexagonalPixellate"),
        .pointillize: CIFilter(name: "CIPointillize")
    ]
    
    func apply(_ filterType: FilterType, to image: UIImage, inputScale: Float) -> UIImage? {
        guard let inputCGImage = image.cgImage,
              let filter = filters[filterType] ?? nil else {
            return nil
        }
        
        guard inputScale >= 1 else { return image }
        
        let inputImage = CIImage(cgImage: inputCGImage)
        let center = CGPoint(x: inputImage.extent.width / 2, y: inputImage.extent.height / 2)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgPoint: center), forKey: "inputCenter")
        filter.setValue(
            NSNumber(value: inputScale),
            forKey: filterType == .pointillize ? "inputRadius" : "inputScale"
        )
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let inset = CGPoint(x: abs(outputImage.extent.minX), y: abs(outputImage.extent.minY))
        
        guard let outputCGImage = context.createCGImage(
                outputImage,
                from: inputImage.extent.insetBy(dx: inset.x, dy: inset.y)
        ) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
}

//
//  Filter.swift
//  PixelRoom
//
//  Created by Jean-Baptiste Castro on 28/04/2021.
//

import UIKit


class Filter {
    
    // MARK: Effect
    
    enum Effect: Int, Codable {
        
        case pixellate
        case hexagonalPixellate
        case pointillize
        
        var name: String {
            switch self {
            case .pixellate: return "Pixellate"
            case .hexagonalPixellate: return "Hexagonal"
            case .pointillize: return "Pointillize"
            }
        }
        
        var minValue: Float {
            switch self {
            case .pixellate: return 1.0
            case .hexagonalPixellate: return 1.0
            case .pointillize: return 1.0
            }
        }
    }
    
    // MARK: Properties
    
    private let context = CIContext()
    
    private lazy var pixellateFilter = CIFilter(name: "CIPixellate")
    private lazy var hexagonalPixellateFilter = CIFilter(name: "CIHexagonalPixellate")
    private lazy var pointillizeFilter = CIFilter(name: "CIPointillize")
    
    // MARK: Process
    
    func perform(_ effect: Effect,
                 on image: UIImage,
                 with value: Float) -> UIImage? {
        
        guard let inputCGImage = image.cgImage else { return nil }
        
        let inputImage = CIImage(cgImage: inputCGImage)
        let center = CGPoint(x: inputImage.extent.width / 2, y: inputImage.extent.height / 2)
        
        var outputImage: CIImage?
        
        switch effect {
        case .pixellate: outputImage = outputPixellateFilter(input: inputImage, center: center, scale: value)
        case .hexagonalPixellate: outputImage = outputHexagonalPixellateFilter(input: inputImage, center: center, scale: value)
        case .pointillize: outputImage = outputPointillizeFilter(input: inputImage, center: center, radius: value)
        }
        
        guard let output = outputImage else { return nil }
        
        let insetX = abs(output.extent.minX)
        let insetY = abs(output.extent.minY)
        
        guard let outputCGImage = context.createCGImage(output, from: inputImage.extent.insetBy(dx: insetX, dy: insetY)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func outputPixellateFilter(input: CIImage,
                                       center: CGPoint,
                                       scale: Float) -> CIImage? {
        
        guard let filter = pixellateFilter else { return nil }
        
        filter.setValue(input, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
        filter.setValue(NSNumber(value: scale), forKey: kCIInputScaleKey)
        
        return filter.outputImage
    }
    
    private func outputHexagonalPixellateFilter(input: CIImage,
                                                center: CGPoint,
                                                scale: Float) -> CIImage? {
        
        guard let filter = hexagonalPixellateFilter else { return nil }
        
        filter.setValue(input, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
        filter.setValue(NSNumber(value: scale), forKey: kCIInputScaleKey)
        
        return filter.outputImage
    }
    
    private func outputPointillizeFilter(input: CIImage,
                                         center: CGPoint,
                                         radius: Float) -> CIImage? {
        
        guard let filter = pointillizeFilter else { return nil }
        
        filter.setValue(input, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgPoint: center), forKey: kCIInputCenterKey)
        filter.setValue(NSNumber(value: radius), forKey: kCIInputRadiusKey)
        
        return filter.outputImage
    }
}

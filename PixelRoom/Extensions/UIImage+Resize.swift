//
//  UIImage+Resize.swift
//  PixelRoom
//
//  Created by Jean-Baptiste Castro on 28/04/2021.
//

import UIKit


extension UIImage {
    
    static func resizedImage(from url: URL) -> UIImage? {
        
        guard let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        
        return image.resized()
    }
    
    func resized() -> UIImage {
        let maxSize = UIScreen.main.bounds.size
        
        let scale = max(maxSize.width / size.width, maxSize.height / size.height)
        let renderSize = CGSize(
            width: size.height * scale,
            height: size.height * scale
        )
        let renderer = UIGraphicsImageRenderer(size: renderSize)
        return renderer.image { (context) in
            draw(in: CGRect(origin: .zero, size: renderSize))
        }
    }
}

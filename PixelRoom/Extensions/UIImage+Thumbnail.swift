//
//  UIImage+Thumbnail.swift
//  PixelRoom
//
//  Created by Jean-Baptiste Castro on 28/04/2021.
//

import UIKit


extension UIImage {
    
    static func thumbnail(from imageData: Data) -> UIImage {
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 150 * UIScreen.main.scale
        ] as CFDictionary
        let source = CGImageSourceCreateWithData(imageData as NSData, nil)!
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
        let thumbnailImage = UIImage(cgImage: imageReference)
        return thumbnailImage
    }
}

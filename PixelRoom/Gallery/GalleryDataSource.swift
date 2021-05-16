//
//  GalleryDataSource.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

struct PhotoItem: Equatable {
    let name: String
    let thumbnail: UIImage
    let url: URL
}

enum GallerySectionStyle {
    case featured
    case normal
    case featuredFooter
}

class GalleryDataSource {

    private struct GallerySection {
        let style: GallerySectionStyle
        let items: [PhotoItem]
    }
    
    private enum Constants {
        static let bundledPhotoNameTag = "unsplash"
        static let supportedFileTypes = ["jpg", "jpeg", "png", "heic"]
        static let featuredCount: Int = 5
        static let featureFooterCount: Int = 6
    }
    
    private var featuredPhotos = GallerySection(style: .featured, items: [])
    private var featuredFooterPhotos = GallerySection(style: .featuredFooter, items: [])
    private var photos = GallerySection(style: .normal, items: [])
    
    private let pixellateFilter = PixellateFilter()
    
    private var allSections: [GallerySection] {
        return [featuredPhotos, featuredFooterPhotos, photos]
    }
    
    // MARK: - Public
    
    public func reloadPhotos(completion: @escaping ()->Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let edits = UserDefaults.standard.photoEdits()
            var allItems: [PhotoItem] = Constants.supportedFileTypes
                .flatMap { Bundle.main.paths(forResourcesOfType: $0, inDirectory: nil) }
                .compactMap {
                    let url = URL(fileURLWithPath: $0)
                    let name = url.deletingPathExtension().lastPathComponent
                    guard name.contains(Constants.bundledPhotoNameTag),
                          let data = try? Data(contentsOf: url) else {
                        return nil
                    }
                    let (thumbnail, thumbnailScale) = self.createThumbnail(from: data)
                    
                    if let edits = edits,
                       let thumbnailScale = thumbnailScale,
                       let scaleValue = edits[name] as? Float,
                       let pixellated = self.pixellateFilter.pixelate(
                        image: thumbnail,
                        inputScale: thumbnailScale * scaleValue
                       ) {
                        return PhotoItem(name: name, thumbnail: pixellated, url: url)
                    }
                    
                    return PhotoItem(name: name, thumbnail: thumbnail, url: url)
                }.shuffled()
            
            let featuredItems = allItems.prefix(Constants.featuredCount)
            allItems.removeFirst(featuredItems.count)
            
            let footerItems = allItems.prefix(Constants.featureFooterCount)
            allItems.removeFirst(footerItems.count)
            
            self.featuredPhotos = GallerySection(style: .featured, items: Array(featuredItems))
            self.photos = GallerySection(style: .normal, items: allItems)
            self.featuredFooterPhotos = GallerySection(style: .featuredFooter, items: Array(footerItems))
            DispatchQueue.main.async { completion() }
        }
    }

    public var numberOfSections: Int {
        return allSections.count
    }

    public func numberOfItemsInSection(_ section: Int) -> Int {
        return allSections[section].items.count
    }
    
    public func sectionStyleForSecton(_ section: Int) -> GallerySectionStyle {
        return allSections[section].style
    }
    
    public func item(at index:Int, inSection section: Int) -> PhotoItem {
        return allSections[section].items[index]
    }
    
}

// MARK: - Helpers

extension GalleryDataSource {
    private func createThumbnail(from imageData: Data) -> (thumbnail: UIImage, thumbnailScale: Float?) {
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 150 * UIScreen.main.scale
        ] as CFDictionary
        let source = CGImageSourceCreateWithData(imageData as NSData, nil)!
        
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
        let thumbnailImage = UIImage(cgImage: imageReference)
        
        if let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, [kCGImageSourceShouldCache: false] as CFDictionary) as? [CFString: Any],
           let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
           let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
            let thumbnailScale = min(
                Float((thumbnailImage.size.width * thumbnailImage.scale) / width),
                Float((thumbnailImage.size.height * thumbnailImage.scale) / height)
            )
            return (thumbnailImage, thumbnailScale)
        }
        return (thumbnailImage, nil)
    }
}

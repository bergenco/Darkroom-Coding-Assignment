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
    
    private var allSections: [GallerySection] {
        return [featuredPhotos, featuredFooterPhotos, photos]
    }
    
    // MARK: - Public
    
    public func reloadPhotos(completion: @escaping ()->Void) {
        DispatchQueue.global(qos: .background).async {
            
            var allItems: [PhotoItem] = Constants.supportedFileTypes
                .flatMap { Bundle.main.paths(forResourcesOfType: $0, inDirectory: nil) }
                .concurrentCompactMap {
                    let url = URL(fileURLWithPath: $0)
                    let name = url.deletingPathExtension().lastPathComponent
                    guard name.contains(Constants.bundledPhotoNameTag),
                          let data = try? Data(contentsOf: url)
                    else {
                        return nil
                    }
                    
                    let image = Self.createThumbnail(from: data)
                    return PhotoItem(name: name, thumbnail: image, url: url)
                }.shuffled()
            
            let featuredItems = allItems.prefix(Constants.featuredCount)
            allItems.removeFirst(featuredItems.count)
            
            let footerItems = allItems.prefix(Constants.featureFooterCount)
            allItems.removeFirst(footerItems.count)
            
            DispatchQueue.main.async {
                self.featuredPhotos = GallerySection(style: .featured, items: Array(featuredItems))
                self.photos = GallerySection(style: .normal, items: allItems)
                self.featuredFooterPhotos = GallerySection(style: .featuredFooter, items: Array(footerItems))
                completion()
            }
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
    
    // I made this static so the closure in reloadPhotos could call this
    // without having to retain `self`.
    //
    // TODO: Potentially make the size a parameter so we generate slighly larger
    // thumbnails when the preview is shown in a larger context (such as our larger gallery view).
    private static func createThumbnail(from imageData: Data) -> UIImage {
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

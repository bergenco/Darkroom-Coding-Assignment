//
//  GalleryDataSource.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit


enum GallerySectionStyle: CaseIterable {
    case featured
    case featuredFooter
    case normal
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
        DispatchQueue.global(qos: .background).async { [weak self] in
            var allItems: [PhotoItem] = Constants.supportedFileTypes
                .flatMap { Bundle.main.paths(forResourcesOfType: $0, inDirectory: nil) }
                .compactMap {
                    let url = URL(fileURLWithPath: $0)
                    let name = url.deletingPathExtension().lastPathComponent
                    guard name.contains(Constants.bundledPhotoNameTag),
                          let data = try? Data(contentsOf: url) else {
                        return nil
                    }
                    
                    let image = UIImage.thumbnail(from: data)
                    let userDefaults = UserDefaults.standard
                    
                    var edited: UIImage?
                    if let data = userDefaults.object(forKey: name) as? Data {
                        let decoder = JSONDecoder()
                        if let data = try? decoder.decode(EditedItem.self, from: data).data {
                            edited = UIImage(data: data)
                        }
                    }
                    
                    return PhotoItem(name: name, thumbnail: image, url: url, edited: edited)
                }.shuffled()
            
            let featuredItems = allItems.prefix(Constants.featuredCount)
            allItems.removeFirst(featuredItems.count)
            
            let footerItems = allItems.prefix(Constants.featureFooterCount)
            allItems.removeFirst(footerItems.count)
            
            self?.featuredPhotos = GallerySection(style: .featured, items: Array(featuredItems))
            self?.photos = GallerySection(style: .normal, items: allItems)
            self?.featuredFooterPhotos = GallerySection(style: .featuredFooter, items: Array(footerItems))
            
            DispatchQueue.main.async {
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

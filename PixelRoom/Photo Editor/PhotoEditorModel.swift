//
//  PhotoEditorModel.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

class PhotoEditorModel: PhotoEditorModelProtocol {
    
    private let item: PhotoItem
    private weak var view: PhotoEditorView?
    private weak var gallery: PhotoGalleryProtocol?

    private let inputImage: UIImage
    private let pixellateFilter = PixellateFilter()
    private let thumbnailScaleConverter = ThumbnailScaleConverter()
        
    private var currentlyFiltering: Bool = false
    private var pendingFilterUpdate: Bool = false
    private var pixellateInputScaleValue: Float = 0
    
    init(with item: PhotoItem, photoEditorView: PhotoEditorView, photoGallery: PhotoGalleryProtocol) {
        self.item = item
        self.view = photoEditorView
        self.gallery = photoGallery
        
        // setup input image
        self.inputImage = UIImage.resizedImage(from: item.url) ?? item.thumbnail
        
        // load edits and setup filter
        loadPixellateEdits()
        let image = pixellateFilter.pixelate(image: inputImage, inputScale: pixellateInputScaleValue)
        photoEditorView.setFilteredImage(image ?? item.thumbnail)
    }
    
    
    /// `currentlyFiltering` and `pendingFilterUpdate` are used to make sure we don't slow down
    /// the editing experience or block the user interface with too many updates.
    private func applyPixellateFilter() {
        guard !currentlyFiltering else {
            pendingFilterUpdate = true
            return
        }
        currentlyFiltering = true
        DispatchQueue.global().async {
            let pixellated = self.pixellateFilter.pixelate(image: self.inputImage, inputScale: self.pixellateInputScaleValue)
            
            let pixellatedThumbnailData = pixellated
                .flatMap { self.thumbnailScaleConverter.thumbnail(fromImage: $0)?.pngData() }
            
            DispatchQueue.main.async {
                if let pixellated = pixellated {
                    self.view?.setFilteredImage(pixellated)
                    self.currentlyFiltering = false
                    if self.pendingFilterUpdate {
                        self.pendingFilterUpdate = false
                        self.applyPixellateFilter()
                    }
                }
                
                if let thumbnailData = pixellatedThumbnailData,
                   let url = PhotoItem.pixellatedThumbnailURL(forId: self.item.id)
                {
                    do {
                        try thumbnailData.write(to: url)
                        self.gallery?.refreshPhoto(withId: self.item.id)
                    } catch {
                        print("failed to save pixellatedThumbnail with \(error)")
                    }
                }
            }
        }
    }
    
    var currentPixellateInputScaleValue: Float {
        return pixellateInputScaleValue
    }
    
    func editorDidChangePixellateInputScaleValue(to value: Float) {
        pixellateInputScaleValue = value
        storePixellateEdits()
        applyPixellateFilter()
    }
    
    func storePixellateEdits() {
        currentInputScaleSettings[item.id] = pixellateInputScaleValue
    }
    
    func loadPixellateEdits() {
        pixellateInputScaleValue = currentInputScaleSettings[item.id] ?? 0
    }
    
    // This probably works for this simple use case, but I would move this over to either a CoreData store
    // or a SQLite database.
    //
    // By doing that, I could store multiple types of edits in the future and access the edits of a single photo
    // without loading all of the edits into memory.
    private var currentInputScaleSettings: [String: Float] {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.dictionary(forKey: "inputScales") as? [String: Float] ?? [:]
        }
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: "inputScales")
        }
    }
}

// MARK: - Helpers

extension UIImage {
    static func resizedImage(from url: URL) -> UIImage? {
        let maxSize = UIScreen.main.bounds.size
        guard let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        let scale = max(maxSize.width / image.size.width, maxSize.height / image.size.height)
        let renderSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        let renderer = UIGraphicsImageRenderer(size: renderSize)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: renderSize))
        }
    }
}


extension PhotoItem {
    
    static func pixellatedThumbnailURL(forId id: ID) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
            .first?
            .appendingPathComponent("pixellatedThumbnails_" + id + ".png")
    }
    
    static func pixellatedThumbnail(forId id: ID) -> UIImage? {
        pixellatedThumbnailURL(forId: id)
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap(UIImage.init(data:))
    }
}

//
//  PhotoEditorModel.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

class PhotoEditorModel: PhotoEditorModelProtocol {
    
    private let item: PhotoItem
    private let view: PhotoEditorView
    private let inputImage: UIImage
    private let pixellateFilter = PixellateFilter()
    
    private var currentlyFiltering: Bool = false
    private var pendingFilterUpdate: Bool = false
    private var pixellateInputScaleValue: Float = 0.0
    
    init(with item: PhotoItem, photoEditorView: PhotoEditorView) {
        self.item = item
        self.view = photoEditorView
        
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
            DispatchQueue.main.async {
                if let pixellated = pixellated {
                    self.view.setFilteredImage(pixellated)
                    self.currentlyFiltering = false
                    if self.pendingFilterUpdate {
                        self.pendingFilterUpdate = false
                        self.applyPixellateFilter()
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
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(pixellateInputScaleValue, forKey: "inputscale")
        userDefaults.synchronize()
    }
    
    func loadPixellateEdits() {
        let userDefaults = UserDefaults.standard
        pixellateInputScaleValue = userDefaults.float(forKey: "inputScale")
        
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

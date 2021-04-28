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
    private var pixellateInputScaleValue: Float = PixellateFilter.minInputScale
    
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
        guard pixellateInputScaleValue.rounded() != value.rounded() else { return }
        
        pixellateInputScaleValue = value
        applyPixellateFilter()
    }
    
    func storeEditedImage(_ image: UIImage?) {
        let defaults = UserDefaults.standard
        
        guard pixellateInputScaleValue != PixellateFilter.minInputScale else {
            // Remove the edited item on initial scale
            defaults.setValue(nil, forKey: item.name)
            return
        }
        
        guard let image = image?.resized(),
              let data = image.jpegData(compressionQuality: 0.2) else {
            return
        }
        
        let editemItem = EditedItem(data: data, inputScale: pixellateInputScaleValue)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(editemItem) {
            
            defaults.set(encoded, forKey: item.name)
        }
    }
    
    func loadPixellateEdits() {
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.object(forKey: item.name) as? Data {
            let decoder = JSONDecoder()
            if let editedItem = try? decoder.decode(EditedItem.self, from: data) {
                pixellateInputScaleValue = editedItem.inputScale
            }
        }
    }
}

// MARK: - Helpers

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

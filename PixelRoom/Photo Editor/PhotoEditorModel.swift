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
    private let filter = Filter()
    
    private var currentlyFiltering: Bool = false
    private var pendingFilterUpdate: Bool = false
    private var filterType: Filter.FilterType = .pointillize
    private var inputScaleValue: Float = 0.0
    
    init(with item: PhotoItem, photoEditorView: PhotoEditorView) {
        self.item = item
        self.view = photoEditorView
        
        // setup input image
        self.inputImage = UIImage.resizedImage(from: item.url) ?? item.thumbnail
        
        // load edits and setup filter
        loadFilterEdits()
        let image = filter.apply(filterType, to: inputImage, inputScale: inputScaleValue)
        photoEditorView.setFilteredImage(image ?? item.thumbnail)
    }
    
    
    /// `currentlyFiltering` and `pendingFilterUpdate` are used to make sure we don't slow down
    /// the editing experience or block the user interface with too many updates.
    private func applyFilter() {
        guard !currentlyFiltering else {
            pendingFilterUpdate = true
            return
        }
        currentlyFiltering = true
        DispatchQueue.global().async {
            let filtered = self.filter.apply(
                self.filterType,
                to: self.inputImage,
                inputScale: self.inputScaleValue
            )
            DispatchQueue.main.async {
                if let filtered = filtered {
                    self.view.setFilteredImage(filtered)
                    self.currentlyFiltering = false
                    if self.pendingFilterUpdate {
                        self.pendingFilterUpdate = false
                        self.applyFilter()
                    }
                }
            }
        }
    }
    
    var currentFilterType: Filter.FilterType {
        return filterType
    }

    var currentInputScaleValue: Float {
        return inputScaleValue
    }
        
    func editorDidChangeFilter(to filterType: Filter.FilterType, scaleValue: Float) {
        self.filterType = filterType
        self.inputScaleValue = scaleValue
        storeFilterEdits()
        applyFilter()
    }
    
    func storeFilterEdits() {
        let id = item.url.deletingPathExtension().lastPathComponent
        var edits = UserDefaults.standard.photoEdits() ?? [:]
        if inputScaleValue > 0 {
            let edit = PhotoEdit(scaleValue: inputScaleValue, filterType: filterType)
            if let editData = try? JSONEncoder().encode(edit) {
                edits.updateValue(editData, forKey: id)
            }
        } else {
            edits.removeValue(forKey: id)
        }
        UserDefaults.standard.setPhotoEdits(edits)
        UserDefaults.standard.synchronize()
    }
    
    func loadFilterEdits() {
        let id = item.url.deletingPathExtension().lastPathComponent
        if let edits = UserDefaults.standard.photoEdits(),
           let editData = edits[id] as? Data,
           let edit = try? JSONDecoder().decode(PhotoEdit.self, from: editData) {
            filterType = edit.filterType
            inputScaleValue = edit.scaleValue
        }
    }
}

// MARK: - Helpers

extension UserDefaults {
    func photoEdits() -> [String: Any]? {
        return self.dictionary(forKey: "photoEdits")
    }
    
    func setPhotoEdits(_ edits: [String: Any]) {
        self.set(edits, forKey: "photoEdits")
    }
}

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

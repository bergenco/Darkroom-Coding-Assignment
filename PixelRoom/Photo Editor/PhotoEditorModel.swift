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
    private var filterValue: Float = PixellateFilter.minInputScale
    private var effect: Filter.Effect = .pixellate
    
    init(with item: PhotoItem, photoEditorView: PhotoEditorView) {
        self.item = item
        self.view = photoEditorView
        
        // setup input image
        self.inputImage = UIImage.resizedImage(from: item.url) ?? item.thumbnail
        
        // load edits and setup filter
        loadPixellateEdits()
        let image = filter.perform(currentEffect, on: inputImage, with: filterValue)
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
            let pixellated = self.filter.perform(self.effect, on: self.inputImage, with: self.filterValue)
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
    
    var currentFilterValue: Float {
        return filterValue
    }
    
    var currentEffect: Filter.Effect {
        return effect
    }
    
    
    func editorDidChangeFilterValue(to value: Float) {
        guard filterValue.rounded() != value.rounded() else { return }
        
        filterValue = value
        applyPixellateFilter()
    }
    
    func editorDidChangeEffect(to value: Filter.Effect) {
        effect = value
        filterValue = effect.minValue
        applyPixellateFilter()
    }
    
    func storeEditedImage(_ image: UIImage?) {
        let defaults = UserDefaults.standard
        
        guard filterValue != currentEffect.minValue else {
            // Remove the edited item on initial scale
            defaults.setValue(nil, forKey: item.name)
            return
        }
        
        guard let image = image?.resized(),
              let data = image.jpegData(compressionQuality: 0.2) else {
            return
        }
        
        let editemItem = EditedItem(data: data, inputScale: filterValue, effect: effect)
        
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
                filterValue = editedItem.inputScale
                effect = editedItem.effect
            }
        }
    }
}

//
//  PhotoEditor.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

protocol PhotoEditorModelProtocol: class {
    var currentPixellateInputScaleValue: Float { get }
    func editorDidChangePixellateInputScaleValue(to value: Float)
}

protocol PhotoEditorView: class {
    func setupWithModel(_ model: PhotoEditorModelProtocol)
    func setFilteredImage(_ image: UIImage)
}

protocol PhotoGalleryProtocol: class {
    func refreshPhoto(withId id: PhotoItem.ID)
}

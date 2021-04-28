//
//  PhotoEditor.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

protocol PhotoEditorModelProtocol: class {
    var currentFilterValue: Float { get }
    var currentEffect: Filter.Effect { get }
    func editorDidChangeFilterValue(to value: Float)
    func editorDidChangeEffect(to value: Filter.Effect)
    func storeEditedImage(_ image: UIImage?)
}

protocol PhotoEditorView: class {
    func setupWithModel(_ model: PhotoEditorModelProtocol)
    func setFilteredImage(_ image: UIImage)
}

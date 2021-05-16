//
//  PhotoEditor.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

protocol PhotoEditorModelProtocol: class {
    var currentFilterType: Filter.FilterType { get }
    var currentInputScaleValue: Float { get }
    func editorDidChangeFilter(to filterType: Filter.FilterType, scaleValue: Float)
}

protocol PhotoEditorView: class {
    func setupWithModel(_ model: PhotoEditorModelProtocol)
    func setFilteredImage(_ image: UIImage)
}

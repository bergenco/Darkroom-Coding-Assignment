//
//  PhotoItem.swift
//  PixelRoom
//
//  Created by Jean-Baptiste Castro on 28/04/2021.
//

import UIKit


struct PhotoItem: Equatable {
    
    let name: String
    let thumbnail: UIImage
    let url: URL
    
    var edited: UIImage? = nil
}

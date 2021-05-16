//
//  GalleryCollectionViewCell.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    let photoView = UIImageView()
    let editedView = UIImageView(image: UIImage(named: "icon-edit"))
    
    private let filter = Filter()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(photoView)
        contentView.addSubview(editedView)
        contentView.backgroundColor = .black
        photoView.layer.cornerRadius = 6
        photoView.layer.masksToBounds = true
        photoView.contentMode = .scaleAspectFill
        photoView.translatesAutoresizingMaskIntoConstraints = false
        editedView.layer.cornerRadius = 9
        editedView.backgroundColor = .white.withAlphaComponent(0.8)
        editedView.layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: 18, height: 18),
            cornerRadius: 9
        ).cgPath
        editedView.layer.shadowOffset = .zero
        editedView.layer.shadowColor = UIColor.black.cgColor
        editedView.layer.shadowRadius = 1
        editedView.layer.shadowOpacity = 0.7
        editedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            editedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            editedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            editedView.widthAnchor.constraint(equalToConstant: 18),
            editedView.heightAnchor.constraint(equalToConstant: 18),
        ])
      }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
    func configure(with item: PhotoItem) {
        if let edits = UserDefaults.standard.photoEdits(),
           let thumbnailScale = item.thumbnailScale,
           let editData = edits[item.url.deletingPathExtension().lastPathComponent] as? Data,
           let edit = try? JSONDecoder().decode(PhotoEdit.self, from: editData),
           let filtered = filter.apply(
            edit.filterType,
            to: item.thumbnail,
            inputScale: thumbnailScale * edit.scaleValue
           ) {
            photoView.image = filtered
            editedView.isHidden = false
        } else {
            photoView.image = item.thumbnail
            editedView.isHidden = true
        }
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.photoView.alpha = self.isSelected ? 0.75 : 1
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.photoView.alpha = self.isHighlighted ? 0.75 : 1
            }
        }
    }
}

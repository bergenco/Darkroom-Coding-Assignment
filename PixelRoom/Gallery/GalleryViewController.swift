//
//  GalleryViewController.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 28/02/2021.
//

import UIKit


// MARK: - GalleryViewController -

class GalleryViewController: UIViewController {
    
    enum Constants {
        static let interitemSpacing: CGFloat = 6
        static let sectionSpacing: CGFloat = 16
        static let cellIdentifier = "GalleryCollectionViewCell"
    }
    
    // MARK: Properties

    private let photoDataSource: GalleryDataSource = GalleryDataSource()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        
        return collectionView
    }()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.alpha = 0
        
        return activityIndicator
    }()
    
    // MARK: Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Not implemented. Use `init()`")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented. Use `init()`")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: View Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupLayout()
        reloadData()
    }

    // MARK: - Subviews and Layout
    
    private func setupSubviews() {
        title = "Gallery"
        view.backgroundColor = .black
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.interitemSpacing),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.interitemSpacing),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
        ])
    }
    
    private func setupCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                 
                 let section = GallerySectionStyle.allCases[sectionIndex]
                 switch section {
                 case .featured: return self.featuredSection()
                 case .featuredFooter: return self.featuredFooterSection()
                 case .normal: return self.normalSection()
                 }
              }
        
              return layout
    }
    
    // MARK: Data
    
    private func reloadData() {
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
        photoDataSource.reloadPhotos {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.alpha = 0
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Section Layout
    
    private func featuredSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging

        return section
    }
    
    private func featuredFooterSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous

        return section
    }
    
    private func normalSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 5, trailing: 10)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 5)

        return NSCollectionLayoutSection(group: group)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoDataSource.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoDataSource.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = photoDataSource.item(at: indexPath.row, inSection: indexPath.section)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath)
        if let photoCell = cell as? GalleryCollectionViewCell {
            photoCell.configure(with: item.edited ?? item.thumbnail)
            return photoCell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = photoDataSource.item(at: indexPath.row, inSection: indexPath.section)
        let editor = PhotoEditorViewController()
        let model = PhotoEditorModel(with: item, photoEditorView: editor)
        editor.setupWithModel(model)
        navigationController?.pushViewController(editor, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

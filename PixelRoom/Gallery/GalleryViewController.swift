//
//  GalleryViewController.swift
//  PixelRoom
//
//  Created by Igor Lipovac on 28/02/2021.
//

import UIKit

class GalleryViewController: UIViewController {
    
    enum Constants {
        static let interitemSpacing: CGFloat = 6
        
        // The section spacing was set using a combination of top/bottom insets before.
        // They are set using interSectionSpacing now, so I doubled this to match what the spacing was before.
        static let sectionSpacing: CGFloat = 32
        static let cellIdentifier = "GalleryCollectionViewCell"
    }

    private let photoDataSource: GalleryDataSource
    private let compositionalLayout: UICollectionViewCompositionalLayout
    private let collectionView: UICollectionView
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Not implemented. Use `init()`")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented. Use `init()`")
    }
    
    init() {
        photoDataSource = GalleryDataSource()
        compositionalLayout = Self.compositionalLayout(dataSource: photoDataSource)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This just makes sure we are using the latest image after editing.
        // This is code smell, and in a production app the diffable data source would handle this.
        collectionView.reloadData()
    }

    // MARK: - Subviews and Layout
    
    private func setupSubviews() {
        title = "Gallery"
        view.backgroundColor = .black
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        setupActivityIndicator()
        setupCollectionView()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.color = .white
        activityIndicator.alpha = 0
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
    }
    
    private func setupLayout() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.interitemSpacing),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.interitemSpacing),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
        ])
    }
    
    private static func compositionalLayout(dataSource: GalleryDataSource) -> UICollectionViewCompositionalLayout {
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = Constants.sectionSpacing
        
        return UICollectionViewCompositionalLayout(
            sectionProvider: { (section, environment) in
                
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let group: NSCollectionLayoutGroup
                let orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
                
                let style = dataSource.sectionStyleForSecton(section)
                switch style {
                case .featured:
                    
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.9),
                        heightDimension: .fractionalWidth(1/2)
                    )
                    
                    group = .horizontal(layoutSize: groupSize, subitem: item, count: 1)
                    orthogonalScrollingBehavior = .groupPagingCentered
                
                case .featuredFooter:
                    
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.9),
                        heightDimension: .fractionalWidth(1/8)
                    )
                    
                    group = .horizontal(layoutSize: groupSize, subitem: item, count: 4)
                    orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                    
                case .normal:
                    
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1/5)
                    )
                    
                    group = .horizontal(layoutSize: groupSize, subitem: item, count: 5)
                    orthogonalScrollingBehavior = .none
                }
                
                group.interItemSpacing = .fixed(Constants.interitemSpacing)
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = Constants.interitemSpacing
                section.orthogonalScrollingBehavior = orthogonalScrollingBehavior
                return section
                
            }, configuration: configuration)
    }
    
    private func reloadData() {
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
        photoDataSource.reloadPhotos {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.alpha = 0
            self.collectionView.reloadData()
        }
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
            photoCell.configure(with: item.thumbnail)
            return photoCell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = photoDataSource.item(at: indexPath.row, inSection: indexPath.section)
        let editor = PhotoEditorViewController()
        let model = PhotoEditorModel(with: item, photoEditorView: editor, photoGallery: photoDataSource)
        editor.setupWithModel(model)
        navigationController?.pushViewController(editor, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

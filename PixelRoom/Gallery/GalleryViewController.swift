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
        static let sectionSpacing: CGFloat = 16
        static let cellIdentifier = "GalleryCollectionViewCell"
    }

    private let photoDataSource: GalleryDataSource
    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private var lastSelection: IndexPath? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Not implemented. Use `init()`")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented. Use `init()`")
    }
    
    init() {
        photoDataSource = GalleryDataSource()
        super.init(nibName: nil, bundle: nil)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let lastSelection = self.lastSelection {
            collectionView.reloadItems(at: [lastSelection])
        }
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
            photoCell.configure(with: item)
            return photoCell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lastSelection = indexPath
        let item = photoDataSource.item(at: indexPath.row, inSection: indexPath.section)
        let editor = PhotoEditorViewController()
        let model = PhotoEditorModel(with: item, photoEditorView: editor)
        editor.setupWithModel(model)
        navigationController?.pushViewController(editor, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionViewLayout

extension GalleryViewController {
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (section, environment) in
            let style = self.photoDataSource.sectionStyleForSecton(section)
            switch style {
            case .featured:
                return self.makeFeaturedLayoutSection(environment)
            case .featuredFooter:
                return self.makeFeaturedFooterLayoutSection()
            case .normal:
                return self.makeNormalLayoutSection()
            }
        }
    }
    
    private func makeFeaturedLayoutSection(_ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let layoutItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        layoutItem.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.interitemSpacing,
            bottom: 0,
            trailing: Constants.interitemSpacing
        )
        let groupWidth = environment.container.contentSize.width * 0.94
        let layoutGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(groupWidth),
                heightDimension: .absolute(groupWidth / 2)
            ),
            subitem: layoutItem,
            count: 1
        )
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        let sectionHorizontalInset = (environment.container.contentSize.width - groupWidth) / 2
        layoutSection.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.sectionSpacing,
            leading: sectionHorizontalInset,
            bottom: Constants.sectionSpacing,
            trailing: sectionHorizontalInset
        )
        layoutSection.orthogonalScrollingBehavior = .groupPaging
        return layoutSection
    }
    
    private func makeFeaturedFooterLayoutSection() -> NSCollectionLayoutSection {
        let layoutItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        let layoutGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1.0 / 4.0 / 2.0)
            ),
            subitem: layoutItem,
            count: 4
        )
        layoutGroup.interItemSpacing = .fixed(Constants.interitemSpacing)
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = Constants.interitemSpacing
        layoutSection.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.sectionSpacing,
            leading: 0,
            bottom: Constants.sectionSpacing,
            trailing: 0
        )
        return layoutSection
    }
    
    private func makeNormalLayoutSection() -> NSCollectionLayoutSection {
        let layoutItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        let layoutGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1.0 / 5.0)
            ),
            subitem: layoutItem,
            count: 5
        )
        layoutGroup.interItemSpacing = .fixed(Constants.interitemSpacing)
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.interGroupSpacing = Constants.interitemSpacing
        layoutSection.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.sectionSpacing,
            leading: 0,
            bottom: Constants.sectionSpacing,
            trailing: 0
        )
        return layoutSection
    }
}

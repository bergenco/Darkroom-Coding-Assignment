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
    private let flowLayout: UICollectionViewFlowLayout
    private let collectionView: UICollectionView
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
        flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        super.init(nibName: nil, bundle: nil)
    }
    
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
        setupCollectionViewLayout()
    }
    
    private func setupCollectionViewLayout() {
        flowLayout.minimumInteritemSpacing = Constants.interitemSpacing
        flowLayout.minimumLineSpacing = Constants.interitemSpacing
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: Constants.sectionSpacing, left: 0, bottom: Constants.sectionSpacing, right: 0)
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let lastSelection = self.lastSelection {
            self.collectionView.reloadItems(at: [lastSelection])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let style = photoDataSource.sectionStyleForSecton(indexPath.section)
        switch style {
        case.featured:
            let width = (collectionView.frame.size.width - Constants.interitemSpacing) / 2
            let height = width / 2
            return CGSize(width: width, height: height)
            
        case .featuredFooter:
            let width = (collectionView.frame.size.width - 3 * Constants.interitemSpacing) / 4
            let height = width / 2
            return CGSize(width: width, height: height)
        
        case .normal:
            let width = (collectionView.frame.size.width - 4 * Constants.interitemSpacing) / 5
            let height = width
            return CGSize(width: width, height: height)
        }
    }
}

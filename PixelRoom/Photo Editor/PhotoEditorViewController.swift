//
//  PhotoEditorViewController.swift
//  Literoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

class PhotoEditorViewController: UIViewController, PhotoEditorView {
    
    private let stackView = UIStackView()
    private let filterTypeSegmentedControl = UISegmentedControl()
    private let imageView = UIImageView()
    private let scaleSliderStackView = UIStackView()
    private let valueLabel = UILabel()
    private let scaleSlider = UISlider()
    private var model: PhotoEditorModelProtocol?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Not implemented. Use `init()`")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented. Use `init()`")
    }
    

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    // MARK: - PhotoEditorView
    
    func setupWithModel(_ model: PhotoEditorModelProtocol) {
        self.model = model
        filterTypeSegmentedControl.selectedSegmentIndex = model.currentFilterType.rawValue
        scaleSlider.value = model.currentInputScaleValue
        updateValueLabel()
    }
    
    func setFilteredImage(_ image: UIImage) {
        self.imageView.image = image
    }
    
    // MARK: - Subviews and Layout
    
    private func setupSubviews() {
        title = "PixelRoom"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(sharePhoto(_:))
        )
        view.backgroundColor = .black
        view.addSubview(stackView)
        setupStackView()
        setupFilterTypeSegmentedControl()
        setupValueLabel()
        setupScaleSlider()
        updateValueLabel()
        setupImageView()
        setupLayout()
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        stackView.addArrangedSubview(filterTypeSegmentedControl)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(scaleSliderStackView)
    }
    
    private func setupFilterTypeSegmentedControl() {
        filterTypeSegmentedControl.insertSegment(withTitle: "Pointillize", at: 0, animated: false)
        filterTypeSegmentedControl.insertSegment(withTitle: "Hexagonal", at: 0, animated: false)
        filterTypeSegmentedControl.insertSegment(withTitle: "Pixellate", at: 0, animated: false)
        filterTypeSegmentedControl.selectedSegmentIndex = model?.currentFilterType.rawValue ?? 0
        filterTypeSegmentedControl.addTarget(
            self,
            action: #selector(segmentedControlChanged(_:)),
            for: .valueChanged
        )
    }
    
    private func setupImageView() {
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
    }
    
    private func setupValueLabel() {
        valueLabel.textAlignment = .right
    }
    
    private func setupScaleSlider() {
        scaleSliderStackView.axis = .horizontal
        scaleSliderStackView.alignment = .center
        scaleSliderStackView.distribution = .fillProportionally
        scaleSliderStackView.spacing = 16
        scaleSliderStackView.addArrangedSubview(scaleSlider)
        scaleSliderStackView.addArrangedSubview(valueLabel)
        scaleSlider.minimumValue = 0.0
        scaleSlider.maximumValue = 50.0
        scaleSlider.value = model?.currentInputScaleValue ?? 0.0
        scaleSlider.tintColor = .orange
        scaleSlider.thumbTintColor = .darkGray
        scaleSlider .addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
    }
    
    
    private func setupLayout() {
        let labelSize = ("100%" as NSString).size(
            withAttributes: [NSAttributedString.Key.font: valueLabel.font ?? .systemFont(ofSize: 17)]
        )
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            filterTypeSegmentedControl.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -60),
            filterTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 30),
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            scaleSliderStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -60),
            scaleSliderStackView.heightAnchor.constraint(equalToConstant: 120),
            valueLabel.widthAnchor.constraint(equalToConstant: labelSize.width)
        ])
    }
    
    @objc
    private func sliderChanged(_ slider: UISlider) {
        updateValueLabel()
        if let filterType = Filter.FilterType(rawValue: filterTypeSegmentedControl.selectedSegmentIndex) {
            model?.editorDidChangeFilter(to: filterType, scaleValue: slider.value)
        }
    }
   
    private func updateValueLabel() {
        let percentage = scaleSlider.value / (scaleSlider.maximumValue - scaleSlider.minimumValue) * 100;
        valueLabel.text = String(format: "%.0f%%", roundf(percentage))
    }
    
    @objc
    private func segmentedControlChanged(_ segmentedControl: UISegmentedControl) {
        if let filterType = Filter.FilterType(rawValue: segmentedControl.selectedSegmentIndex) {
            model?.editorDidChangeFilter(to: filterType, scaleValue: scaleSlider.value)
        }
    }
    
    @objc
    private func sharePhoto(_ sender: Any) {
        if let filteredImage = imageView.image {
            present(UIActivityViewController(
                activityItems: [filteredImage],
                applicationActivities: nil
            ), animated: true)
        }
    }
}

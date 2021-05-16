//
//  PhotoEditorViewController.swift
//  Literoom
//
//  Created by Igor Lipovac on 01/03/2021.
//

import UIKit

class PhotoEditorViewController: UIViewController, PhotoEditorView {
    
    private let stackView = UIStackView()
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
        scaleSlider.value = model.currentPixellateInputScaleValue
        updateValueLabel()
    }
    
    func setFilteredImage(_ image: UIImage) {
        self.imageView.image = image
    }
    
    // MARK: - Subviews and Layout
    
    private func setupSubviews() {
        title = "PixelRoom"
        view.backgroundColor = .black
        view.addSubview(stackView)
        setupStackView()
        setupValueLabel()
        updateValueLabel()
        setupScaleSlider()
        setupImageView()
        setupLayout()
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(scaleSliderStackView)
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
        scaleSlider.value = model?.currentPixellateInputScaleValue ?? 0.0
        scaleSlider.minimumValue = 0.0
        scaleSlider.maximumValue = 50.0
        scaleSlider.tintColor = .orange
        scaleSlider.thumbTintColor = .darkGray
        scaleSlider .addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
    }
    
    
    private func setupLayout() {
        let labelSize = ("100%" as NSString).size(
            withAttributes: [NSAttributedString.Key.font: self.valueLabel.font ?? .systemFont(ofSize: 17)]
        )
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            scaleSliderStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -60),
            scaleSliderStackView.heightAnchor.constraint(equalToConstant: 120),
            valueLabel.widthAnchor.constraint(equalToConstant: labelSize.width)
        ])
    }
    
    @objc
    private func sliderChanged(_ slider: UISlider) {
        updateValueLabel()
        model?.editorDidChangePixellateInputScaleValue(to: slider.value)
    }
   
    private func updateValueLabel() {
        let percentage = scaleSlider.value / (scaleSlider.maximumValue - scaleSlider.minimumValue) * 100;
        valueLabel.text = String(format: "%.0f%%", roundf(percentage))
    }
}



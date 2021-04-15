//
//  ProductColorPickerItemView.swift
//  ForwardLeasing
//

import UIKit

class ProductColorPickerItemView: UIView, EstimatedSizeHaving {
  // MARK: - Properties
  
  var estimatedSize: CGSize {
    return CGSize(width: 64, height: 64)
  }
  
  var isSelected: Bool = false {
    didSet {
      layer.borderWidth = isSelected ? 3 : 0
    }
  }
  
  private let colorView = UIView()
  private var viewModel: ProductColorPickerItemViewModel?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  func configure(with viewModel: ProductColorPickerItemViewModel) {
    self.viewModel = viewModel
    
    colorView.backgroundColor = viewModel.color
    colorView.layer.borderWidth = (viewModel.color.isLight(threshold: 0.94) ?? false) ? 1 : 0
    isSelected = viewModel.isSelected
    
    viewModel.onDidUpdate = { [weak self, weak viewModel] in
      guard let viewModel = viewModel else { return }
      self?.isSelected = viewModel.isSelected
    }
  }
  
  // MARK: - Actions
  
  @objc private func handleTap() {
    viewModel?.didTapView()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupColorView()
  }
  
  private func setupContainer() {
    layer.borderColor = UIColor.accent.cgColor
    makeRoundedCorners(radius: 32)
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    
    snp.makeConstraints { make in
      make.size.equalTo(64)
    }
  }
  
  private func setupColorView() {
    addSubview(colorView)
    colorView.makeRoundedCorners(radius: 24)
    colorView.layer.borderColor = UIColor.colorPickerColorOutline.cgColor
    colorView.snp.makeConstraints { make in
      make.size.equalTo(48)
      make.center.equalToSuperview()
    }
  }
}

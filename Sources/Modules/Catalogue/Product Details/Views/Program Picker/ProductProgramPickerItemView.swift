//
//  ProductProgramPickerItemView.swift
//  ForwardLeasing
//

import UIKit

class ProductProgramPickerItemView: UIView {
  // MARK: - Properties
  
  private let titleLabel = AttributedLabel(textStyle: .title2Regular)
  
  private var viewModel: ProductProgramPickerItemViewModel?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ProductProgramPickerItemViewModel) {
    self.viewModel = viewModel
    titleLabel.text = viewModel.title
    layer.borderWidth = viewModel.isSelected ? 3  : 1
    layer.borderColor = viewModel.isSelected ? UIColor.accent.cgColor  : UIColor.shade40.cgColor
    
    viewModel.onDidUpdate = { [weak self, weak viewModel] in
      self?.layer.borderWidth = (viewModel?.isSelected == true) ? 3  : 1
      self?.layer.borderColor = (viewModel?.isSelected == true) ? UIColor.accent.cgColor  : UIColor.shade40.cgColor
    }
  }
  
  // MARK: - Actions
  
  @objc private func didTapView() {
    viewModel?.didTapView()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupTitleLabel()
  }
  
  private func setupContainer() {
    layer.borderWidth = 1
    layer.borderColor = UIColor.shade40.cgColor
    makeRoundedCorners(radius: 28)
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
    
    snp.makeConstraints { make in
      make.height.equalTo(56)
    }
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.textColor = .shade70
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 2
    titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.centerY.equalToSuperview()
    }
    titleLabel.numberOfLines = 0
  }
}

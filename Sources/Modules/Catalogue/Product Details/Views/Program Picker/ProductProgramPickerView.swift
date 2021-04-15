//
//  ProductProgramPickerView.swift
//  ForwardLeasing
//

import UIKit

class ProductProgramPickerView: UIView {
  // MARK: - Properties
  
  private let titleLabel = AttributedLabel(textStyle: .textRegular)
  private let stackView = UIStackView()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ProductProgramPickerViewModel) {
    titleLabel.text = viewModel.title
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    viewModel.itemViewModels.forEach { itemViewModel in
      let item = ProductProgramPickerItemView()
      item.configure(with: itemViewModel)
      stackView.addArrangedSubview(item)
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupTitleLabel()
    setupStackView()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    
    titleLabel.textColor = .base1
    titleLabel.numberOfLines = 0
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupStackView() {
    addSubview(stackView)
    
    stackView.axis = .vertical
    stackView.spacing = 8
    
    stackView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
    }
  }
}

extension ProductProgramPickerView: Configurable {
  typealias ViewModel = ProductProgramPickerViewModel
}

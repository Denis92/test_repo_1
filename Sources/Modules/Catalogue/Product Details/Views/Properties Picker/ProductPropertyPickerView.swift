//
//  ProductPropertiesPickerView.swift
//  ForwardLeasing
//

import UIKit

protocol ProductPropertyPickerViewModelProtocol: class {
  var title: String? { get }
  var itemViewModels: [ProductPropertyPickerItemViewModel] { get }
}

class ProductPropertyPickerView: UIView {
  // MARK: - Properties
  
  private let titleLabel = AttributedLabel(textStyle: .textRegular)
  private let containerView = LeftAlignedItemsView(spacing: 24)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ProductPropertyPickerViewModelProtocol) {
    containerView.prepare()
    
    viewModel.itemViewModels.forEach { itemViewModel in
      let item = ProductPropertyPickerItemView()
      item.configure(with: itemViewModel)
      containerView.addArrangedSubview(item)
    }
    
    titleLabel.text = viewModel.title
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupTitle()
    setupContainerView()
  }
  
  private func setupTitle() {
    addSubview(titleLabel)
    
    titleLabel.textColor = .base1
    titleLabel.numberOfLines = 0
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupContainerView() {
    addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
    }
  }
}

extension ProductPropertyPickerView: Configurable {
  typealias ViewModel = ProductPropertyPickerViewModelProtocol
}

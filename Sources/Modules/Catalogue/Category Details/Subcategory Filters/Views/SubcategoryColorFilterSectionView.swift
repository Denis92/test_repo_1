//
//  SubcategoryColorFilterSectionView.swift
//  ForwardLeasing
//

import UIKit

class SubcategoryColorFilterSectionView: UIView {
  private let titleLabel = AttributedLabel(textStyle: .textRegular)
  private let containerView = LeftAlignedItemsView(spacing: 16)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: SubcategoryColorFilterSectionViewModel) {
    containerView.prepare()
    
    viewModel.itemViewModels.forEach { itemViewModel in
      let item = ProductColorPickerItemView()
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
      make.leading.trailing.top.equalToSuperview()
    }
  }
  
  private func setupContainerView() {
    addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
}

//
//  SubcategoryFilterSectionView.swift
//  ForwardLeasing
//

import UIKit

class SubcategoryFilterSectionView: UIView {
  private let titleLabel = AttributedLabel(textStyle: .textRegular)
  private lazy var containerView = LeftAlignedItemsView(spacing: 10, containerWidth: containerWidth)
  
  private let containerWidth: CGFloat?

  // MARK: - Init
  
  init(containerWidth: CGFloat) {
    self.containerWidth = containerWidth
    super.init(frame: .zero)
    setup()
  }

  override init(frame: CGRect) {
    self.containerWidth = nil
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure

  func configure(with viewModel: SubcategoryFilterSectionViewModel) {
    containerView.prepare()
    
    viewModel.itemViewModels.forEach { itemViewModel in
      let item = ProductPropertyPickerItemView(selectionStyle: .filled)
      item.configure(with: itemViewModel)
      containerView.addArrangedSubview(item)
    }

    titleLabel.text = viewModel.title
  }

  // MARK: - Setup

  private func setup() {
    setupTitleLabel()
    setupContainerView()
  }

  private func setupTitleLabel() {
    addSubview(titleLabel)
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

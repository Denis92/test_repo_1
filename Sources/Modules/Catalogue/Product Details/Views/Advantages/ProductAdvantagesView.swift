//
//  ProductAdvantagesView.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let itemSpacing: CGFloat = 15
  static let itemWidth: CGFloat = (UIScreen.main.bounds.width - 40 - itemSpacing) / 2
}

class ProductAdvantagesView: UIView {
  let containerView = LeftAlignedItemsView(spacing: Constants.itemSpacing)
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with viewModel: ProductAdvantagesViewModel) {
    containerView.prepare()
    
    viewModel.itemViewModels.forEach { itemViewModel in
      let itemView = ProductAdvantagesItemView(estimatedWidth: Constants.itemWidth)
      itemView.configure(with: itemViewModel)
      itemView.snp.makeConstraints { make in
        make.width.equalTo(Constants.itemWidth)
      }
      containerView.addArrangedSubview(itemView)
    }
  }
  
  private func setup() {
    addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
}

extension ProductAdvantagesView: Configurable {
  typealias ViewModel = ProductAdvantagesViewModel
}

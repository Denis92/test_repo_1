//
//  ListStackView.swift
//  ForwardLeasing
//

import UIKit

class ListStackView<ItemView: UIView & Configurable>: UIStackView {
  // MARK: - Init
  
  init(spacing: CGFloat = 0) {
    super.init(frame: .zero)
    self.spacing = spacing
    setup()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(viewModels: [ItemView.ViewModel]) {
    arrangedSubviews.forEach { $0.removeFromSuperview() }
    viewModels.forEach { viewModel in
      let itemView = ItemView()
      itemView.configure(with: viewModel)
      addArrangedSubview(itemView)
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    axis = .vertical
  }
}

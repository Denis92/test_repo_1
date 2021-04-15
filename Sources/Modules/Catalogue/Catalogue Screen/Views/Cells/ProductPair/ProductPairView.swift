//
//  ProductPairView.swift
//  ForwardLeasing
//

import UIKit

class ProductPairView: UIView, Configurable {
  private var viewModel: ProductPairViewModel?
  
  // MARK: - Subviews
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
  func configure(with viewModel: ProductPairViewModel) {
    self.viewModel = viewModel
    stackView.subviews.forEach { $0.removeFromSuperview() }
    
    for pair in viewModel.productViewModels {
      let cell = SingleProductView(style: .small)
      cell.configure(with: pair)
      
      if pair.product.size == .small {
        cell.snp.makeConstraints { $0.width.equalToSuperview().dividedBy(3) }
        stackView.alignment = pair.product.alignment.stackViewAlignment
      }
      
      stackView.addArrangedSubview(cell)
    }
  }
  
  // MARK: - Setup
  private func setup() {
    backgroundColor = .white
    setupStackView()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 5
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
  }
}

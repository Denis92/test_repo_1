//
//  ProductImageCarouselItemView.swift
//  ForwardLeasing
//

import UIKit

class ProductImageCarouselItemView: UIView, Configurable {
  // MARK: - Properties
  
  private let imageView = UIImageView()
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ProductImageCarouselItemViewModel) {
    imageView.setImage(with: viewModel.imageURL)
  }
  
  // MARK: - Setup
  
  private func setup() {
    layer.cornerRadius = 8
    clipsToBounds = true
    
    addSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

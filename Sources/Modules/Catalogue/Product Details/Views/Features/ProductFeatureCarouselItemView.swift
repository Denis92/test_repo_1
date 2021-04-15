//
//  ProductFeatureCarouselItemView.swift
//  ForwardLeasing
//

import UIKit

class ProductFeatureCarouselItemView: UIView, Configurable {
  // MARK: - Properties
  
  private let imageView = UIImageView()
  private let titleLabel = AttributedLabel(textStyle: .textRegular)

  // MARK: - Init

  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurable
  
  func configure(with viewModel: ProductFeaturesCarouselItemViewModel) {
    imageView.setImage(with: viewModel.imageURL)
    titleLabel.text = viewModel.title
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupImageView()
    setupTitleLabel()
    
    snp.makeConstraints { make in
      make.height.equalTo(320)
    }
  }
  
  private func setupImageView() {
    addSubview(imageView)
    
    imageView.contentMode = .scaleAspectFill
    imageView.makeRoundedCorners(radius: 10)
    imageView.clipsToBounds = true
    
    imageView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(270)
      make.width.equalTo(140)
    }
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    
    titleLabel.textColor = .shade70
    titleLabel.numberOfLines = 2
    titleLabel.textAlignment = .center
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview()
    }
  }
}

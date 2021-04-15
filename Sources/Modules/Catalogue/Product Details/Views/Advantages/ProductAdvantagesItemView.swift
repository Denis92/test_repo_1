//
//  ProductAdvantagesItemView.swift
//  ForwardLeasing
//

import UIKit

class ProductAdvantagesItemView: UIView, EstimatedSizeHaving {
  // MARK: - Properties
  
  var estimatedSize: CGSize {
    let titleHeight = titleLabel.text?.height(forContainerWidth: estimatedWidth, textStyle: .textRegular) ?? 0
    let contentHeight = contentLabel.text?.height(forContainerWidth: estimatedWidth, textStyle: .textRegular) ?? 0
    return CGSize(width: estimatedWidth, height: titleHeight + contentHeight + 74)
  }
  
  private let imageView = UIImageView()
  private let titleLabel = AttributedLabel(textStyle: .textRegular)
  private let contentLabel = AttributedLabel(textStyle: .textRegular)
  
  private let estimatedWidth: CGFloat
  
  // MARK: - Init
  
  init(estimatedWidth: CGFloat) {
    self.estimatedWidth = estimatedWidth
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ProductAdvantageItemViewModel) {
    imageView.setImage(with: viewModel.imageURL)
    titleLabel.text = viewModel.title
    contentLabel.text = viewModel.content
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupImageView()
    setupTitleLabel()
    setupContentLabel()
  }
  
  private func setupImageView() {
    addSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints { make in
      make.width.lessThanOrEqualTo(88)
      make.height.equalTo(64)
      make.leading.top.equalToSuperview()
      make.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.textColor = .base1
    titleLabel.numberOfLines = 3
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupContentLabel() {
    addSubview(contentLabel)
    contentLabel.textColor = .shade70
    contentLabel.numberOfLines = 2
    contentLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(2)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
}

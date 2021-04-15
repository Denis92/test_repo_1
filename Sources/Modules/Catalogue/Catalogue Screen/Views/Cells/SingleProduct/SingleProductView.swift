//
//  SingleProductView.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

enum SingleProductStyle {
  case small, large
  
  var size: Int {
    switch self {
    case .small:
      return 222
    case .large:
      return 345
    }
  }
  
  var circleSize: CGFloat {
    switch self {
    case .small:
      return 140
    case .large:
      return 220
    }
  }
}

class SingleProductView: UIView, Configurable {
  private var viewModel: SingleProductViewModel?
  private var style: SingleProductStyle
  private var imageInsetConstraint: Constraint?
  
  private let productTitleLabel = AttributedLabel(textStyle: .title2Bold)
  private let productPriceLabel = AttributedLabel(textStyle: .title2Bold)
  private let productImageViewContainer = UIView()
  private let backgroundCircleView = UIView()
  private let productImageView = UIImageView()
  private let tapControl = UIControl()
  
  // MARK: - Init
  convenience init(style: SingleProductStyle) {
    self.init(frame: .zero)
    self.style = style
    setup()
  }
  
  override init(frame: CGRect) {
    style = .large
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundCircleView.layer.cornerRadius = backgroundCircleView.frame.size.height / 2
  }
  
  // MARK: - Configure
  func configure(with viewModel: SingleProductViewModel) {
    self.viewModel = viewModel
    productTitleLabel.text = viewModel.title
    productPriceLabel.text = viewModel.price
    backgroundCircleView.backgroundColor = viewModel.backgroundColor
    productImageView.setImage(with: viewModel.productImageURL)
    productImageView.contentMode = viewModel.imageViewConfiguration.contentMode
    imageInsetConstraint?.update(inset: viewModel.imageInset(for: style))
    backgroundCircleView.isHidden = viewModel.isAppliances
  }
  
  // MARK: - Setup
  private func setup() {
    setupProductPrice()
    setupProductTitle()
    setupProductImageViewContainer()
    setupProductImage()
    setupTapControl()
  }
  
  private func setupProductImageViewContainer() {
    addSubview(backgroundCircleView)
    addSubview(productImageViewContainer)
    productImageViewContainer.contentMode = .scaleAspectFill
    productImageViewContainer.snp.makeConstraints { make in
      make.height.equalTo(style.size)
      make.bottom.equalTo(backgroundCircleView.snp.bottom)
      make.leading.top.trailing.equalToSuperview()
    }
    
    backgroundCircleView.snp.makeConstraints { make in
      make.size.equalTo(style.circleSize)
      make.bottom.equalTo(productTitleLabel.snp.top).offset(-10)
      make.centerX.equalToSuperview()
    }
  }

  private func setupProductImage() {
    productImageViewContainer.addSubview(productImageView)
    productImageView.snp.makeConstraints { make in
      imageInsetConstraint = make.edges.equalToSuperview().constraint
    }
  }

  private func setupProductTitle() {
    addSubview(productTitleLabel)
    productTitleLabel.textAlignment = .center
    productTitleLabel.snp.makeConstraints { make in
      make.bottom.equalTo(productPriceLabel.snp.top).offset(-10)
      make.leading.equalToSuperview().offset(12)
      make.trailing.equalToSuperview().offset(-12)
    }
    productTitleLabel.numberOfLines = 0
  }
  
  private func setupProductPrice() {
    addSubview(productPriceLabel)
    productPriceLabel.textAlignment = .center
    productPriceLabel.snp.makeConstraints { make in
      make.bottom.equalToSuperview().offset(-5)
      make.leading.equalToSuperview().offset(12)
      make.trailing.equalToSuperview().inset(12)
    }
  }

  private func setupTapControl() {
    addSubview(tapControl)
    tapControl.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    tapControl.addTarget(self, action: #selector(didTapped), for: .touchUpInside)
  }

  @objc private func didTapped() {
    viewModel?.selectTableCell()
  }
}

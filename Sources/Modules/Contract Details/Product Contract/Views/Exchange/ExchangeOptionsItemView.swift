//
//  ExchangeOptionsItemView.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let gradientStartColor = UIColor(red: 0.938, green: 0.328, blue: 0.621, alpha: 1)
  static let gradientEndColor = UIColor(red: 1, green: 0.404, blue: 0.196, alpha: 1)
  static let gradientStartPoint = CGPoint(x: 0, y: 0)
  static let gradientEndPoint = CGPoint(x: 1, y: 1)
  static let gradientLocations: [NSNumber] = [0.1, 0.9]
}

class ExchangeOptionsItemView: UIView, Configurable {
  // MARK: - Properties
  
  private let gradientLayer = CAGradientLayer()
  private let imageView = UIImageView()
  private let titleLabel = AttributedLabel(textStyle: .textBold)
  private let priceLabel = AttributedLabel(textStyle: .textBold)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = self.bounds
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ExchangeOptionsItemViewModel) {
    imageView.setImage(with: viewModel.imageURL)
    titleLabel.text = viewModel.title
    priceLabel.text = viewModel.monthPriceDifference
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupImageView()
    setupTitleLabel()
    setupPriceLabel()
  }
  
  private func setupContainer() {
    layer.cornerRadius = 12
    clipsToBounds = true
    
    gradientLayer.colors = [Constants.gradientStartColor.cgColor, Constants.gradientEndColor.cgColor]
    gradientLayer.locations = Constants.gradientLocations
    gradientLayer.startPoint = Constants.gradientStartPoint
    gradientLayer.endPoint = Constants.gradientEndPoint
    layer.addSublayer(gradientLayer)
  }
  
  private func setupImageView() {
    addSubview(imageView)
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(2)
      make.top.bottom.equalToSuperview().inset(6)
      make.width.equalTo(imageView.snp.height)
    }
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.textColor = .base2
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(24)
      make.leading.equalTo(imageView.snp.trailing).offset(4)
    }
  }
  
  private func setupPriceLabel() {
    addSubview(priceLabel)
    priceLabel.numberOfLines = 0
    priceLabel.textColor = .base2
    priceLabel.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(24)
      make.leading.equalTo(imageView.snp.trailing).offset(4)
      make.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(16)
    }
  }
}

//
//  PaymentsScheduleExchangeView.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let gradientStartColor = UIColor(red: 0.937, green: 0.329, blue: 0.619, alpha: 1)
  static let gradientEndColor = UIColor(red: 1, green: 0.404, blue: 0.196, alpha: 1)
  static let gradientStartPoint = CGPoint(x: 0, y: 0.4)
  static let gradientEndPoint = CGPoint(x: 1, y: 0.6)
}

class PaymentsScheduleExchangeView: UIView {
  // MARK: - Properties
  
  var price: Decimal? {
    didSet {
      if let priceString = price?.priceString() {
        exchangePriceLabel.text = R.string.contractDetails.paymentsScheduleExchangeText(priceString)
      }
    }
  }
  
  private let containerView = UIView()
  private let exchangePriceLabel = AttributedLabel(textStyle: .textBold)
  private let gradientLayer = CAGradientLayer()
  
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
    gradientLayer.frame = containerView.bounds
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainerView()
    setupExchangePriceLabel()
  }
  
  private func setupContainerView() {
    addSubview(containerView)
    containerView.layer.cornerRadius = 12
    containerView.clipsToBounds = true
    
    gradientLayer.colors = [Constants.gradientStartColor.cgColor, Constants.gradientEndColor.cgColor]
    gradientLayer.startPoint = Constants.gradientStartPoint
    gradientLayer.endPoint = Constants.gradientEndPoint
    containerView.layer.addSublayer(gradientLayer)
    
    containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(16)
      make.top.bottom.equalToSuperview().inset(10)
    }
  }
  
  private func setupExchangePriceLabel() {
    containerView.addSubview(exchangePriceLabel)
    exchangePriceLabel.numberOfLines = 0
    exchangePriceLabel.textColor = .base2
    exchangePriceLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10)
      make.top.bottom.equalToSuperview().inset(12)
    }
  }
}

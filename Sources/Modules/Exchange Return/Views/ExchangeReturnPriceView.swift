//
//  ExchangeReturnPriceView.swift
//  ForwardLeasing
//

import UIKit

class ExchangeReturnPriceView: UIView, Configurable {
  // MARK: - Subviews
  
  private let stackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let equationLabel = AttributedLabel(textStyle: .title2Bold)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ExchangeReturnPriceViewModel) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    setupTitleLabel(with: viewModel.priceViewModelTitles.title)
    
    if viewModel.hasEarlyExchangePayment {
      setupEquationLabel()
      equationLabel.attributedText = makeEquationString(earlyExchangePrice: viewModel.earlyExchangePrice,
                                                        deviceStatePrice: viewModel.deviceStatePrice,
                                                        totalPrice: viewModel.totalPrice)
      stackView.addArrangedSubview(makePriceInfoItemView(title: viewModel.priceViewModelTitles.earlyPriceTitle,
                                                         price: viewModel.earlyExchangePrice))
    }
    
    stackView.addArrangedSubview(makePriceInfoItemView(title: viewModel.priceViewModelTitles.deviceStatePriceTitle,
                                                       price: viewModel.deviceStatePrice))
    
    if viewModel.hasEarlyExchangePayment {
      if viewModel.hasTotalPrice {
        stackView.addArrangedSubview(makePriceInfoItemView(title: viewModel.priceViewModelTitles.totalPriceTitle,
                                                           price: viewModel.totalPrice))
      } else {
        stackView.addArrangedSubview(makePriceInfoItemView(title: viewModel.priceViewModelTitles.unknownTotalPriceTitle,
                                                           price: nil))
      }
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupStackView()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 10
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(32)
    }
  }
  
  private func setupTitleLabel(with title: String?) {
    stackView.addArrangedSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.text = title
    stackView.setCustomSpacing(16, after: titleLabel)
  }
  
  private func setupEquationLabel() {
    stackView.addArrangedSubview(equationLabel)
    equationLabel.numberOfLines = 0
    stackView.setCustomSpacing(12, after: equationLabel)
  }
  
  // MARK: - Private methods
  
  private func makeEquationString(earlyExchangePrice: String, deviceStatePrice: String,
                                  totalPrice: String) -> NSAttributedString {
    let equationString = NSMutableAttributedString(string: R.string.exchangeInfo.priceEquationLeftSide(earlyExchangePrice,
                                                                                                       deviceStatePrice),
                                                   attributes: [.foregroundColor: UIColor.accent])
    let equationRightSideString = NSAttributedString(string: totalPrice, attributes: [.foregroundColor: UIColor.base1])
    equationString.append(equationRightSideString)
    return equationString
  }
  
  private func makePriceInfoItemView(title: String, price: String?) -> UIView {
    let containerView = UIStackView()
    containerView.spacing = 24
    containerView.alignment = .center
    
    let titleLabel = AttributedLabel(textStyle: .textRegular)
    titleLabel.numberOfLines = 0
    titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    titleLabel.text = title
    containerView.addArrangedSubview(titleLabel)
    
    if let price = price {
      let priceLabel = AttributedLabel(textStyle: .textRegular)
      priceLabel.textAlignment = .right
      priceLabel.setContentHuggingPriority(.required, for: .horizontal)
      priceLabel.numberOfLines = 0
      priceLabel.text = price
      containerView.addArrangedSubview(priceLabel)
    }
    
    return containerView
  }
}

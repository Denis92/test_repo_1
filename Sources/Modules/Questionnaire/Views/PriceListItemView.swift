//
//  PriceListItemView.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

protocol PriceListItemViewModelProtocol {
  var price: String? { get }
  var description: String? { get }
}

class PriceListItemView: UIView, Configurable {
  // MARK: - Subviews
  private let priceLabel = AttributedLabel(textStyle: .textRegular)
  private let descriptionLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Properties
  var onDidUpdateWidth: (() -> Void)?
  
  private var priceLabelWidthConstraint: Constraint?
  private(set) var priceLabelWidth: CGFloat = 0 {
    didSet {
      onDidUpdateWidth?()
    }
  }
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    priceLabelWidth = priceLabel.intrinsicContentSize.width
  }
  
  // MARK: - Public Methods
  func configure(with viewModel: PriceListItemViewModelProtocol) {
    priceLabel.text = viewModel.price
    descriptionLabel.text = viewModel.description
    priceLabel.sizeToFit()
    priceLabelWidth = priceLabel.intrinsicContentSize.width
  }
  
  func updatePriceWidth(_ width: CGFloat) {
    priceLabelWidthConstraint?.update(offset: width)
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupPriceLabel()
    setupDescriptionLabel()
  }
  
  private func setupPriceLabel() {
    addSubview(priceLabel)
    priceLabel.textColor = .base1
    priceLabel.numberOfLines = 2
    priceLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    priceLabel.snp.makeConstraints { make in
      priceLabelWidthConstraint = make.width.equalTo(0).constraint
      make.top.leading.equalToSuperview()
    }
  }
  
  private func setupDescriptionLabel() {
    addSubview(descriptionLabel)
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textAlignment = .left
    descriptionLabel.textColor = .base1
    descriptionLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    descriptionLabel.snp.makeConstraints { make in
      make.leading.equalTo(priceLabel.snp.trailing).offset(24)
      make.top.trailing.bottom.equalToSuperview()
    }
  }
}

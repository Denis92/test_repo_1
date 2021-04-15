//
//  QuestionnaireProductInfoItemView.swift
//  ForwardLeasing
//

import UIKit

protocol QuestionnaireProductInfoItemViewModelProtocol {
  var imageURL: URL? { get }
  var productName: String? { get }
  var payment: String? { get }
}

class QuestionnaireProductInfoItemView: UIView, Configurable {
  // MARK: - Subviews
  private let productImageView = UIImageView()
  private let productNameLabel = AttributedLabel(textStyle: .title2Regular)
  private let paymentLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Properties
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Public Methods
  func configure(with viewModel: QuestionnaireProductInfoItemViewModelProtocol) {
    productImageView.setImage(with: viewModel.imageURL)
    productNameLabel.text = viewModel.productName
    paymentLabel.text = viewModel.payment
  }
  
  // MARK: - Private Methods
  private func setup() {
    setupProductImageView()
    setupProductNameLabel()
    setupPaymentLabel()
  }
  
  private func setupProductImageView() {
    addSubview(productImageView)
    productImageView.contentMode = .scaleAspectFit
    productImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.size.equalTo(40)
    }
  }
  
  private func setupProductNameLabel() {
    addSubview(productNameLabel)
    productNameLabel.numberOfLines = 0
    productNameLabel.textColor = .base1
    productNameLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10)
      make.leading.equalTo(productImageView.snp.trailing).offset(16)
      make.trailing.equalToSuperview().inset(28)
      make.centerY.equalTo(productImageView)
    }
  }
  
  private func setupPaymentLabel() {
    addSubview(paymentLabel)
    paymentLabel.numberOfLines = 0
    paymentLabel.textColor = .shade40
    paymentLabel.snp.makeConstraints { make in
      make.top.equalTo(productNameLabel.snp.bottom).offset(6)
      make.leading.equalTo(productNameLabel)
      make.bottom.equalToSuperview().inset(10)
      make.trailing.equalTo(productNameLabel)
    }
  }
}

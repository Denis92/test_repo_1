//
//  PaymentsScheduleItemView.swift
//  ForwardLeasing
//

import UIKit

class PaymentsScheduleItemView: UIView {
  // MARK: - Properties
  
  private let containerStackView = UIStackView()
  private let statusLabel = AttributedLabel(textStyle: .title2Regular)
  private let priceStackView = UIStackView()
  private let fineLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: PaymentScheduleItemViewModel) {
    statusLabel.text = viewModel.statusTitle
    statusLabel.textColor = viewModel.statusColor
    statusLabel.isHidden = viewModel.isStatusHidden || viewModel.statusTitle == nil
    fineLabel.text = viewModel.overduePrice
    fineLabel.isHidden = viewModel.isOverdueHidden || viewModel.overduePrice == nil
    
    priceStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    priceStackView.addArrangedSubview(makePriceItemView(title: viewModel.paymentDate,
                                                        price: viewModel.paymentPrice, textAligment: .left,
                                                        isMuted: viewModel.isMuted))
    priceStackView.addArrangedSubview(makePriceItemView(title: R.string.contractDetails.paymentResidue(),
                                                        price: viewModel.residualPrice, textAligment: .right,
                                                        isMuted: viewModel.isMuted))
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainerStackView()
    setupStatusLabel()
    setupPriceStackView()
    setupFineLabel()
  }
  
  private func setupContainerStackView() {
    addSubview(containerStackView)
    containerStackView.axis = .vertical
    containerStackView.spacing = 6
    containerStackView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(8)
      make.leading.trailing.equalToSuperview().inset(10)
    }
  }
  
  private func setupStatusLabel() {
    containerStackView.addArrangedSubview(statusLabel)
  }
  
  private func setupPriceStackView() {
    containerStackView.addArrangedSubview(priceStackView)
    priceStackView.axis = .horizontal
    priceStackView.distribution = .fillEqually
  }
  
  private func setupFineLabel() {
    containerStackView.addArrangedSubview(fineLabel)
    fineLabel.numberOfLines = 0
    fineLabel.textColor = .error
  }
  
  // MARK: - Private methods
  
  private func makePriceItemView(title: String?, price: String?,
                                 textAligment: NSTextAlignment, isMuted: Bool) -> UIView {
    let containerView = UIStackView()
    containerView.axis = .vertical
    containerView.spacing = 4
    
    let titleLabel = AttributedLabel(textStyle: .textRegular)
    titleLabel.text = title
    titleLabel.textAlignment = textAligment
    titleLabel.textColor = isMuted ? .shade70 : .base1
    containerView.addArrangedSubview(titleLabel)
    
    let priceLabel = AttributedLabel(textStyle: .title2Regular)
    priceLabel.text = price
    priceLabel.textAlignment = textAligment
    priceLabel.textColor = isMuted ? .shade70 : .base1
    containerView.addArrangedSubview(priceLabel)
    
    return containerView
  }
}

// MARK: - EstimatedSizeHaving

extension PaymentsScheduleItemView: EstimatedSizeHaving {
  var estimatedSize: CGSize {
    let width = superview?.frame.width ?? 0
    var statusLabelHeight = statusLabel.text?.height(forContainerWidth: width, textStyle: .title2Regular) ?? 0
    statusLabelHeight += statusLabelHeight == 0 ? 0 : 6
    var fineLabelHeight = fineLabel.text?.height(forContainerWidth: width, textStyle: .textRegular) ?? 0
    fineLabelHeight += fineLabelHeight == 0 ? 0 : 6
    return CGSize(width: width, height: 16 + 48 + statusLabelHeight + fineLabelHeight)
  }
}

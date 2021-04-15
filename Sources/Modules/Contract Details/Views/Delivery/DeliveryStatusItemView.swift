//
//  DeliveryStatusItemView.swift
//  ForwardLeasing
//

import UIKit

protocol DeliveryStatusItemViewModelProtocol {
  var isFinished: Bool { get }
  var status: String? { get }
  var date: String? { get }
  var time: String? { get }
}

class DeliveryStatusItemView: UIView, Configurable {
  // MARK: - Outlets
  private let deliveryIndicator = UIView()
  private let deliveryStatusLabel = AttributedLabel(textStyle: .textRegular)
  private let dateLabel = AttributedLabel(textStyle: .textRegular)
  private let timeLabel = AttributedLabel(textStyle: .textRegular)
  
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
  
  func configure(with viewModel: DeliveryStatusItemViewModelProtocol) {
    deliveryIndicator.backgroundColor = viewModel.isFinished ? .accent2 : .shade40
    dateLabel.text = viewModel.date
    timeLabel.text = viewModel.time
    deliveryStatusLabel.text = viewModel.status
    superview?.layoutIfNeeded()
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    backgroundColor = .shade20
    setupDeliveryIndicator()
    setupDeliveryStatusLabel()
    setupDateLabel()
    setupTimeLabel()
  }
  
  private func setupDeliveryIndicator() {
    addSubview(deliveryIndicator)
    deliveryIndicator.makeRoundedCorners(radius: 3)
    deliveryIndicator.snp.makeConstraints { make in
      make.top.bottom.leading.equalToSuperview().inset(10)
      make.width.equalTo(5)
      make.height.equalTo(44)
    }
  }
  
  private func setupDeliveryStatusLabel() {
    addSubview(deliveryStatusLabel)
    deliveryStatusLabel.textColor = .base1
    deliveryStatusLabel.numberOfLines = 0
    deliveryStatusLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    deliveryStatusLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10)
      make.leading.equalTo(deliveryIndicator.snp.trailing).offset(12)
    }
  }
  
  private func setupDateLabel() {
    addSubview(dateLabel)
    dateLabel.textAlignment = .right
    dateLabel.textColor = .shade70
    dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    dateLabel.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(10)
      make.leading.equalTo(deliveryStatusLabel.snp.trailing).offset(8)
    }
  }
  
  private func setupTimeLabel() {
    addSubview(timeLabel)
    timeLabel.textAlignment = .right
    timeLabel.textColor = .shade70
    timeLabel.snp.makeConstraints { make in
      make.top.equalTo(dateLabel.snp.bottom).offset(8)
      make.trailing.equalTo(dateLabel)
    }
  }
}

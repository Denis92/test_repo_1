//
//  StatusOfDeliveryView.swift
//  ForwardLeasing
//

import UIKit

protocol StatusOfDeliveryViewModelProtocol {
  var statusItems: [DeliveryStatusItemViewModel] { get }
}

class StatusOfDeliveryView: UIView, Configurable {
  // MARK: - Outlets
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let stackViewRoundedContainer = UIView()
  private let stackView = UIStackView()
  
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
  
  func configure(with viewModel: StatusOfDeliveryViewModelProtocol) {
    updateStatusItems(with: viewModel.statusItems)
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupTitleLabel()
    setupStackViewContainer()
    setupStackView()
  }
  
  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.textColor = .base1
    titleLabel.text = R.string.contractDetails.deliveryStatusTitle()
    titleLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupStackViewContainer() {
    addSubview(stackViewRoundedContainer)
    stackViewRoundedContainer.makeRoundedCorners(radius: 12)
    stackViewRoundedContainer.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  private func setupStackView() {
    stackViewRoundedContainer.addSubview(stackView)
    stackView.makeRoundedCorners(radius: 12)
    stackView.axis = .vertical
    stackView.spacing = 0
    stackView.snp.makeConstraints { make in
      make.edges.equalTo(stackViewRoundedContainer)
    }
  }
  
  private func updateStatusItems(with viewModels: [DeliveryStatusItemViewModel]) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    viewModels.forEach {
      let itemView = DeliveryStatusItemView()
      itemView.configure(with: $0)
      stackView.addArrangedSubview(itemView)
    }
  }
}

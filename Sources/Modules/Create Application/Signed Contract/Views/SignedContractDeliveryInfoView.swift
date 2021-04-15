//
//  SignedContractDeliveryInfoView.swift
//  ForwardLeasing
//

import UIKit

class SignedContractDeliveryInfoView: UIStackView {
  // MARK: - Properties
  
  private let addressTitleLabel = AttributedLabel(textStyle: .title2Bold)
  private let addressLabel = AttributedLabel(textStyle: .textRegular)
  private let dateTitleLabel = AttributedLabel(textStyle: .title2Bold)
  private let dateLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(address: String?, date: String?) {
    addressLabel.text = address
    dateLabel.text = date
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupAddressTitleLabel()
    setupAddressLabel()
    setupDateTitleLabel()
    setupDateLabel()
  }
  
  private func setupContainer() {
    axis = .vertical
    spacing = 12
  }
  
  private func setupAddressTitleLabel() {
    addArrangedSubview(addressTitleLabel)
    addressTitleLabel.numberOfLines = 0
    addressTitleLabel.text = R.string.signedContract.deliveryAddressTitleText()
  }
  
  private func setupAddressLabel() {
    addArrangedSubview(addressLabel)
    addressLabel.numberOfLines = 0
    setCustomSpacing(16, after: addressLabel)
  }
  
  private func setupDateTitleLabel() {
    addArrangedSubview(dateTitleLabel)
    dateTitleLabel.numberOfLines = 0
    dateTitleLabel.text = R.string.signedContract.deliveryDateTitleText()
  }
  
  private func setupDateLabel() {
    addArrangedSubview(dateLabel)
    dateLabel.numberOfLines = 0
  }
}

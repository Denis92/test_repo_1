//
//  ContractDetailsInfoView.swift
//  ForwardLeasing
//

import UIKit

protocol ContractDetailsInfoViewModelProtocol {
  var contractNumber: String? { get }
  var productProgressImageViewModel: ProductProgressImageViewModel { get }
  var monthPayment: String? { get }
  var statusTitle: String? { get }
  var statusSubtitle: String? { get }
}

class ContractDetailsInfoView: UIView, Configurable {
  // MARK: - Outlets
  private let contractNumberLabel = AttributedLabel(textStyle: .textRegular)
  private let productProgressImageView = ProductProgressImageView()
  private let titleContainer = UIView()
  private let monthPaymentTitleLabel = AttributedLabel(textStyle: .title2Bold)
  private let statusTitleLabel = AttributedLabel(textStyle: .title2Bold)
  private let subtitleContainer = UIView()
  private let monthPaymentSubtitleLabel = AttributedLabel(textStyle: .textRegular)
  private let statusSubtitleLabel = AttributedLabel(textStyle: .textRegular)
  
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
  
  func configure(with viewModel: ContractDetailsInfoViewModelProtocol) {
    contractNumberLabel.text = viewModel.contractNumber
    productProgressImageView.configure(with: viewModel.productProgressImageViewModel)
    monthPaymentTitleLabel.text = viewModel.monthPayment
    statusTitleLabel.text = viewModel.statusTitle
    statusSubtitleLabel.text = viewModel.statusSubtitle
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupContractNumberLabel()
    setupProductProgressImageView()
    setupTitleContainer()
    setupMonthPaymentTitleLabel()
    setupStatusTitleLabel()
    setupSubtitleContainer()
    setupMonthPaymentSubtitleLabel()
    setupStatusSubtitleLabel()
  }
  
  private func setupContractNumberLabel() {
    addSubview(contractNumberLabel)
    contractNumberLabel.textAlignment = .center
    contractNumberLabel.textColor = .base2
    contractNumberLabel.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview().inset(16)
    }
  }
  
  private func setupProductProgressImageView() {
    addSubview(productProgressImageView)
    productProgressImageView.imageBackgroundColor = .base2
    productProgressImageView.trackColor = .accent2Light
    productProgressImageView.snp.makeConstraints { make in
      make.top.firstBaseline.equalTo(contractNumberLabel.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(100)
      make.width.equalTo(productProgressImageView.snp.height)
    }
  }
  
  private func setupTitleContainer() {
    addSubview(titleContainer)
    titleContainer.snp.makeConstraints { make in
      make.top.equalTo(productProgressImageView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupMonthPaymentTitleLabel() {
    titleContainer.addSubview(monthPaymentTitleLabel)
    monthPaymentTitleLabel.textColor = .base2
    monthPaymentTitleLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview()
      make.width.equalTo(95)
      make.bottom.equalToSuperview().priority(.low)
    }
  }
  
  private func setupStatusTitleLabel() {
    titleContainer.addSubview(statusTitleLabel)
    statusTitleLabel.textColor = .base2
    statusTitleLabel.numberOfLines = 2
    statusTitleLabel.snp.makeConstraints { make in
      make.top.equalTo(monthPaymentTitleLabel)
      make.leading.equalTo(monthPaymentTitleLabel.snp.trailing).offset(32)
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview().priority(.low)
    }
  }
  
  private func setupSubtitleContainer() {
    addSubview(subtitleContainer)
    subtitleContainer.snp.makeConstraints { make in
      make.top.equalTo(titleContainer.snp.bottom).offset(4)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview()
    }
  }
  
  private func setupMonthPaymentSubtitleLabel() {
    subtitleContainer.addSubview(monthPaymentSubtitleLabel)
    monthPaymentSubtitleLabel.textColor = .base2
    monthPaymentSubtitleLabel.numberOfLines = 2
    monthPaymentSubtitleLabel.text = R.string.contractDetails.monthPaymentSubtitle()
    monthPaymentSubtitleLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview()
      make.width.equalTo(95)
      make.bottom.equalToSuperview().priority(.low)
    }
  }

  private func setupStatusSubtitleLabel() {
    subtitleContainer.addSubview(statusSubtitleLabel)
    statusSubtitleLabel.textColor = .base2
    statusSubtitleLabel.numberOfLines = 0
    statusSubtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(monthPaymentSubtitleLabel)
      make.leading.equalTo(monthPaymentSubtitleLabel.snp.trailing).offset(32)
      make.bottom.equalToSuperview().priority(.low)
      make.trailing.equalToSuperview()
    }
  }
}

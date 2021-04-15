//
//  BuySubscriptionRegisterViewController.swift
//  ForwardLeasing
//

import UIKit

class BuySubscriptionRegisterViewController: RegisterViewController {
  // MARK: - Subviews
  private let whereSentCodeLabel = AttributedLabel(textStyle: .title2Bold)
  private let alsoProfileLabel = AttributedLabel(textStyle: .textRegular)
  private let activationAvailableLabel = AttributedLabel(textStyle: .textRegular)
  
  // MARK: - Properties
  override var scrollViewAdditionalTopOffset: CGFloat {
    return 72
  }
  
  private let viewModel: BuySubscriptionRegisterViewModel
  
  // MARK: - Init
  init(viewModel: BuySubscriptionRegisterViewModel) {
    self.viewModel = viewModel
    super.init(viewModel: viewModel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  // MARK: - Public Methods
  
  // MARK: - Private Methods
  private func setup() {
    setupWhereSentCodeLabel()
    updateTextInputsConstraints()
    setupAlsoProfileLabel()
    setupActivationAvailableLabel()
    updateAgreementContainerConstraints()
  }
  
  private func bind() {
    viewModel.onDidFailPayment = { [weak self] in
      self?.showAppAlert(message: R.string.subscriptionRegister.paymentFailedAlertMessage())
    }
  }
  
  private func setupWhereSentCodeLabel() {
    contentView.addSubview(whereSentCodeLabel)
    whereSentCodeLabel.textColor = .base1
    whereSentCodeLabel.text = R.string.subscriptionRegister.whereSentCodeText()
    whereSentCodeLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func updateTextInputsConstraints() {
    textInputStackView.snp.remakeConstraints { make in
      make.top.equalTo(whereSentCodeLabel.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupAlsoProfileLabel() {
    contentView.addSubview(alsoProfileLabel)
    alsoProfileLabel.textColor = .base1
    alsoProfileLabel.text = R.string.subscriptionRegister.alsoProfileText()
    alsoProfileLabel.numberOfLines = 0
    alsoProfileLabel.snp.makeConstraints { make in
      make.top.equalTo(textInputStackView.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupActivationAvailableLabel() {
    contentView.addSubview(activationAvailableLabel)
    activationAvailableLabel.textColor = .base1
    activationAvailableLabel.text = R.string.subscriptionRegister.activationAvailableText()
    activationAvailableLabel.numberOfLines = 0
    activationAvailableLabel.snp.makeConstraints { make in
      make.top.equalTo(alsoProfileLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func updateAgreementContainerConstraints() {
    agreementContainer.snp.remakeConstraints { make in
      make.top.greaterThanOrEqualTo(activationAvailableLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
    }
  }
}

//
//  ContractMakePaymentButtonView.swift
//  ForwardLeasing
//

import UIKit

typealias ContractMakePaymentButtonCell =
  CommonContainerTableViewCell<ContractMakePaymentButtonView>

class ContractMakePaymentButtonView: UIView, Configurable {
  // MARK: - Properties
  
  private let paymentButton = StandardButton(type: .primary)
  private var viewModel: ContractMakePaymentButtonViewModel?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ContractMakePaymentButtonViewModel) {
    self.viewModel = viewModel
    paymentButton.setTitle(viewModel.title, for: .normal)
  }
  
  // MARK: - Actions
  
  @objc private func didTapButton() {
    viewModel?.didTapButton()
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(paymentButton)
    paymentButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    paymentButton.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
    }
  }
}

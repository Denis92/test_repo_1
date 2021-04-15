//
//  ExchangeReturnInfoButtonsView.swift
//  ForwardLeasing
//

import UIKit

class ExchangeReturnInfoButtonsView: UIView, Configurable {
  // MARK: - Properties
  
  private let stackView = UIStackView()
  private let primaryButton = StandardButton(type: .primary)
  private let cancelContractButton = StandardButton(type: .clear)
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: ExchangeReturnButtonsViewModel) {
    primaryButton.setTitle(viewModel.primaryButtonTitle, for: .normal)
    primaryButton.isHidden = viewModel.shouldHidePrimaryButton
    primaryButton.actionHandler(controlEvents: .touchUpInside) { [weak viewModel] in
      viewModel?.didTapPrimaryButton()
    }
    cancelContractButton.setTitle(viewModel.cancelButtonTitle, for: .normal)
    cancelContractButton.isHidden = viewModel.shouldHideCancelButton
    cancelContractButton.actionHandler(controlEvents: .touchUpInside) { [weak viewModel] in
      viewModel?.didTapCancelContractButton()
    }
    viewModel.onDidStartRequest = { [weak self] in
      self?.primaryButton.startAnimating()
    }
    viewModel.onDidFinishRequest = { [weak self] in
      self?.primaryButton.stopAnimating()
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupStackView()
    setupPrimaryButton()
    setupCancelContractButton()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupPrimaryButton() {
    stackView.addArrangedSubview(primaryButton)
  }
  
  private func setupCancelContractButton() {
    stackView.addArrangedSubview(cancelContractButton)
    cancelContractButton.setTitle(R.string.exchangeInfo.cancelContractButtonTitle(), for: .normal)
  }
}

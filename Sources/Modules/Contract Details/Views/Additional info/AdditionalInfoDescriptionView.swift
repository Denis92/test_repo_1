//
//  EarlyRedemptionView.swift
//  ForwardLeasing
//

import UIKit

protocol AdditionalInfoDescriptionViewModelProtocol {
  var description: String? { get }
  var buttonTitle: String? { get }
  var isEnabled: Bool { get }
  var onDidTapButton: (() -> Void)? { get }
}

class AdditionalInfoDescriptionView: UIView, Configurable {
  // MARK: - Outlets
  private let descriptionLabel = AttributedLabel(textStyle: .textRegular)
  private let bottomButton = StandardButton(type: .primary)
  
  // MARK: - Properties
  private var onDidTapButton: (() -> Void)?
  
  // MARK: - Init
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  // MARK: - Public
  func configure(with viewModel: AdditionalInfoDescriptionViewModelProtocol) {
    onDidTapButton = viewModel.onDidTapButton
    descriptionLabel.text = viewModel.description
    bottomButton.setTitle(viewModel.buttonTitle, for: .normal)
    bottomButton.updateType(viewModel.isEnabled ? .primary : .secondary)
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupDescriptionLabel()
    setupBottomButton()
  }
  
  private func setupDescriptionLabel() {
    addSubview(descriptionLabel)
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textColor = .base1
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupBottomButton() {
    addSubview(bottomButton)
    bottomButton.actionHandler(controlEvents: .touchUpInside) { [weak self] in
      self?.onDidTapButton?()
    }
    bottomButton.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(24)
    }
  }
}

//
//  ReturnInfoView.swift
//  ForwardLeasing
//

import UIKit

protocol ReturnInfoViewModelProtocol {
  var onDidTapMakeReturn: (() -> Void)? { get }
}

class ReturnInfoView: UIView, Configurable {
  // MARK: - Outlets
  private let descriptionLabel = AttributedLabel(textStyle: .textRegular)
  private let returnButton = StandardButton(type: .primary)
  
  // MARK: - Properties
  private var onDidTapMakeReturn: (() -> Void)?
  
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
  
  func configure(with viewModel: ReturnInfoViewModelProtocol) {
    onDidTapMakeReturn = viewModel.onDidTapMakeReturn
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupDescriptionLabel()
    setupReturnButton()
  }
  
  private func setupDescriptionLabel() {
    addSubview(descriptionLabel)
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textColor = .base1
    descriptionLabel.text = R.string.contractDetails.returnInfoDescription()
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupReturnButton() {
    addSubview(returnButton)
    returnButton.setTitle(R.string.contractDetails.returnInfoButtonTitle(), for: .normal)
    returnButton.actionHandler(controlEvents: .touchUpInside) { [weak self] in
      self?.onDidTapMakeReturn?()
    }
    returnButton.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(24)
    }
  }
}

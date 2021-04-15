//
//  ContractAdditionalApplicationView.swift
//  ForwardLeasing
//

import UIKit

class ContractAdditionalApplicationView<ApplicationView: UIView>: UIView, Configurable where ApplicationView: Configurable {
  // MARK: - Properties

  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let applicationView = ApplicationView()
  private let hintLabelContainer = UIStackView()
  private let hintLabel = AttributedLabel(textStyle: .textRegular)

  // MARK: - Init

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configure

  func configure(with viewModel: ContractAdditionalViewModel<ApplicationView.ViewModel>) {
    applicationView.configure(with: viewModel.applicationViewModel)
    titleLabel.text = viewModel.title
    hintLabel.text = viewModel.hint
    hintLabel.isHidden = viewModel.hint.isEmptyOrNil
  }

  // MARK: - Setup

  private func setup() {
    setupTitleLabel()
    setupExchangeApplicationView()
    setupHintLabelContainer()
    setupHintLabel()
  }

  private func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }

  private func setupExchangeApplicationView() {
    addSubview(applicationView)
    applicationView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }

  private func setupHintLabelContainer() {
    addSubview(hintLabelContainer)
    hintLabelContainer.snp.makeConstraints { make in
      make.top.equalTo(applicationView.snp.bottom).offset(12)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(40)
    }
  }

  private func setupHintLabel() {
    hintLabelContainer.axis = .vertical
    hintLabelContainer.addArrangedSubview(hintLabel)
    hintLabel.numberOfLines = 0
  }
}

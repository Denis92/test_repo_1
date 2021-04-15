//
//  ContractReturnApplicationView.swift
//  ForwardLeasing
//

import UIKit

class ContractReturnApplicationView: UIView, Configurable {
  // MARK: - Properties
  
  private let stackView = UIStackView()
  private let descriptionView = ProductStatusDescriptionView()
  private let primaryButton = StandardButton(type: .primary)
  private let cancelButton = StandardButton(type: .outlined)
  private let diagnosticsView = ContractExchangeDiagnosticsView()

  private var viewModel: ContractReturnApplicationViewModel?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurable
  
  func configure(with viewModel: ContractReturnApplicationViewModel) {
    self.viewModel = viewModel
    updateState()

    if viewModel.contractReturnDescriptionViewModel?.productDescriptionConfiguration.title.isEmpty == true {
      stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 24, leading: 10, bottom: 24, trailing: 10)
    } else {
      stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 24, trailing: 10)
    }
    stackView.isLayoutMarginsRelativeArrangement = true
  }
  
  // MARK: - Actions
  
  @objc private func didTapPrimaryButton() {
    viewModel?.didTapPrimaryButton()
  }
  
  @objc private func didTapCancelApplicationButton() {
    viewModel?.didTapCancelApplicationButton()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupContainer()
    setupStackView()
    setupDescriptionView()
    setupPrimaryButton()
    setupCancelButton()
    setupDiagnosticView()
  }
  
  private func setupContainer() {
    backgroundColor = .shade20
    layer.cornerRadius = 12
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 12
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupDescriptionView() {
    stackView.addArrangedSubview(descriptionView)
    stackView.setCustomSpacing(16, after: descriptionView)
  }
  
  private func setupPrimaryButton() {
    stackView.addArrangedSubview(primaryButton)
    primaryButton.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
  }
  
  private func setupCancelButton() {
    stackView.addArrangedSubview(cancelButton)
    cancelButton.setTitle(R.string.contractDetails.cancelApplicationButtonTitle(), for: .normal)
    cancelButton.addTarget(self, action: #selector(didTapCancelApplicationButton), for: .touchUpInside)
  }
  
  private func setupDiagnosticView() {
    addSubview(diagnosticsView)
    diagnosticsView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  // MARK: - Private methods
  
  private func updateState() {
    guard let viewModel = viewModel else { return }

    switch viewModel.state {
    case .new, .awaitingDiagnostics, .comission, .freeExchange:
      stackView.isHidden = false
      diagnosticsView.isHidden = true
      primaryButton.isHidden = false
      cancelButton.isHidden = false
    case .paid, .awaitingExchange:
      stackView.isHidden = false
      diagnosticsView.isHidden = true
      primaryButton.isHidden = true
      cancelButton.isHidden = false
    case .onDiagnostics:
      stackView.isHidden = true
      diagnosticsView.isHidden = false
    }

    if let descriptionViewModel = viewModel.contractReturnDescriptionViewModel {
      descriptionView.configure(with: descriptionViewModel)
      descriptionView.isHidden = false
    } else {
      descriptionView.isHidden = true
    }

    primaryButton.setTitle(viewModel.primaryButtonTitle, for: .normal)
  }
}

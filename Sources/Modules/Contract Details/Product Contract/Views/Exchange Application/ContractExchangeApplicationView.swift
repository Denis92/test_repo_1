//
//  ContractExchangeApplicationView.swift
//  ForwardLeasing
//

import UIKit

class ContractExchangeApplicationView: UIView, Configurable {
  // MARK: - Properties
  
  private let stackView = UIStackView()
  private let productInfoView = ProductInfoView()
  private let primaryButton = StandardButton(type: .primary)
  private let cancelButton = StandardButton(type: .outlined)
  private let diagnosticsView = ContractExchangeDiagnosticsView()
  private let activityIndicatorView = ActivityIndicatorView(color: .accent)
  
  private var viewModel: ContractExchangeApplicationViewModel?
  
  // MARK: - Init
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurable
  
  func configure(with viewModel: ContractExchangeApplicationViewModel) {
    self.viewModel = viewModel
    updateState()
    
    viewModel.onDidStartRequest = { [weak self] in
      self?.activityIndicatorView.startAnimating()
      self?.diagnosticsView.isHidden = true
      self?.stackView.isHidden = true
    }
    viewModel.onDidFinishRequest = { [weak self] in
      self?.activityIndicatorView.stopAnimating()
      self?.diagnosticsView.isHidden = false
      self?.stackView.isHidden = false
    }
    viewModel.onDidUpdate = { [weak self] in
      self?.updateState()
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.handle(error: error)
    }
    
    updateState()
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
    setupProductInfoView()
    setupPrimaryButton()
    setupCancelButton()
    setupActivityIndicatorView()
  }
  
  private func setupContainer() {
    backgroundColor = .shade20
    layer.cornerRadius = 12
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.leading.trailing.equalToSuperview().inset(10)
      make.bottom.equalToSuperview().inset(24)
    }
  }
  
  private func setupProductInfoView() {
    stackView.addArrangedSubview(productInfoView)
    stackView.setCustomSpacing(12, after: productInfoView)
  }
  
  private func setupPrimaryButton() {
    primaryButton.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
  }
  
  private func setupCancelButton() {
    cancelButton.setTitle(R.string.contractDetails.cancelApplicationButtonTitle(), for: .normal)
    cancelButton.addTarget(self, action: #selector(didTapCancelApplicationButton), for: .touchUpInside)
  }
  
  private func setupActivityIndicatorView() {
    addSubview(activityIndicatorView)
    activityIndicatorView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Private methods
  
  private func updateState() {
    guard let viewModel = viewModel else { return }
    
    stackView.removeFromSuperview()
    diagnosticsView.removeFromSuperview()
    
    stackView.subviews.forEach { subview in
      if subview !== productInfoView {
        subview.removeFromSuperview()
      }
    }
    
    if viewModel.state == .onDiagnostics {
      addSubview(diagnosticsView)
      diagnosticsView.snp.remakeConstraints { make in
        make.top.bottom.equalToSuperview().inset(87)
        make.leading.trailing.equalToSuperview()
      }
      return
    } else {
      addSubview(stackView)
      stackView.snp.remakeConstraints { make in
        make.top.equalToSuperview().inset(16)
        make.leading.trailing.equalToSuperview().inset(10)
        make.bottom.equalToSuperview().inset(24)
      }
    }
    
    switch viewModel.state {
    case .new, .awaitingDiagnostics, .comission, .freeExchange:
      stackView.addArrangedSubview(primaryButton)
      stackView.addArrangedSubview(cancelButton)
    case .paid, .awaitingExchange:
      stackView.addArrangedSubview(primaryButton)
    case .onDiagnostics:
      return
    }
    
    primaryButton.setTitle(viewModel.primaryButtonTitle, for: .normal)
    
    var descriptions: [ProductDescriptionConfiguration] = []
    if let status = viewModel.statusTitle {
      descriptions.append(ProductDescriptionConfiguration(title: status, color: .access))
    }
    let productDescriptionViewModel = ProductDescriptionViewModel(descriptions: descriptions,
                                                                  nameTitle: viewModel.productName,
                                                                  paymentTitle: viewModel.monthPayment)
    let productInfoViewModel = ProductInfoViewModel(descriptionViewModel: productDescriptionViewModel,
                                                    imageViewType: .simple(ProductImageViewModel(imageURL: viewModel.imageURL)))
    productInfoView.configure(with: productInfoViewModel as ProductInfoViewModelProtocol)
  }
}

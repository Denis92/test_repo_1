//
//  ContractSigningViewController.swift
//  ForwardLeasing
//

import UIKit

protocol ContractSigningViewControllerDelegate: class {
  func contractSigningViewControllerDidFinish(_ viewController: ContractSigningViewController)
}

class ContractSigningViewController: RegularNavBarViewController, ActivityIndicatorViewDisplaying,
                                     ErrorEmptyViewDisplaying, ViewModelBinding {
  // MARK: - Properties
  
  weak var delegate: ContractSigningViewControllerDelegate?
  
  let activityIndicatorView = ActivityIndicatorView()
  let errorEmptyView = ErrorEmptyView()
  
  private let stackView = UIStackView()
  private let contractPDFView = DocumentPDFView()
  private let featuresListView = ListStackView<ContractFeatureView>()
  private let totalPriceTitleLabel = AttributedLabel(textStyle: .title2Bold)
  private let totalPriceValueLabel = AttributedLabel(textStyle: .title2Bold)
  private let exchangeDescriptionLabel = AttributedLabel(textStyle: .textRegular)
  private let infoListView = ListStackView<ContractInfoItemView>(spacing: 24)
  private let agreementView = AgreementCheckboxView(hasHorizontalInsets: false)
  private let signContractButton = StandardButton(type: .primary)
  
  private let viewModel: ContractSigningViewModel
  
  private var updatedContentOffset = false
  
  // MARK: - Init
  
  init(viewModel: ContractSigningViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindToViewModel()
    viewModel.loadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updatedContentOffset = false
    view.setNeedsLayout()
    view.layoutIfNeeded()
  }

  // MARK: - Public methods
  
  func handleEmptyViewRefreshButtonTapped() {
    viewModel.loadData()
  }
  
  func handleRequestStarted(shouldShowActivityIndicator: Bool) {
    scrollView.isHidden = true
  }
  
  func handleRequestFinished() {
    signContractButton.stopAnimating()
  }
  
  func reloadViews() {
    featuresListView.configure(viewModels: viewModel.contractFeatureViewModels)
    infoListView.configure(viewModels: viewModel.infoItemViewModels)
    totalPriceTitleLabel.text = viewModel.totalPriceTitle
    totalPriceValueLabel.text = viewModel.totalPrice
    scrollView.isHidden = false
  }
  
  // MARK: - Actions
  
  @objc private func didTapSignContractButton() {
    viewModel.proceed()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupNavigationBarView(title: R.string.contractSigning.screenTitle()) { [weak self] in
      guard let self = self else { return }
      self.delegate?.contractSigningViewControllerDidFinish(self)
    }
    setupScrollView()
    setupStackView()
    setupContractPDFView()
    setupFeaturesListView()
    setupTotalSum()
    setupExchangeDescriptionLabel()
    setupInfoListView()
    setupAgreementView()
    setupSignContractButton()
    addActivityIndicatorView()
    addErrorEmptyView()
  }
  
  private func setupStackView() {
    scrollView.addSubview(stackView)
    stackView.axis = .vertical
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.bottom.equalToSuperview().inset(40)
      make.leading.trailing.equalToSuperview().inset(20)
      make.width.equalTo(view).offset(-40)
    }
  }
  
  private func setupContractPDFView() {
    stackView.addArrangedSubview(contractPDFView)
    contractPDFView.onDidTapButton = { [weak self] in
      self?.viewModel.openContractPDF()
    }
    stackView.setCustomSpacing(12, after: contractPDFView)
  }
  
  private func setupFeaturesListView() {
    stackView.addArrangedSubview(featuresListView)
    stackView.setCustomSpacing(12, after: featuresListView)
  }
  
  private func setupTotalSum() {
    stackView.addArrangedSubview(totalPriceTitleLabel)
    totalPriceTitleLabel.textColor = .base1
    stackView.setCustomSpacing(4, after: totalPriceTitleLabel)
    
    stackView.addArrangedSubview(totalPriceValueLabel)
    totalPriceValueLabel.textColor = .base1
    stackView.setCustomSpacing(32, after: totalPriceValueLabel)
  }
  
  private func setupExchangeDescriptionLabel() {
    stackView.addArrangedSubview(exchangeDescriptionLabel)
    exchangeDescriptionLabel.textColor = .shade70
    exchangeDescriptionLabel.numberOfLines = 0
    exchangeDescriptionLabel.text = R.string.contractSigning.exchangeDescriptionText()
    stackView.setCustomSpacing(24, after: exchangeDescriptionLabel)
  }
  
  private func setupInfoListView() {
    stackView.addArrangedSubview(infoListView)
    stackView.setCustomSpacing(24, after: infoListView)
  }
  
  private func setupAgreementView() {
    stackView.addArrangedSubview(agreementView)
    agreementView.configure(with: viewModel.agreementViewModel)
    stackView.setCustomSpacing(24, after: agreementView)
  }
  
  private func setupSignContractButton() {
    stackView.addArrangedSubview(signContractButton)
    signContractButton.isEnabled = false
    signContractButton.setTitle(R.string.contractSigning.signContractButtonTitle(), for: .normal)
    signContractButton.addTarget(self, action: #selector(didTapSignContractButton), for: .touchUpInside)
  }
  
  // MARK: - ViewModel
  
  private func bindToViewModel() {
    viewModel.onDidUpdate = { [weak self] in
      self?.signContractButton.isEnabled = self?.viewModel.canSignContract ?? false
    }
    viewModel.onDidStartSmsSendingRequest = { [weak self] in
      self?.signContractButton.startAnimating()
    }
    bind(to: viewModel)
  }
}

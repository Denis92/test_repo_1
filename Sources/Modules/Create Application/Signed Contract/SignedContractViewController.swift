//
//  SignedContractViewController.swift
//  ForwardLeasing
//

import UIKit

protocol SignedContractViewControllerDelegate: class {
  func signedContractViewControllerDidFinish(_ viewController: SignedContractViewController)
}

class SignedContractViewController: RegularNavBarViewController, ViewModelBinding,
                                    ActivityIndicatorViewDisplaying, ErrorEmptyViewDisplaying {
  // MARK: - Properties
  
  weak var delegate: SignedContractViewControllerDelegate?
  
  let activityIndicatorView = ActivityIndicatorView()
  let errorEmptyView = ErrorEmptyView()
  
  private let containerView = UIView()
  private let stackView = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let contractPDFView = DocumentPDFView()
  
  private let agreementPDFView = DocumentPDFView()
  private let deliveryInfoView = SignedContractDeliveryInfoView()
  
  private let barcodeView = BarcodeView()
  private let storeInfoView = StoreInfoView(style: .signedContract)
  
  private let additionalInfoLabel = AttributedLabel(textStyle: .textRegular)
  private let confirmationButton = StandardButton(type: .primary)
  private let cancelContractButton = StandardButton(type: .clear)
  
  private let viewModel: SignedContractViewModel
  private var updatedContentOffset = false

  // MARK: - Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindToViewModel()
    viewModel.loadData()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !updatedContentOffset {
      updatedContentOffset = true
      scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: false)
    }
  }
  
  // MARK: - Init
  
  init(viewModel: SignedContractViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  func handleEmptyViewRefreshButtonTapped() {
    viewModel.refresh()
  }
  
  func handleRequestStarted(shouldShowActivityIndicator: Bool) {
    scrollView.isHidden = true
  }
  
  func reloadViews() {
    scrollView.isHidden = false
    setupScreen()

    deliveryInfoView.configure(address: viewModel.deliveryAddress, date: viewModel.deliveryDate)
    barcodeView.configure(contractNumber: viewModel.contractNumber,
                          title: R.string.signedContract.pickupBarcodeTitle(),
                          additionalInfo: [R.string.signedContract.pickupBarcodeSmsInfoText()])
    storeInfoView.configure(storePointInfo: viewModel.storePointInfo)
    titleLabel.text = viewModel.title
    let signingState: DocumentPDFViewSigningState = viewModel.isDeliveryActSigned ? .signed : .notSigned
    agreementPDFView.configure(type: .agreement, signingState: signingState)
    additionalInfoLabel.isHidden = !viewModel.isDeliveryActSigned
    confirmationButton.setTitle(viewModel.confirmationButtonTitle, for: .normal)
  }
  
  // MARK: - Actions
  
  @objc private func didTapCancelContract() {
    showCancelContractAlert()
  }
  
  @objc private func didTapConfirmationButton() {
    viewModel.proceed()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupNavigationBarView(title: R.string.signedContract.screenTitle()) { [weak self] in
      guard let self = self else { return }
      self.delegate?.signedContractViewControllerDidFinish(self)
    }
    setupScrollView()
    setupContainerView()
    setupStackView()
    setupConfirmationButton()
    setupCancelContractButton()
    addActivityIndicatorView()
    addErrorEmptyView()
  }
  
  private func setupScreen() {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    setupTitleLabel()
    setupContractPDFView()
    
    switch viewModel.deliveryType {
    case .delivery, .deliveryPartner:
      setupAgreementPDFView()
      setupDeliveryInfoView()
    case .pickup:
      stackView.setCustomSpacing(24, after: contractPDFView)
      setupBarcodeView()
      setupStoreInfoView()
    }
    
    setupAdditionalInfoLabel()
  }
  
  private func setupContainerView() {
    scrollView.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
      make.width.equalTo(view).offset(-40)
      make.height.greaterThanOrEqualTo(view).offset(-navigationBarView.titleViewMaxY - scrollView.contentInset.top)
    }
  }
  
  private func setupStackView() {
    containerView.addSubview(stackView)
    stackView.axis = .vertical
    stackView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupTitleLabel() {
    stackView.addArrangedSubview(titleLabel)
    titleLabel.numberOfLines = 0
    stackView.setCustomSpacing(24, after: titleLabel)
  }
  
  private func setupContractPDFView() {
    stackView.addArrangedSubview(contractPDFView)
    contractPDFView.configure(type: .contract, signingState: .signed)
    contractPDFView.onDidTapButton = { [weak self] in
      self?.viewModel.showContractPDF()
    }
  }
  
  private func setupAgreementPDFView() {
    stackView.addArrangedSubview(agreementPDFView)
    agreementPDFView.configure(type: .agreement, signingState: .notSigned)
    agreementPDFView.onDidTapButton = { [weak self] in
      self?.viewModel.showAgreementPDF()
    }
    stackView.setCustomSpacing(24, after: agreementPDFView)
  }
  
  private func setupDeliveryInfoView() {
    stackView.addArrangedSubview(deliveryInfoView)
    stackView.setCustomSpacing(24, after: deliveryInfoView)
  }
  
  private func setupBarcodeView() {
    stackView.addArrangedSubview(barcodeView)
    stackView.setCustomSpacing(24, after: barcodeView)
  }
  
  private func setupStoreInfoView() {
    stackView.addArrangedSubview(storeInfoView)
    stackView.setCustomSpacing(24, after: storeInfoView)
    storeInfoView.onTapSelectOtherStore = { [weak self] in
      self?.viewModel.selectOtherStore()
    }
    storeInfoView.onNeedsToPresentViewController = { [weak self] viewController in
      self?.present(viewController, animated: true, completion: nil)
    }
  }
  
  private func setupAdditionalInfoLabel() {
    stackView.addArrangedSubview(additionalInfoLabel)
    additionalInfoLabel.numberOfLines = 0
    switch viewModel.deliveryType {
    case .delivery, .deliveryPartner:
      additionalInfoLabel.isHidden = true
      additionalInfoLabel.text = R.string.signedContract.deliveryAdditionalInfoText()
    case .pickup:
      additionalInfoLabel.isHidden = false
      additionalInfoLabel.text = R.string.signedContract.pickupAdditionalInfoText()
    }
  }
  
  private func setupConfirmationButton() {
    containerView.addSubview(confirmationButton)
    confirmationButton.addTarget(self, action: #selector(didTapConfirmationButton), for: .touchUpInside)
    confirmationButton.snp.makeConstraints { make in
      make.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(24)
      make.top.equalTo(stackView.snp.bottom).offset(24).priority(250)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupCancelContractButton() {
    containerView.addSubview(cancelContractButton)
    cancelContractButton.setTitle(R.string.signedContract.deliveryCancelContractButtonTitle(), for: .normal)
    cancelContractButton.addTarget(self, action: #selector(didTapCancelContract), for: .touchUpInside)
    cancelContractButton.snp.makeConstraints { make in
      make.top.equalTo(confirmationButton.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(40)
    }
  }
  
  // MARK: - ViewModel
  
  private func bindToViewModel() {
    bind(to: viewModel)
  }
  
  // MARK: - Private methods
  
  private func showCancelContractAlert() {
    let alertController = BaseAlertViewController()
    let popupView = PopupAlertView(viewModel.cancelContractAlertTitle)
    let agreeButton = StandardButton(type: .primary)
    agreeButton.setTitle(R.string.common.yes(), for: .normal)
    agreeButton.actionHandler(controlEvents: .touchUpInside) { [weak self, weak alertController] in
      self?.viewModel.cancelContract()
      alertController?.dismiss(animated: true, completion: nil)
    }
    let cancelButton = StandardButton(type: .secondary)
    cancelButton.setTitle(R.string.common.cancel(), for: .normal)
    cancelButton.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
      alertController?.dismiss(animated: true, completion: nil)
    }
    popupView.addButton(agreeButton)
    popupView.addButton(cancelButton)
    alertController.addPopupAlert(popupView)
    present(alertController, animated: true, completion: nil)
  }
}

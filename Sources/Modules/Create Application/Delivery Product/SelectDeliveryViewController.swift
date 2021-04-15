//
//  SelectDeliveryViewController.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

protocol SelectDeliveryViewControllerDelegate: class {
  func selectDeliveryViewControllerDidRequestGoBack(_ viewController: SelectDeliveryViewController)
}

class SelectDeliveryViewController: RegularNavBarViewController, TextInputContaining,
                                    PartialTextInputContaining, TextInputSuggestionsContaining,
                                    ErrorEmptyViewDisplaying, ActivityIndicatorEmptyViewPresenting {
  // MARK: - Types
  typealias ContainerFieldType = AddressFieldType

  // MARK: - Outlets
  var errorViewParent: UIView {
    return view
  }
  let errorEmptyView = ErrorEmptyView()
  var suggestionsListView: SuggestionListView?
  let contentView = UIView()
  let textInputStackView = UIStackView()
  let activityIndicatorContainer = UIView()
  let activityIndicator = ActivityIndicatorView(title: R.string.common.loading())
  
  private let deliveryContainer = UIView()
  private let deliveryTitleLabel = AttributedLabel(textStyle: .title2Bold)
  private let titleContainer = UIStackView()
  private let titleLabel = AttributedLabel(textStyle: .title2Bold)
  private let segmentedControl = SegmentedControl()
  private let deliveryInfoView = DeliveryInfoView()
  private let continueButton = StandardButton(type: .primary)
  private let cancelContractButton = StandardButton(type: .clear)
  private let pickupLabel = AttributedLabel(textStyle: .title3Regular)
  private var spacerHeight: Constraint?
  private let spacerView = UIView()
  private var didSetHeightConstraint: Bool = false
  
  // MARK: - Keyboard visibility
  var keyboardWillShowNotificationToken: NSObjectProtocol?
  var keyboardWillHideNotificationToken: NSObjectProtocol?
  var keyboardWillChangeFrameNotificationToken: NSObjectProtocol?
  
  // MARK: - Properties
  var textInputContainers: [(textInput: TextInput, type: AddressFieldType)] = []
  var currentKeyboardHeight: CGFloat = 0
  var suggestionsListBottomConstraintItem: ConstraintItem?
  var needsResizeSuggestions: Bool {
    return viewModel.needsResizeSuggestions
  }
  
  weak var delegate: SelectDeliveryViewControllerDelegate?
  
  private let viewModel: SelectDeliveryViewModel
  
  // MARK: - Init
  
  init(viewModel: SelectDeliveryViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
    viewModel.load()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updateContinueButtonTopConstraintIfNeeded()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    subscribeForKeyboardNotifications()
    view.setNeedsLayout()
    view.layoutIfNeeded()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupNavigationBarView(title: R.string.deliveryProduct.selectTitle()) { [weak self] in
      guard let self = self else { return }
      self.delegate?.selectDeliveryViewControllerDidRequestGoBack(self)
    }
    setupScrollView()
    setupContentView()
    setupTitleContainer()
    setupTitleLabel()
    setupSegmentedControl()
    setupDeliveryContainer()
    setupDeliveryTitleLabel()
    setupTextInputs()
    setupDeliveryInfoView()
    setupSpacerView()
    setupContinueButton()
    setupCancelContractButton()
    setupPickupLabel()
    setupActivityIndicator()
    addErrorEmptyView()
  }
  
  private func updateContinueButtonTopConstraintIfNeeded() {
    contentView.snp.remakeConstraints { make in
      make.height.greaterThanOrEqualToSuperview()
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
    let contentViewHeight = contentView.bounds.height 
    guard contentViewHeight < scrollView.bounds.height, contentView.bounds.height != 0, !didSetHeightConstraint else {
      return
    }
    let height = scrollView.bounds.height - contentViewHeight
    spacerHeight?.update(offset: height)
    didSetHeightConstraint = true
    view.setNeedsLayout()
    view.layoutIfNeeded()
  }
  
  private func bind() {
    viewModel.onDidUpdateValidity = { [weak self, weak viewModel] in
      guard let viewModel = viewModel else { return }
      self?.continueButton.isEnabled = viewModel.isContinueEnabled
    }
    viewModel.onDidRequestShowAddresses = { [weak self] in
      guard let self = self else { return }
      self.showSuggestions(with: self.viewModel.addressListViewModel)
    }
    viewModel.onDidRequestHideAddresses = { [weak self] in
      self?.hideAddressList()
    }
    viewModel.onNeedsResizeSuggestionsList = { [weak self] in
      self?.handleSuggestionsResize()
    }
    viewModel.onDidStartInitialLoadingRequest = { [weak self] in
      self?.setupLoadingDeliveryTypesState()
    }
    viewModel.onDidFinishInitialLoadingRequest = { [weak self] in
      self?.setupNormalState()
      self?.textInputContainers.forEach {
        $0.textInput.updateTextEditAppearance()
      }
    }
    viewModel.onDidStartSaveDeliveryTypeRequest = { [weak self] in
      self?.continueButton.startAnimating()
      self?.view.isUserInteractionEnabled = false
    }
    viewModel.onDidFinishSaveDeliveryTypeRequest = { [weak self] in
      self?.continueButton.stopAnimating()
      self?.view.isUserInteractionEnabled = true
    }
    viewModel.onDidStartCancelDeliveryRequest = { [weak self] in
      self?.cancelContractButton.startAnimating()
      self?.view.isUserInteractionEnabled = false
    }
    viewModel.onDidFinishCancelDeliveryRequest = { [weak self] in
      self?.cancelContractButton.stopAnimating()
      self?.view.isUserInteractionEnabled = true
    }
    viewModel.onDidUpdateDeliveryType = { [weak self] in
      self?.updateDeliveryType()
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.handle(selectDeliveryError: error)
    }
    viewModel.onDidUpdateDeliveryInfoVisibility = { [weak self] in
      guard let self = self else { return }
      self.deliveryInfoView.isHidden = self.viewModel.isHiddenDeliveryInfo
    }
  }
  
  private func handle(selectDeliveryError: SelectDeliveryError) {
    view.isUserInteractionEnabled = true
    switch selectDeliveryError {
    case .productDelivery:
      handle(error: selectDeliveryError, refreshButtonTitle: R.string.deliveryProduct.selectAnotherAddressButtonTitle())
    case .goodUnavailable:
      setupGoodUnavailableState()
    }
  }
}

// MARK: - Error empty view displaying
extension SelectDeliveryViewController {
  func handleEmptyViewRefreshButtonTapped() {
    hideErrorEmptyView()
    setupNormalState()
  }
}

// MARK: - Setup states
extension SelectDeliveryViewController {
  private func setupLoadingDeliveryTypesState() {
    navigationBarView.isHidden = true
    showActivityIndicator()
    activityIndicator.isAnimating = true
  }
  
  private func setupNormalState(isLoadingDeliveryInfo: Bool = false) {
    navigationBarView.isHidden = false
    titleLabel.text = viewModel.selectDeliveryTitle
    setupDeliveryOrPickupPage()
    segmentedControl.isHidden = !viewModel.isBothDeliveryType
    hideActivityIndicator()
  }
  
  private func setupGoodUnavailableState() {
    navigationBarView.isHidden = false
    titleLabel.text = viewModel.selectDeliveryTitle
    deliveryContainer.isHidden = true
    segmentedControl.isHidden = true
    hideActivityIndicator()
    pickupLabel.isHidden = true
    continueButton.setTitle(viewModel.continueButtonTitle, for: .normal)
  }
  
  private func setupDeliveryOrPickupPage() {
    deliveryContainer.isHidden = viewModel.selectedDeliveryType == .pickup
    pickupLabel.isHidden = viewModel.selectedDeliveryType == .delivery
  }
  
  private func updateDeliveryType() {
    setupDeliveryOrPickupPage()
    segmentedControl.setSelectedIndex(viewModel.selectedDeliveryIndex,
                                      animated: false, shouldSendAction: false)
    continueButton.setTitle(viewModel.continueButtonTitle, for: .normal)
    setupNormalState()
  }
  
  private func showCancelContractAlert() {
    let alertController = BaseAlertViewController()
    let popup = PopupAlertView(R.string.signedContract.cancelContractAlertTitle())
    alertController.addPopupAlert(popup)
    
    let confirmButton = StandardButton(type: .primary)
    confirmButton.setTitle(R.string.common.yes(), for: .normal)
    confirmButton.actionHandler(controlEvents: .touchUpInside) { [weak self, weak alertController] in
      self?.viewModel.cancelContract()
      alertController?.dismiss(animated: true, completion: nil)
    }
    popup.addButton(confirmButton)
    
    let cancelButton = StandardButton(type: .secondary)
    cancelButton.setTitle(R.string.common.cancel(), for: .normal)
    cancelButton.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
      alertController?.dismiss(animated: true, completion: nil)
    }
    popup.addButton(cancelButton)
    
    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - Setup subviews
extension SelectDeliveryViewController {
  private func setupContentView() {
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.width.equalToSuperview()
    }
  }
  
  private func setupTitleContainer() {
    contentView.addSubview(titleContainer)
    titleContainer.axis = .vertical
    titleContainer.spacing = 24
    titleContainer.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(navigationBarView.maskArcHeight + 24)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupTitleLabel() {
    titleContainer.addArrangedSubview(titleLabel)
    titleLabel.text = R.string.deliveryProduct.selectTitleLabelText()
    titleLabel.textColor = .base1
    titleLabel.numberOfLines = 0
  }
  
  private func setupSegmentedControl() {
    titleContainer.addArrangedSubview(segmentedControl)
    segmentedControl.setTabs(titles: viewModel.segmentedControlTitles)
    segmentedControl.addTarget(self, action: #selector(didChangeDeliveryType(_:)), for: .valueChanged)
  }
  
  private func setupDeliveryContainer() {
    contentView.addSubview(deliveryContainer)
    deliveryContainer.snp.makeConstraints { make in
      make.top.equalTo(titleContainer.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupDeliveryTitleLabel() {
    deliveryContainer.addSubview(deliveryTitleLabel)
    deliveryTitleLabel.textColor = .base1
    deliveryTitleLabel.text = R.string.deliveryProduct.selectDeliveryTitle()
    deliveryTitleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func setupTextInputs() {
    deliveryContainer.addSubview(textInputStackView)
    textInputStackView.axis = .vertical
    textInputStackView.snp.makeConstraints { make in
      make.top.equalTo(deliveryTitleLabel.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
    }
    setupTextFields(with: viewModel.addressConfigurators, configureTextInput: makeConfigureTextInputClosure())
  }
  
  private func makeConfigureTextInputClosure() -> ((FieldConfigurator<ContainerFieldType>, UIView, UIStackView?) -> Void)? {
    return { [weak self] configurator, textInputContainer, horizontalStackView in
      guard let self = self else { return }
      switch configurator.type.textInputLayoutType {
      case .partialWidthFixed:
        guard configurator.type == .apartmentNumber else { break }
        textInputContainer.isHidden = self.viewModel.isHiddenApartmentNumberField
        if let horizontalStackView = horizontalStackView {
          self.suggestionsListBottomConstraintItem = horizontalStackView.snp.bottom
        }
        self.viewModel.onDidRequestUpdateApartmentNumberField = { [weak self] in
          guard let self = self else { return }
          textInputContainer.isHidden = self.viewModel.isHiddenApartmentNumberField
          if textInputContainer.isHidden {
            configurator.update(text: nil)
          }
          horizontalStackView?.setNeedsLayout()
          self.view.layoutIfNeeded()
        }
      default:
        break
      }
      configurator.onDidBeginEditing = { [weak self, weak configurator] textInput in
        self?.moveScroll(to: textInput)
        if configurator?.type == .deliveryAddress {
          self?.viewModel.beginEditingRegistrationAddress()
        } else if configurator?.type == .apartmentNumber {
          self?.viewModel.handleApartmentBeginEditing()
        }
      }
    }
  }
  
  private func setupDeliveryInfoView() {
    deliveryContainer.addSubview(deliveryInfoView)
    deliveryInfoView.configure(with: viewModel.deliveryInfoViewModel)
    deliveryInfoView.snp.makeConstraints { make in
      make.top.equalTo(textInputStackView.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
  
  private func setupSpacerView() {
    contentView.addSubview(spacerView)
    spacerView.snp.makeConstraints { make in
      make.top.equalTo(deliveryContainer.snp.bottom)
      make.leading.trailing.equalToSuperview()
      spacerHeight = make.height.equalTo(24).constraint
    }
  }
  
  private func setupContinueButton() {
    contentView.addSubview(continueButton)
    continueButton.setTitle(R.string.common.continue(), for: .normal)
    continueButton.actionHandler(controlEvents: .touchUpInside) { [weak self] in
      self?.viewModel.continueWithSelectedDelivery()
    }
    continueButton.snp.makeConstraints { make in
      make.top.equalTo(spacerView.snp.bottom)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupCancelContractButton() {
    contentView.addSubview(cancelContractButton)
    cancelContractButton.setTitle(R.string.deliveryProduct.cancelContractButtonTitle(), for: .normal)
    cancelContractButton.actionHandler(controlEvents: .touchUpInside) { [weak self] in
      self?.showCancelContractAlert()
    }
    cancelContractButton.snp.makeConstraints { make in
      make.top.equalTo(continueButton.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(56)
    }
  }
  
  private func setupPickupLabel() {
    contentView.addSubview(pickupLabel)
    pickupLabel.numberOfLines = 0
    pickupLabel.textAlignment = .center
    pickupLabel.textColor = .base1
    pickupLabel.text = R.string.deliveryProduct.selectPickupLabelText()
    pickupLabel.snp.makeConstraints { make in
      make.top.equalTo(segmentedControl.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  // MARK: - Actions
  @objc func didChangeDeliveryType(_ sender: SegmentedControl) {
    viewModel.selectDeliveryType(with: sender.selectedIndex)
  }
}

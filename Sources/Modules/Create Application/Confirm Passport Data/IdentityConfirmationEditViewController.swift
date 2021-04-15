//
//  IdentityConfirmationEditViewController.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

protocol IdentityConfirmationEditViewControllerDelegate: class {
  func identityConfirmationEditViewControllerDidRequestGoBack(_ viewController: IdentityConfirmationEditViewController)
  func identityConfirmationEditViewControllerDidRequestRescanPassport(_ viewController: IdentityConfirmationEditViewController)
}

class IdentityConfirmationEditViewController: RegularNavBarViewController, TextInputContaining,
                                              ErrorEmptyViewDisplaying, PartialTextInputContaining,
                                              TextInputSuggestionsContaining {

  typealias ContainerFieldType = IdentityConfirmationEditFieldType
  
  // MARK: - Subviews
  let textInputStackView = UIStackView()
  let errorEmptyView = ErrorEmptyView()

  var needsResizeSuggestions: Bool {
    return viewModel.needsResizeSuggestions
  }
  
  let contentView = UIView()
  var suggestionsListView: SuggestionListView?
  private let letsCheckLabel = AttributedLabel(textStyle: .title2Bold)
  private let photoImageView = UIImageView()
  private let confirmCheckButton = StandardButton(type: .primary)
  private let repeatScanButton = StandardButton(type: .clear)
  private let activityIndicatorContainerView = UIView()
  private let activityIndicatorView = ActivityIndicatorView(color: .accent)

  // MARK: - Properties
  var suggestionsListBottomConstraintItem: ConstraintItem?
  var isUpdatingBottomInsetWithAnimation: Bool {
    return true
  }
  var keyboardWillShowNotificationToken: NSObjectProtocol?
  var keyboardWillHideNotificationToken: NSObjectProtocol?
  var keyboardWillChangeFrameNotificationToken: NSObjectProtocol?
  var textInputContainers: [(textInput: TextInput, type: IdentityConfirmationEditFieldType)] = []
  var currentKeyboardHeight: CGFloat = 0

  weak var delegate: IdentityConfirmationEditViewControllerDelegate?

  private let viewModel: IdentityConfirmationEditViewModel
  
  // MARK: - Init
  init(viewModel: IdentityConfirmationEditViewModel) {
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
    viewModel.setup()
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

  // MARK: - ErrorEmptyViewDisplaying
  func handleErrorEmptyViewHiddenStateChanged(isHidden: Bool) {
    if !isHidden {
      navigationBarView.setState(isCollapsed: false, animated: false)
      scrollView.setContentOffset(.zero, animated: false)
    }
  }

  func handleEmptyViewRefreshButtonTapped() {
    viewModel.retry()
  }
  
  // MARK: - Private Methods
    
  private func setup() {
    setupNavigationBarView(title: viewModel.title) { [weak self] in
      guard let self = self else { return }
      self.delegate?.identityConfirmationEditViewControllerDidRequestGoBack(self)
    }
    setupScrollView()
    setupContentView()
    setupLetsCheckLabel()
    setupPhotoImageView()
    setupStackView()
    setupTextFields()
    setupConfirmCheckButton()
    setupRepeatScanButton()
    addErrorEmptyView()
    setupActivityIndicatorContainerView()
    view.bringSubviewToFront(navigationBarView)
  }
  
  private func bind() {
    viewModel.onDidUpdateValidity = { [weak self, weak viewModel] in
      guard let viewModel = viewModel else { return }
      self?.confirmCheckButton.isEnabled = viewModel.isEnabledCheckButton
    }
    viewModel.onDidRequestShowAddresses = { [weak self] in
      guard let self = self else { return }
      self.showSuggestions(with: self.viewModel.addressListViewModel)
    }
    viewModel.onDidRequestHideAddresses = { [weak self] in
      self?.hideAddressList()
    }
    viewModel.onNeedsResizeSuggestionList = { [weak self] in
      self?.handleSuggestionsResize()
    }
    viewModel.onDidStartRequest = { [weak self] in
      self?.confirmCheckButton.startAnimating()
      self?.errorEmptyView.startAnimating()
      self?.textInputStackView.isUserInteractionEnabled = false
      self?.repeatScanButton.isUserInteractionEnabled = false
    }
    viewModel.onDidFinishRequest = { [weak self] in
      self?.confirmCheckButton.stopAnimating()
      self?.errorEmptyView.stopAnimating()
      self?.textInputStackView.isUserInteractionEnabled = true
      self?.repeatScanButton.isUserInteractionEnabled = true
    }
    viewModel.onNeedsToHideErrorView = { [weak self] in
      self?.hideErrorEmptyView()
    }
    viewModel.onDidRequestToShowEmptyErrorView = { [weak self] error in
      self?.scrollView.setContentOffset(.zero, animated: false)
      self?.navigationBarView.setState(isCollapsed: false, animated: false)
      self?.handle(dataDefiningError: error)
    }
    viewModel.onDidStartInitialRequest = { [weak self] in
      self?.activityIndicatorContainerView.isHidden = false
      self?.activityIndicatorView.startAnimating()
    }
    viewModel.onDidFinishInitialRequest = { [weak self] in
      self?.activityIndicatorContainerView.isHidden = true
      self?.activityIndicatorView.stopAnimating()
    }
    viewModel.onDidUpdateData = { [weak self] in
      self?.updateViews()
    }
    viewModel.onDidRequestToShowHardcheckerError = { [weak self] message in
      self?.showHardcheckerError(message: message)
    }
  }
  
  private func setupContentView() {
    scrollView.addSubview(contentView)
    scrollView.showsVerticalScrollIndicator = false
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.greaterThanOrEqualToSuperview()
      make.width.equalToSuperview()
    }
  }
  
  private func setupLetsCheckLabel() {
    contentView.addSubview(letsCheckLabel)
    letsCheckLabel.textColor = .base1
    letsCheckLabel.text = R.string.passportDataConfirmation.letsCheckTitle()
    letsCheckLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(navigationBarView.maskArcHeight + 24)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupPhotoImageView() {
    guard viewModel.hasPassportPhoto || viewModel.hasUserPhoto else {
      return
    }
    contentView.addSubview(photoImageView)
    photoImageView.clipsToBounds = true
    photoImageView.contentMode = .scaleAspectFill
    photoImageView.snp.makeConstraints { make in
      make.top.equalTo(letsCheckLabel.snp.bottom).offset(24)
      make.size.equalTo(136)
      make.leading.equalToSuperview().inset(20)
    }
    
    if viewModel.hasUserPhoto {
      photoImageView.setImage(with: viewModel.userPhotoURL)
    } else {
      photoImageView.image = viewModel.passportPhoto
    }
  }
  
  private func setupStackView() {
    contentView.addSubview(textInputStackView)
    textInputStackView.axis = .vertical
    textInputStackView.snp.makeConstraints { make in
      if viewModel.hasPassportPhoto {
        make.top.equalTo(photoImageView.snp.bottom).offset(25)
      } else {
        make.top.equalTo(letsCheckLabel.snp.bottom).offset(25)
      }
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupConfirmCheckButton() {
    contentView.addSubview(confirmCheckButton)
    confirmCheckButton.isEnabled = viewModel.isEnabledCheckButton
    confirmCheckButton.setTitle(R.string.passportDataConfirmation.checkButtonTitle(), for: .normal)
    confirmCheckButton.addTarget(self, action: #selector(handleFinishButtonTapped(_:)), for: .touchUpInside)
    confirmCheckButton.snp.makeConstraints { make in
      make.top.equalTo(textInputStackView.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupRepeatScanButton() {
    contentView.addSubview(repeatScanButton)
    repeatScanButton.setTitle(R.string.passportDataConfirmation.repeatScanButtonTitle(), for: .normal)
    repeatScanButton.titleLabel?.adjustsFontSizeToFitWidth = true
    repeatScanButton.addTarget(self, action: #selector(handleRepeatScanButtonTapped(_:)), for: .touchUpInside)
    repeatScanButton.snp.makeConstraints { make in
      make.top.equalTo(confirmCheckButton.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(32)
      make.bottom.equalToSuperview().inset(40)
    }
  }

  private func setupActivityIndicatorContainerView() {
    view.addSubview(activityIndicatorContainerView)
    activityIndicatorContainerView.snp.makeConstraints { make in
      make.edges.equalTo(errorViewParent)
    }
    activityIndicatorContainerView.addSubview(activityIndicatorView)
    activityIndicatorView.snp.makeConstraints { make in
      make.centerY.equalToSuperview().offset(navigationBarView.maskArcHeight)
      make.centerX.equalToSuperview()
    }
    activityIndicatorContainerView.isHidden = true
    activityIndicatorContainerView.backgroundColor = .base2
  }

  private func updateViews() {
    textInputContainers.forEach {
      $0.textInput.updateTextEditAppearance()
    }
    if viewModel.hasUserPhoto {
      photoImageView.setImage(with: viewModel.userPhotoURL)
    } else {
      photoImageView.image = viewModel.passportPhoto
    }
  }
  
  private func showHardcheckerError(message: String?) {
    let alertController = BaseAlertViewController(closesOnBackgroundTap: false)
    let popup = PopupAlertView(message)
    alertController.addPopupAlert(popup)
    
    let okButton = StandardButton(type: .primary)
    okButton.setTitle(R.string.common.ok(), for: .normal)
    okButton.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
      alertController?.dismiss(animated: true) { [weak self] in
        self?.viewModel.forceFinishFlow()
      }
    }
    popup.addButton(okButton)
    
    present(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Actions
  
  @objc private func handleFinishButtonTapped(_ sender: UIButton) {
    view.endEditing(true)
    viewModel.finish()
  }
  
  @objc private func handleRepeatScanButtonTapped(_ sender: UIButton) {
    view.endEditing(true)
    delegate?.identityConfirmationEditViewControllerDidRequestRescanPassport(self)
  }
}

// MARK: - Setup text inputs

extension IdentityConfirmationEditViewController {
  private func setupTextFields() {
    setupTextFields(with: viewModel.textEditConfigurators, configureTextInput: makeConfigureTextInputClosure())
    textInputStackView.layoutIfNeeded()
    contentView.layoutIfNeeded()
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
      if configurator.type == .registrationAddress {
        configurator.onDidBeginEditing = { [weak self] textInput in
          self?.moveScroll(to: textInput)
          self?.viewModel.beginEditingRegistrationAddress()
        }
      }
    }
  }
}

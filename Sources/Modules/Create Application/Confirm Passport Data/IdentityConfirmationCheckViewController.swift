//
//  IdentityConfirmationCheckViewController.swift
//  ForwardLeasing
//

import UIKit

protocol IdentityConfirmationCheckViewControllerDelegate: class {
  func identityConfirmationCheckViewControllerDidRequestGoBack(_ controller: IdentityConfirmationCheckViewController)
}

class IdentityConfirmationCheckViewController: RegularNavBarViewController, ErrorEmptyViewDisplaying, TextInputContaining {
  typealias ContainerFieldType = IdentityConfirmationEditFieldType

  // MARK: - Outlets
  var keyboardWillShowNotificationToken: NSObjectProtocol?
  var keyboardWillHideNotificationToken: NSObjectProtocol?
  var keyboardWillChangeFrameNotificationToken: NSObjectProtocol?
  var textInputContainers: [(textInput: TextInput, type: IdentityConfirmationEditFieldType)] = []
  var currentKeyboardHeight: CGFloat = 0

  let errorEmptyView = ErrorEmptyView()
  let textInputStackView = UIStackView()

  private let contentView = UIView()
  private let letsCheckLabel = AttributedLabel(textStyle: .title2Bold)
  private let photoImageView = UIImageView()
  private let userDataStackView = UIStackView()
  private let confirmCheckButton = StandardButton(type: .primary)
  private let repeatScanButton = StandardButton(type: .clear)
  
  // MARK: - Properties
  weak var delegate: IdentityConfirmationCheckViewControllerDelegate?
  
  private let viewModel: IdentityConfirmationCheckViewModel
  
  // MARK: - Init
  init(viewModel: IdentityConfirmationCheckViewModel) {
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
    viewModel.confirmCheck()
  }

  // MARK: - Private Methods
  private func setup() {
    setupNavigationBarView(title: viewModel.title) { [weak self] in
      guard let self = self else { return }
      self.delegate?.identityConfirmationCheckViewControllerDidRequestGoBack(self)
    }
    setupScrollView()
    setupContentView()
    setupLetsCheckLabel()
    setupPhotoImageView()
    setupUserDataStackView()
    setupTextInputStackView()
    setupConfirmCheckButton()
    setupRepeatScanButton()
    addErrorEmptyView()
  }
  
  private func bind() {
    viewModel.onDidUpdateValidity = { [weak self, weak viewModel] in
      guard let viewModel = viewModel else { return }
      self?.confirmCheckButton.isEnabled = viewModel.isEnabledCheckButton
    }
    viewModel.onDidUpdateItems = { [weak self] in
      self?.updateUserDataItems()
      self?.updateTextInputs()
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
    viewModel.onDidRequestToShowEmptyErrorView = { [weak self] error in
      self?.scrollView.setContentOffset(.zero, animated: false)
      self?.navigationBarView.setState(isCollapsed: false, animated: false)
      self?.handle(dataDefiningError: error)
    }
    viewModel.onNeedsToHideErrorView = { [weak self] in
      self?.hideErrorEmptyView()
    }
  }
  
  private func setupContentView() {
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.height.greaterThanOrEqualToSuperview()
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
  }
  
  private func setupLetsCheckLabel() {
    contentView.addSubview(letsCheckLabel)
    letsCheckLabel.textColor = .base1
    letsCheckLabel.text = R.string.passportDataConfirmation.letsCheckTitle()
    letsCheckLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupPhotoImageView() {
    guard viewModel.hasUserPhoto else { return }
    contentView.addSubview(photoImageView)
    photoImageView.clipsToBounds = true
    photoImageView.contentMode = .scaleAspectFill
    photoImageView.setImage(with: viewModel.userPhotoURL, authToken: viewModel.accessToken)
    photoImageView.snp.makeConstraints { make in
      make.top.equalTo(letsCheckLabel.snp.bottom).offset(24)
      make.leading.equalToSuperview().inset(20)
      make.size.equalTo(136)
    }
  }
  
  private func setupUserDataStackView() {
    contentView.addSubview(userDataStackView)
    userDataStackView.axis = .vertical
    userDataStackView.spacing = 16
    userDataStackView.snp.makeConstraints { make in
      if viewModel.hasUserPhoto {
        make.top.equalTo(photoImageView.snp.bottom).offset(16)
      } else {
        make.top.equalTo(letsCheckLabel.snp.bottom).offset(16)
      }
      make.leading.trailing.equalToSuperview()
    }
  }

  private func setupTextInputStackView() {
    contentView.addSubview(textInputStackView)
    textInputStackView.axis = .vertical
    textInputStackView.spacing = 25
    textInputStackView.snp.makeConstraints { make in
      make.top.equalTo(userDataStackView.snp.bottom).offset(22)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }

  private func updateTextInputs() {
    textInputStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    viewModel.textEditConfigurators.forEach {
      let textInput = createTextInput(for: $0)
      textInputStackView.addArrangedSubview(textInput)
    }
  }

  private func updateUserDataItems() {
    userDataStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    viewModel.items.forEach {
      let itemView = UserDataItemView()
      itemView.configure(with: $0)
      let containerView = UIView()
      containerView.addSubview(itemView)
      itemView.snp.makeConstraints { make in
        make.top.bottom.equalToSuperview()
        make.leading.trailing.equalToSuperview().inset(20)
      }
      userDataStackView.addArrangedSubview(containerView)
    }
  }
  
  private func setupConfirmCheckButton() {
    contentView.addSubview(confirmCheckButton)
    confirmCheckButton.setTitle(R.string.passportDataConfirmation.checkButtonTitle(),
                                for: .normal)
    confirmCheckButton.addTarget(self, action: #selector(didTapCofirmCheck), for: .touchUpInside)
    confirmCheckButton.snp.makeConstraints { make in
      make.top.equalTo(textInputStackView.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupRepeatScanButton() {
    contentView.addSubview(repeatScanButton)
    repeatScanButton.setTitle(R.string.passportDataConfirmation.changePassportScanButtonTitle(),
                              for: .normal)
    repeatScanButton.addTarget(self, action: #selector(didTapRepeatScan), for: .touchUpInside)
    repeatScanButton.titleLabel?.numberOfLines = 2
    repeatScanButton.titleLabel?.textAlignment = .center
    repeatScanButton.snp.makeConstraints { make in
      make.top.equalTo(confirmCheckButton.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(32)
      make.bottom.equalToSuperview().inset(56)
    }
  }
  
  // MARK: - Actions
  @objc private func didTapCofirmCheck() {
    viewModel.confirmCheck()
  }
  
  @objc private func didTapRepeatScan() {
    viewModel.repeatScan()
  }
}

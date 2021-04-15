//
//  PinCodeRecoveryViewController.swift
//  ForwardLeasing
//

import UIKit

protocol PinCodeRecoveryViewControllerDelegate: class {
  func pinCodeRecoveryViewControllerDidRequestGoBack(_ viewController: PinCodeRecoveryViewController)
}

class PinCodeRecoveryViewController: BaseViewController, TextInputContaining,
                                     ActivityIndicatorPresenting, NavigationBarHiding {
  typealias ContainerFieldType = RecoveryPinFieldType
  
  // MARK: - Keyboard visibility
  var keyboardWillShowNotificationToken: NSObjectProtocol?
  var keyboardWillHideNotificationToken: NSObjectProtocol?
  var keyboardWillChangeFrameNotificationToken: NSObjectProtocol?
  
  // MARK: - TextInputContaining
  let scrollView = UIScrollView()
  var textInputStackView = UIStackView()
  var textInputContainers: [(textInput: TextInput, type: RecoveryPinFieldType)] = []
  var currentKeyboardHeight: CGFloat = 0
  
  weak var delegate: PinCodeRecoveryViewControllerDelegate?
  
  // MARK: - Subviews
  private let navigationBarView = NavigationBarView()
  private lazy var phoneField = createTextInput(for: viewModel.textInputConfigurator)
  private let subtitleLabel = AttributedLabel(textStyle: .title3Regular)
  private let continueButton = StandardButton(type: .primary)
  
  // MARK: - View Model
  private let viewModel: PinCodeRecoveryViewModel
  
  // MARK: - Init
  
  init(viewModel: PinCodeRecoveryViewModel) {
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
  
  // MARK: - Private Methods
  private func setup() {
    setupNavigationBarView()
    setupPhoneField()
    setupSubtitleLabel()
    setupContinueButton()
  }
  
  private func bind() {
    viewModel.onDidStartRequest = { [weak self] in
      self?.presentActivtiyIndicator(completion: nil)
    }
    viewModel.onDidSuccessFinishRequest = { [weak self] in
      self?.dismissActivityIndicator {
        self?.viewModel.finish()
      }
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.handle(error: error)
    }
    viewModel.onValidityUpdated = { [weak self] in
      guard let self = self else { return }
      self.continueButton.isEnabled = self.viewModel.isValid
    }
  }
  
  private func setupNavigationBarView() {
    view.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    navigationBarView.configureNavigationBarTitle(title: R.string.auth.pinCodeRecoveryTitle())
    navigationBarView.addBackButton { [weak self] in
      guard let self = self else { return }
      self.delegate?.pinCodeRecoveryViewControllerDidRequestGoBack(self)
    }
  }
  
  private func setupPhoneField() {
    view.addSubview(phoneField)
    phoneField.snp.makeConstraints { make in
      make.top.equalTo(navigationBarView.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupSubtitleLabel() {
    view.addSubview(subtitleLabel)
    subtitleLabel.textAlignment = .center
    subtitleLabel.textColor = .shade70
    subtitleLabel.numberOfLines = 0
    subtitleLabel.text = R.string.auth.pinCodeRecoverySubtitleText()
    subtitleLabel.snp.makeConstraints { make in
      make.top.equalTo(phoneField.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupContinueButton() {
    view.addSubview(continueButton)
    continueButton.setTitle(R.string.common.continue(), for: .normal)
    continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    continueButton.isEnabled = viewModel.isValid
    continueButton.snp.makeConstraints { make in
      make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  @objc private func didTapContinue() {
    viewModel.sendCode()
  }
}

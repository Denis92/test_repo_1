//
//  AuthorizationViewController.swift
//  ForwardLeasing
//

import UIKit

private extension Constants {
  static let scrollViewTopInset: CGFloat = 112
}

class AuthorizationViewController: BaseViewController, NavigationBarHiding,
                                   TextInputContaining {
  typealias ContainerFieldType = AuthorizationFieldType
  
  // MARK: - Properties
  var keyboardWillShowNotificationToken: NSObjectProtocol?
  var keyboardWillHideNotificationToken: NSObjectProtocol?
  var keyboardWillChangeFrameNotificationToken: NSObjectProtocol?
  var currentKeyboardHeight: CGFloat = -0
  var textInputContainers: [(textInput: TextInput, type: AuthorizationFieldType)] = []
  var scrollViewTopInset: CGFloat {
    return Constants.scrollViewTopInset
  }
  
  let navigationBarView = NavigationBarView(type: .titleWithoutContent)
  let scrollView = UIScrollView()
  let textInputStackView = UIStackView()
  
  private let additionalActionsStackView = UIStackView()
  private let forgotPinButton = UIButton(type: .system)
  private let signUpButton = UIButton(type: .system)
  private let signInButton = StandardButton(type: .primary)

  private let viewModel: AuthorizationViewModel
  
  // MARK: - Init
  
  init(viewModel: AuthorizationViewModel) {
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
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    subscribeForKeyboardNotifications()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    unsubscribeFromKeyboardNotifications()
  }
  
  // MARK: - Public methods
  
  func handleKeyboardDoneButtonTapped() {
    viewModel.signIn()
  }
  
  // MARK: - Actions
  
  @objc private func didTapSignInButton() {
    viewModel.signIn()
  }
  
  @objc private func didTapSignUpButton() {
    viewModel.signUp()
  }
  
  @objc private func didTapForgotPasswordButton() {
    viewModel.resetPassword()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupScrollView()
    setupStackView()
    setupTextFields()
    setupAdditionalActionsStackView()
    setupForgotPinButton()
    setupSignUpButton()
    setupSignInButton()
    setupNavigationBarView()
  }
  
  private func setupScrollView() {
    view.addSubview(scrollView)
    scrollView.showsVerticalScrollIndicator = false
    scrollView.alwaysBounceVertical = false
    scrollView.contentInset = UIEdgeInsets(top: Constants.scrollViewTopInset,
                                           left: 0, bottom: 0, right: 0)
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupStackView() {
    scrollView.addSubview(textInputStackView)
    textInputStackView.axis = .vertical
    textInputStackView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(20)
      make.width.equalTo(view).offset(-40)
    }
  }
  
  private func setupTextFields() {
    viewModel.fieldConfigurators.forEach {
      let textField = createTextInput(for: $0)
      if $0.type == .phoneNumber {
        textField.text = viewModel.phoneInitialValue
      }
      textInputStackView.addArrangedSubview(textField)
      textInputStackView.setCustomSpacing($0.type.spacingAfterTextInput, after: textField)
    }
  }
  
  private func setupAdditionalActionsStackView() {
    textInputStackView.addArrangedSubview(additionalActionsStackView)
    additionalActionsStackView.axis = .horizontal
    additionalActionsStackView.distribution = .equalSpacing
    textInputStackView.setCustomSpacing(32, after: additionalActionsStackView)
  }
  
  private func setupForgotPinButton() {
    additionalActionsStackView.addArrangedSubview(forgotPinButton)
    forgotPinButton.setTitle(R.string.authorization.forgotPinButtonTitle(), for: .normal)
    forgotPinButton.setTitleColor(.accent, for: .normal)
    forgotPinButton.titleLabel?.font = .title3Regular
    forgotPinButton.addTarget(self, action: #selector(didTapForgotPasswordButton), for: .touchUpInside)
    forgotPinButton.snp.makeConstraints { make in
      make.height.equalTo(56)
    }
  }
  
  private func setupSignUpButton() {
    additionalActionsStackView.addArrangedSubview(signUpButton)
    signUpButton.setTitle(R.string.authorization.signUpButtonTitle(), for: .normal)
    signUpButton.setTitleColor(.accent, for: .normal)
    signUpButton.titleLabel?.font = .title3Regular
    signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    signUpButton.snp.makeConstraints { make in
      make.height.equalTo(56)
    }
  }
  
  private func setupSignInButton() {
    textInputStackView.addArrangedSubview(signInButton)
    signInButton.isEnabled = false
    signInButton.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
    signInButton.setTitle(R.string.authorization.signInButtonTitle(), for: .normal)
  }
  
  private func setupNavigationBarView() {
    view.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
  }
  
  // MARK: - View Model
  
  private func bindToViewModel() {
    viewModel.onDidUpdate = { [weak self, unowned viewModel] in
      self?.signInButton.isEnabled = viewModel.isValid
    }
    viewModel.onDidStartRequest = { [weak self] in
      self?.signInButton.startAnimating()
    }
    viewModel.onDidFinishRequest = { [weak self] in
      self?.signInButton.stopAnimating()
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.handle(error: error)
    }
  }
}

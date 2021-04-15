//
//  PersonalDataRegisterViewController.swift
//  ForwardLeasing
//

import UIKit

protocol RegisterViewControllerDelegate: class {
  func registerViewControllerDidRequestGoBack(_ viewController: RegisterViewController)
}

class RegisterViewController: RegularNavBarViewController, TextInputContaining,
                              ActivityIndicatorPresenting {
  // MARK: - Types
  typealias ContainerFieldType = AnyFieldType<RegisterFieldType>
  
  // MARK: - Subviews
  let textInputStackView = UIStackView()
  
  var textInputContainers: [(textInput: TextInput, type: ContainerFieldType)] = []
  var currentKeyboardHeight: CGFloat = 0
  weak var delegate: RegisterViewControllerDelegate?
  override var scrollViewAdditionalTopOffset: CGFloat {
    return 0
  }

  var scrollViewTopInset: CGFloat {
    return navigationBarView.maskArcHeight + scrollViewAdditionalTopOffset
  }
  let contentView = UIView()
  
  let agreementContainer = UIStackView()
  private let confirmButton = StandardButton(type: .primary)
  
  // MARK: - Properties
  
  var keyboardWillShowNotificationToken: NSObjectProtocol?
  var keyboardWillHideNotificationToken: NSObjectProtocol?
  var keyboardWillChangeFrameNotificationToken: NSObjectProtocol?
  private let viewModel: RegisterViewModel
  
  // MARK: - Init
  
  init(viewModel: RegisterViewModel) {
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
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    unsubscribeFromKeyboardNotifications()
  }
  // MARK: - Private Methods
  
  private func setup() {
    setupNavigationBarView(title: viewModel.title) { [weak self] in
      guard let self = self else { return }
      self.delegate?.registerViewControllerDidRequestGoBack(self)
    }
    setupScrollView()
    setupContentView()
    setupTextFields()
    setupAgreementContainer()
    setupConfirmButton()
    view.bringSubviewToFront(navigationBarView)
  }
  
  private func bind() {
    viewModel.onValidityUpdate = { [weak self] in
      guard let self = self else { return }
      self.confirmButton.isEnabled = self.viewModel.isValid
    }
    viewModel.onDidStartRequest = { [weak self] in
      self?.presentActivtiyIndicator(completion: nil)
    }
    viewModel.onDidFinishRequest = { [weak self] competion in
      self?.dismiss(animated: true, completion: competion)
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.dismissActivityIndicator {
        self?.handle(error: error)
      }
    }
  }

  private func setupContentView() {
    scrollView.addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
    }
  }
  
  private func setupNavigationBarView() {
    view.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.leading.top.trailing.equalToSuperview()
    }
    navigationBarView.configureNavigationBarTitle(title: viewModel.title)
    navigationBarView.addBackButton { [unowned self] in
      self.delegate?.registerViewControllerDidRequestGoBack(self)
    }
  }

  private func setupTextFields() {
    contentView.addSubview(textInputStackView)
    textInputStackView.axis = .vertical
    textInputStackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.equalToSuperview()
    }
    viewModel.fieldConfigurators.forEach { configurator in
      let textField = createTextInput(for: configurator)
      if configurator.type.wrapped == .email {
        viewModel.onDidRequestUpdateEmail = { [weak configurator] email in
          configurator?.update(text: email)
        }
      } else if configurator.type.wrapped == .phoneNumber {
        configurator.update(text: viewModel.defaultPhoneNumber)
      }
      let textFieldContainer = UIView()
      textFieldContainer.addSubview(textField)
      textField.snp.makeConstraints { make in
        make.top.equalToSuperview().inset(16)
        make.leading.trailing.equalToSuperview().inset(20)
        make.bottom.equalToSuperview()
      }
      textInputStackView.addArrangedSubview(textFieldContainer)
    }
  }
  
  private func setupAgreementContainer() {
    contentView.addSubview(agreementContainer)
    agreementContainer.axis = .vertical
    agreementContainer.spacing = 24
    agreementContainer.snp.makeConstraints { make in
      make.top.equalTo(textInputStackView.snp.bottom).offset(18)
      make.leading.trailing.equalToSuperview()
    }
    viewModel.agreements.forEach {
      let agreementCheckbox = AgreementCheckboxView()
      agreementCheckbox.configure(with: $0)
      agreementContainer.addArrangedSubview(agreementCheckbox)
    }
  }
  
  private func setupConfirmButton() {
    contentView.addSubview(confirmButton)
    confirmButton.isEnabled = viewModel.isValid
    confirmButton.setTitle(R.string.common.confirm(), for: .normal)
    confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    confirmButton.snp.makeConstraints { make in
      make.top.equalTo(agreementContainer.snp.bottom).offset(32)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.lessThanOrEqualToSuperview().inset(40)
    }
  }
  
  @objc private func didTapConfirm() {
    viewModel.didTapConfirm()
  }
}

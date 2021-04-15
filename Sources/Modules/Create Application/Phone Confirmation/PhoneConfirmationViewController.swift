//
//  PhoneConfirmationViewController.swift
//  ForwardLeasing
//

import UIKit
import SnapKit

protocol PhoneConfirmationViewControllerDelegate: class {
  func phoneConfirmationViewControllerDidRequestGoBack(_ viewController: PhoneConfirmationViewController)
}

class PhoneConfirmationViewController: BaseViewController, KeyboardVisibilityHandler, ActivityIndicatorPresenting,
                                       NavigationBarHiding {
  // MARK: - Subviews
  private let remainTimeLabel = AttributedLabel(textStyle: .title3Regular)
  private let phoneConfirmCodeView = CodeView()
  private let repeatCodeButton = UIButton(type: .system)
  private let textField = UITextField()
  private let navigationBarView = NavigationBarView()
  
  // MARK: - Properties
  var keyboardWillShowNotificationToken: NSObjectProtocol?
  var keyboardWillHideNotificationToken: NSObjectProtocol?
  var keyboardWillChangeFrameNotificationToken: NSObjectProtocol?

  weak var delegate: PhoneConfirmationViewControllerDelegate?
  
  private var remainTimeBottomConstraint: Constraint?
  private let viewModel: PhoneConfirmationViewModel
  private let hasBackButton: Bool
  
  // MARK: - Init
  
  init(viewModel: PhoneConfirmationViewModel, hasBackButton: Bool = true) {
    self.hasBackButton = hasBackButton
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
    viewModel.startTimer()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    textField.becomeFirstResponder()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupTextField()
    setupNavigationBarView()
    setupRemainTimeLabel()
    setupConfirmCodeView()
    setupRepeatCodeButton()
  }
  
  private func setupTextField() {
    view.addSubview(textField)
    textField.keyboardType = .numberPad
    textField.addTarget(self, action: #selector(codeDidChange), for: .editingChanged)
    textField.delegate = self
  }
  
  private func bind() {
    viewModel.onDidUpdateCode = { [weak self, weak viewModel] in
      guard let viewModel = viewModel else { return }
      self?.phoneConfirmCodeView.configure(with: viewModel.codeViewModel)
    }
    viewModel.onDidStartRequest = { [weak self] in
      self?.view.endEditing(true)
      self?.presentActivtiyIndicator(completion: nil)
    }
    viewModel.onDidFinishRequest = { [weak self] completion in
      self?.dismissActivityIndicator(completion: completion)
    }
    viewModel.onDidUpdateTime = { [weak self] in
      guard let self = self else { return }
      self.remainTimeLabel.text = self.viewModel.remainTimeTitle
      self.repeatCodeButton.isEnabled = self.viewModel.isEnabledRepeatCodeButton
    }
    viewModel.onDidResetCode = { [weak self] in
      self?.textField.text = nil
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.dismissActivityIndicator {
        self?.handle(error: error)
        self?.textField.becomeFirstResponder()
      }
    }
    viewModel.onDidRequestToShowWrongCodeAlert = { [weak self] message in
      self?.dismissActivityIndicator {
        self?.showWrongCodeAlert(with: message) {
          self?.textField.becomeFirstResponder()
        }
      }
    }
  }
  
  private func setupNavigationBarView() {
    view.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    navigationBarView.configureNavigationBarTitle(title: viewModel.title)
    if hasBackButton {
      navigationBarView.addBackButton { [unowned self] in
        self.delegate?.phoneConfirmationViewControllerDidRequestGoBack(self)
      }
    } 
  }
  
  private func setupRemainTimeLabel() {
    view.addSubview(remainTimeLabel)
    remainTimeLabel.textColor = .shade70
    remainTimeLabel.textAlignment = .center
    remainTimeLabel.numberOfLines = 0
    remainTimeLabel.text = viewModel.remainTimeTitle
    remainTimeLabel.snp.makeConstraints { make in
      make.top.equalTo(navigationBarView.snp.bottom).offset(88)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupConfirmCodeView() {
    view.addSubview(phoneConfirmCodeView)
    phoneConfirmCodeView.snp.makeConstraints { make in
      make.top.equalTo(remainTimeLabel.snp.bottom).offset(32)
      make.centerX.equalToSuperview()
      make.width.equalTo(183)
    }
    phoneConfirmCodeView.configure(with: viewModel.codeViewModel)
  }
  
  private func setupRepeatCodeButton() {
    view.addSubview(repeatCodeButton)
    let normalAttributedString =
      NSAttributedString(string: R.string.auth.codeConfirmationRepeatButtonTitle(),
                         font: .title2Semibold, foregroundColor: .accent)
    repeatCodeButton.setAttributedTitle(normalAttributedString, for: .normal)
    let disabledAttributedString =
      NSAttributedString(string: R.string.auth.codeConfirmationRepeatButtonTitle(),
                         font: .title2Semibold, foregroundColor: .shade30)
    repeatCodeButton.setAttributedTitle(disabledAttributedString, for: .disabled)
    repeatCodeButton.addTarget(self, action: #selector(didTapRepeatCode), for: .touchUpInside)
    repeatCodeButton.snp.makeConstraints { make in
      make.top.equalTo(phoneConfirmCodeView.snp.bottom).offset(48)
      make.centerX.equalToSuperview()
    }
    repeatCodeButton.isEnabled = viewModel.isEnabledRepeatCodeButton
  }
  
  private func showWrongCodeAlert(with message: String, completion: (() -> Void)?) {
    let alertController = BaseAlertViewController()
    let popupView = PopupAlertView(message)
    let button = StandardButton(type: .primary)
    button.setTitle(R.string.auth.wrongCodeAlertOkButtonTitle(), for: .normal)
    button.actionHandler(controlEvents: .touchUpInside) { [weak alertController] in
      alertController?.dismiss(animated: true) {
        completion?()
      }
    }
    popupView.addButton(button)
    alertController.addPopupAlert(popupView)
    present(alertController, animated: true, completion: nil)
  }
  
  @objc private func codeDidChange() {
    viewModel.updateCode(textField.text)
  }
  
  @objc private func didTapRepeatCode() {
    viewModel.repeatCode()
  }
}

// MARK: - TextFieldDelegate
extension PhoneConfirmationViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let text = textField.text ?? ""
    let expectedString = (text as NSString).replacingCharacters(in: range, with: string)
    if expectedString.count > viewModel.codeCount {
      return false
    }
    return true
  }
}

//
//  PinCodeConfirmViewController.swift
//  ForwardLeasing
//

import UIKit

protocol PinCodeConfirmViewControllerDelegate: class {
  func pinCodeConfirmViewControllerDidRequestGoBack(_ viewController: PinCodeConfirmViewController)
}

class PinCodeConfirmViewController: BaseViewController, NavigationBarHiding {
  // MARK: - Subviews
  private let navigationBarView = NavigationBarView()
  private let textField = UITextField()
  private let titleLabel = AttributedLabel(textStyle: .title3Regular)
  private let pincodeView = CodeView()
  
  // MARK: - Properties
  weak var delegate: PinCodeConfirmViewControllerDelegate?
  
  private let viewModel: PinCodeConfirmViewModel
  
  // MARK: - Init
  
  init(viewModel: PinCodeConfirmViewModel) {
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    textField.becomeFirstResponder()
  }
  
  // MARK: - Private Methods
  
  private func setup() {
    setupTextField()
    setupNavigationBarView()
    setupTitleLabel()
    setupPinCodeView()
  }
  
  private func bind() {
    viewModel.onDidRequestResetPin = { [weak self] in
      self?.textField.text = nil
    }
    viewModel.onDidUpdateFirstTry = { [weak self] in
      guard let self = self else { return }
      self.titleLabel.text = self.viewModel.pincodeTitle
    }
    viewModel.onDidFailPinTry = { [weak self] message in
      self?.showAlert(withTitle: message)
    }
    viewModel.onDidReceiveError = { [weak self] error in
      self?.handle(error: error)
    }
    viewModel.onDidUpdateCodeViewModel = { [weak self] in
      guard let self = self else { return }
      self.pincodeView.configure(with: self.viewModel.codeViewModel)
    }
  }
  
  private func setupTextField() {
    view.addSubview(textField)
    textField.keyboardType = .decimalPad
    textField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
  }
  
  private func setupNavigationBarView() {
    view.addSubview(navigationBarView)
    navigationBarView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    navigationBarView.configureNavigationBarTitle(title: viewModel.title)
    navigationBarView.addBackButton { [weak self] in
      guard let self = self else { return }
      self.delegate?.pinCodeConfirmViewControllerDidRequestGoBack(self)
    }
  }
  
  private func setupTitleLabel() {
    view.addSubview(titleLabel)
    titleLabel.textAlignment = .center
    titleLabel.textColor = .shade70
    titleLabel.text = viewModel.pincodeTitle
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(navigationBarView.snp.bottom).offset(144)
      make.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  private func setupPinCodeView() {
    view.addSubview(pincodeView)
    pincodeView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(54)
      make.centerX.equalToSuperview()
      make.width.equalTo(183)
    }
    pincodeView.configure(with: viewModel.codeViewModel)
  }
  
  @objc private func didChangeText() {
    viewModel.updatePin(textField.text)
  }
}

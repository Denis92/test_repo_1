//
//  PinCodeRecoveryViewModel.swift
//  ForwardLeasing
//

import UIKit
import PromiseKit

protocol PinCodeRecoveryViewModelDelegate: class {
  func pinCodeRecoveryViewModel(_ viewModel: PinCodeRecoveryViewModel,
                                didRequestRecoveryForSessionID sessionID: String)
}

class PinCodeRecoveryViewModel {
  // MARK: - Types
  typealias Dependencies = HasAuthService
  
  // MARK: - Properties
  var title: String {
    return R.string.auth.pinCodeRecoveryTitle()
  }
  
  var onDidStartRequest: (() -> Void)?
  var onDidSuccessFinishRequest: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?
  var onValidityUpdated: (() -> Void)?
  
  weak var delegate: PinCodeRecoveryViewModelDelegate?
  
  private(set) var isValid: Bool = false {
    didSet {
      if isValid != oldValue {
        onValidityUpdated?()
      }
    }
  }
  
  private var phone: String?
  
  private(set) lazy var textInputConfigurator = makeTextInputConfigurator()
  private let dependencies: Dependencies
  
  private var onDidFinish: (() -> Void)?
  
  // MARK: - Init
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Public
  func finish() {
    onDidFinish?()
  }
  
  func sendCode() {
    guard let phone = phone else { return }
    onDidStartRequest?()
    firstly {
      dependencies.authService.recoveryPin(phone: phone)
    }.done { response in
      self.onDidSuccessFinishRequest?()
      self.handle(response)
    }.catch { error in
      self.onDidReceiveError?(error)
    }
  }
  
  private func handle(_ response: SessionResponse) {
    onDidFinish = { [weak self, response] in
      guard let self = self else { return }
      self.delegate?.pinCodeRecoveryViewModel(self, didRequestRecoveryForSessionID: response.sessionID)
    }
  }
  
  // MARK: - Private
  private func makeTextInputConfigurator() -> FieldConfigurator<RecoveryPinFieldType> {
    let configurator = FieldConfigurator(fieldType: RecoveryPinFieldType(), text: Constants.phoneInitialValue)
    configurator.onDidChangeText = { [weak self, weak configurator] text in
      configurator?.validate(silent: true)
      self?.phone = text?.sanitizedPhoneNumber()
    }
    configurator.onValidityUpdated = { [weak self] isValid in
      self?.isValid = isValid
    }
    return configurator
  }
}

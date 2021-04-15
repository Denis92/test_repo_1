//
//  AuthorizationViewModel.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol AuthorizationViewModelDelegate: class {
  func authorizationViewModelDidSignIn(_ viewModel: AuthorizationViewModel)
  func authorizationViewModelDidRequestToSignUp(_ viewModel: AuthorizationViewModel)
  func authorizationViewModelDidRequestToResetPassword(_ viewModel: AuthorizationViewModel)
}

private enum AuthorizationError: LocalizedError {
  case wrongPIN
  var errorDescription: String? {
    switch self {
    case .wrongPIN:
      return R.string.networkErrors.errorInvalidPinText()
    }
  }
}

class AuthorizationViewModel {
  typealias Dependencies = HasAuthService & HasUserDataStore & HasTokenStorage
  typealias ContainerFieldType = AuthorizationFieldType
  
  // MARK: - Properties
  
  weak var delegate: AuthorizationViewModelDelegate?
  
  var onDidUpdate: (() -> Void)?
  var onDidStartRequest: (() -> Void)?
  var onDidFinishRequest: (() -> Void)?
  var onDidReceiveError: ((Error) -> Void)?
  
  var isValid: Bool {
    return isPhoneNumberValid && isPinValid
  }
  
  var phoneInitialValue: String {
    Constants.phoneInitialValue
  }
  
  private(set) lazy var fieldConfigurators = makeFieldConfigurators()
  
  private var isPhoneNumberValid = false {
    didSet {
      onDidUpdate?()
    }
  }
  private var isPinValid = false {
    didSet {
      onDidUpdate?()
    }
  }
  
  private var phone: String?
  private var pin: String?
  private let dependencies: Dependencies
  
  // MARK: - Init
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Public methods
  
  func signIn() {
    guard let phone = phone, let pin = pin, isValid else { return }
    onDidStartRequest?()
    dependencies.authService.signIn(phone: phone, pin: pin).ensure {
      self.onDidFinishRequest?()
    }.then { result in
      self.handle(result)
    }.done { _ in
      self.dependencies.userDataStore.phoneNumber = phone
      self.delegate?.authorizationViewModelDidSignIn(self)
    }.catch { error in
      self.onDidReceiveError?(error)
    }
  }
  
  func signUp() {
    delegate?.authorizationViewModelDidRequestToSignUp(self)
  }
  
  func resetPassword() {
    delegate?.authorizationViewModelDidRequestToResetPassword(self)
  }
  
  // MARK: - Private methods

  private func handle(_ result: CheckCodeResult) -> Promise<Void> {
    guard result.resultCode == .ok else {
      return Promise(error: AuthorizationError.wrongPIN)
    }
    if let token = result.token {
      dependencies.tokenStorage.accessToken = token
    }
    return Promise.value(())
  }

  private func makeFieldConfigurators() -> [FieldConfigurator<ContainerFieldType>] {
      return ContainerFieldType.allCases.map { fieldType in
        let configurator = FieldConfigurator(fieldType: fieldType)
        configurator.onValidityUpdated = { [weak self] isValid in
          switch fieldType {
          case .phoneNumber:
            self?.isPhoneNumberValid = isValid
          case .pin:
            self?.isPinValid = isValid
          }
        }
        configurator.onDidChangeText = { [weak configurator, weak self] text in
          if configurator?.type == .pin {
            self?.pin = text
          } else {
            self?.phone = text?.sanitizedPhoneNumber()
          }
          configurator?.validate(silent: true)
        }
        return configurator
      }
  }
}

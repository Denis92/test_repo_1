//
//  RegisterPhoneConfirmation.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

enum PinCodeConfirmationType {
  case registration
  case pinRecovery
  case pinUpdate
}

class PinCodeConfirmation: PhoneConfirmationStrategy {
  typealias Dependency = HasAuthService
  
  // MARK: - Properties
  
  var phoneConfirmationTitle: String {
    switch type {
    case .pinRecovery, .registration:
      return R.string.auth.codeConfirmationRegisterText()
    case .pinUpdate:
      return R.string.profileSettings.codeConfirmationText()
    }
  }
  
  var isHiddenRepeatCodeButton: Bool {
    return false
  }
  
  var title: String? {
    switch type {
    case .pinRecovery:
      return R.string.auth.pinCodeRecoveryTitle()
    case .registration:
      return R.string.auth.registrationTitle()
    case .pinUpdate:
      return R.string.profileSettings.updatePinCodeTitle()
    }
  }
  
  private let dependency: Dependency
  private let type: PinCodeConfirmationType
  
  // MARK: - Init
  init(dependency: Dependency, type: PinCodeConfirmationType) {
    self.dependency = dependency
    self.type = type
  }
  
  // MARK: - Public
  func checkOTP(code: String, id: String) -> Promise<CheckCodeResult> {
    return dependency.authService.checkCode(code: code, sessionID: id)
  }
  
  func resendSMS(id: String) -> Promise<EmptyResponse> {
    return dependency.authService.resendSmsCode(sessionID: id)
  }
}

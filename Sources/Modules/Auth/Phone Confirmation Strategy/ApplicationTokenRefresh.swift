//
//  ApplicationTokenRefresh.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

class ApplicationTokenRefresh: PhoneConfirmationStrategy {
  typealias Dependency = HasPersonalDataRegisterService
  
  var phoneConfirmationTitle: String {
    return R.string.auth.codeConfirmationApplicationText()
  }
  
  var title: String? {
    return application.productInfo.productName
  }
  
  var isHiddenRepeatCodeButton: Bool {
    return false
  }
  
  var shouldImmediatelySendOTPRequest: Bool {
    return true
  }
  
  private let dependency: Dependency
  private let application: LeasingEntity
  
  init(dependency: HasPersonalDataRegisterService,
       leasingApplication: LeasingEntity) {
    self.dependency = dependency
    self.application = leasingApplication
  }
  
  func checkOTP(code: String, id: String) -> Promise<CheckCodeResult> {
    return dependency.personalDataRegistrationService.checkRefreshTokenOTPCode(code: code,
                                                                               applicationID: id)
  }
  
  func resendSMS(id: String) -> Promise<EmptyResponse> {
    return dependency.personalDataRegistrationService.refreshToken(applicationID: id)
  }
}

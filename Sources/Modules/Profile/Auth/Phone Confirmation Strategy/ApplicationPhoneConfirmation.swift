//
//  ApplicationPhoneConfirmation.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

class ApplicationPhoneConfirmation: PhoneConfirmationStrategy {
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
  
  private let dependency: Dependency
  private let application: LeasingEntity
  
  init(dependency: HasPersonalDataRegisterService,
       leasingApplication: LeasingEntity) {
    self.dependency = dependency
    self.application = leasingApplication
  }
  
  func checkOTP(code: String, id: String) -> Promise<CheckCodeResult> {
    return dependency.personalDataRegistrationService.checkCode(code: code, applicationID: id)
  }
  
  func resendSMS(id: String) -> Promise<EmptyResponse> {
    return dependency.personalDataRegistrationService.resendSmsCode(applicationID: id)
  }
}

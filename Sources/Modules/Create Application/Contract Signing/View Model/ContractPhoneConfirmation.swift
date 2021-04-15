//
//  ContractPhoneConfirmation.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

class ContractPhoneConfirmation: PhoneConfirmationStrategy {
  typealias Dependency = HasContractService
  
  var phoneConfirmationTitle: String {
    return R.string.auth.codeConfirmationApplicationText()
  }
  
  var title: String? {
    return R.string.contractSigning.screenTitle()
  }
  
  var isHiddenRepeatCodeButton: Bool {
    return false
  }
  
  private let dependency: Dependency
  private let application: LeasingEntity
  
  init(dependency: Dependency,
       leasingApplication: LeasingEntity) {
    self.dependency = dependency
    self.application = leasingApplication
  }
  
  func checkOTP(code: String, id: String) -> Promise<CheckCodeResult> {
    return dependency.contractService.checkContractCode(code: code, applicationID: id)
  }
  
  func resendSMS(id: String) -> Promise<EmptyResponse> {
    return dependency.contractService.resendContractSmsCode(applicationID: id)
  }
}

//
//  DeliveryPhoneConfirmation.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

class DeliveryPhoneConfirmation: PhoneConfirmationStrategy {
  typealias Dependency =  HasDeliveryService

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
  private let contract: LeasingEntity

  init(dependency: Dependency,
       contract: LeasingEntity) {
    self.dependency = dependency
    self.contract = contract
  }

  func checkOTP(code: String, id: String) -> Promise<CheckCodeResult> {
    return dependency.deliveryService.validateOTP(code: code,
                                                  applicationID: id)
  }

  func resendSMS(id: String) -> Promise<EmptyResponse> {
    return dependency.deliveryService.signOTP(applicationID: id)
  }
}

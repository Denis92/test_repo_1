//
//  PhoneConfirmationStrategy.swift
//  ForwardLeasing
//

import Foundation
import PromiseKit

protocol PhoneConfirmationStrategy {
  var phoneConfirmationTitle: String { get }
  var title: String? { get }
  var isHiddenRepeatCodeButton: Bool { get }
  var shouldImmediatelySendOTPRequest: Bool { get }
  
  func checkOTP(code: String, id: String) -> Promise<CheckCodeResult>
  func resendSMS(id: String) -> Promise<EmptyResponse>
}

extension PhoneConfirmationStrategy {
  var shouldImmediatelySendOTPRequest: Bool {
    return false
  }
}

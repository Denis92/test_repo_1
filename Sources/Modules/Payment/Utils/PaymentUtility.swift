//
//  DeliveryProductPaymentUtility.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let querySuccessKey = "success"
  static let queryErrorKey = "error"
  static let subscriptionPaymentKeys = ["id", "operation", "reference"]
}

protocol PaymentUtilityDelegate: class {
  func paymentUtilityDidFail(_ utility: PaymentUtility)
  func paymentUtilityDidFinishSuccess(_ utility: PaymentUtility)
}

class PaymentUtility {
  // MARK: - Properties
  weak var delegate: PaymentUtilityDelegate?

  // MARK: - Private
  private func parseURL(url: URL) -> Bool {
    guard let parameters = url.queryParameters else { return true }
    if let successString = parameters[Constants.querySuccessKey],
       let isSuccess = Bool(successString) {
      handleSuccess(isSuccess)
      return false
    } else if Constants.subscriptionPaymentKeys.allSatisfy({ parameters.keys.contains($0) }) {
      handleSuccess(!parameters.keys.contains(Constants.queryErrorKey))
      return false
    } else {
      return true
    }
  }
  
  private func handleSuccess(_ isSuccess: Bool) {
    isSuccess ? delegate?.paymentUtilityDidFinishSuccess(self) : delegate?.paymentUtilityDidFail(self)
  }
}

// MARK: - WebViewControllerDelegate
extension PaymentUtility: WebViewControllerDelegate {
  func webViewController(_ viewController: WebViewController, didFailWithError error: Error) {
    delegate?.paymentUtilityDidFail(self)
  }
  
  func webViewController(_ viewController: WebViewController, shouldOpenURL url: URL) -> Bool {
    return parseURL(url: url)
  }
}

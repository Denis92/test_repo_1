//
//  NumberFormatter+Custom.swift
//  ForwardLeasing
//

import Foundation

extension NumberFormatter {
  static func currencyFormatter(withSymbol: Bool = true) -> NumberFormatter {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale(identifier: "ru_RU")
    currencyFormatter.minimumFractionDigits = 0
    currencyFormatter.maximumFractionDigits = 2
    if !withSymbol {
      currencyFormatter.currencySymbol = ""
    }
    return currencyFormatter
  }
  
  func string(from amount: Amount) -> String? {
    return string(from: amount.value)
  }
}

//
//  Decimal+PriceString.swift
//  ForwardLeasing
//

import Foundation

extension Decimal {
  func rounded(precision: Int) -> Decimal {
    let result = (self as NSDecimalNumber).rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .plain,
                                                                                                scale: Int16(precision),
                                                                                                raiseOnExactness: false,
                                                                                                raiseOnOverflow: false,
                                                                                                raiseOnUnderflow: false,
                                                                                                raiseOnDivideByZero: false))
    return result as Decimal
  }

  func priceString(withSymbol: Bool = true) -> String? {
    let currencyFormatter = NumberFormatter.currencyFormatter()
    if !withSymbol {
      currencyFormatter.currencySymbol = ""
    }
    return currencyFormatter.string(from: self as NSNumber)?.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

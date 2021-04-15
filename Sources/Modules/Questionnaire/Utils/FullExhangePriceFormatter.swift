//
//  FullExhangePriceFormatter.swift
//  ForwardLeasing
//

import UIKit

struct FullExhangePriceFormatter {
  func priceString(earlyUpgradePrice: String?, diagnosticPrice: String?,
                          finalPrice: String?) -> NSAttributedString? {
    guard let upgradeReturnSumPrice = earlyUpgradePrice,
          let gradeSumPrice = diagnosticPrice,
          let finalSumPrice = finalPrice else { return nil }
    let sumString = "\(upgradeReturnSumPrice) + \(gradeSumPrice) = "
    let finalString = sumString + finalSumPrice
    let sumStringRange = (finalString as NSString).range(of: sumString)
    let attributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.font: UIFont.title2Bold,
      NSAttributedString.Key.foregroundColor: UIColor.base1
    ]
    let sumAttributes: [NSAttributedString.Key: Any] = [
      NSAttributedString.Key.font: UIFont.title2Bold,
      NSAttributedString.Key.foregroundColor: UIColor.accent
    ]
    let priceAttributedString = NSMutableAttributedString(string: finalString,
                                                          attributes: attributes)
    priceAttributedString.addAttributes(sumAttributes, range: sumStringRange)
    return priceAttributedString
  }
}

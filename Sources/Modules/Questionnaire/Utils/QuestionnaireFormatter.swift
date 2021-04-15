//
//  QuestionnaireFormatter.swift
//  ForwardLeasing
//

import Foundation

struct QuestionnaireFormatter {
  private let priceFormatter = FullExhangePriceFormatter()
  private let gradeInfo: QuestionGradeInfo
  private let contract: LeasingEntity

  init(gradeInfo: QuestionGradeInfo,
       contract: LeasingEntity) {
    self.gradeInfo = gradeInfo
    self.contract = contract
  }

  var title: String {
    return gradeInfo.title
  }

  var description: String? {
    return gradeInfo.subtitle
  }

  var descriptionPrice: NSAttributedString? {
    guard gradeInfo.gradeType != .none else {
      return nil
    }
    return priceFormatter.priceString(earlyUpgradePrice: earlyUpgradePrice,
                                      diagnosticPrice: diagnosticPrice,
                                      finalPrice: finalPrice)
  }

  var earlyUpgradePrice: String? {
    return contract.productInfo.upgradePayment?.priceString()
  }

  var diagnosticPrice: String? {
    return Decimal(gradeInfo.upgradePrice).priceString()
  }

  var finalPrice: String? {
    guard let upgradeReturnPaymentSum = contract.productInfo.upgradePayment else {
      return nil
    }
    return (upgradeReturnPaymentSum + Decimal(gradeInfo.upgradePrice)).priceString()
  }
}

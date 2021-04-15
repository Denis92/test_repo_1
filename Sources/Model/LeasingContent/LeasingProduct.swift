//
//  LeasingProduct.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct LeasingProduct: Codable {
  let code: String
  let leasingSum: Int
  let monthPay: Int
  let monthTerm: Int
  let residualSum: Int
  let earlyUpgradeTerm: Int
  let freeUpgradeTerm: Int
  let prolongationTerm: Int
  let hasUpgrade: Bool
  let upgradePayment: Int
  let financialType: String
  let additionalServices: [AdditionalService]?
  let deliveryInfo: LeasingContentDeliveryInfo
  let leasingPayPercent: Int
  let maxAccessoriesSum: Int
  let hasReturn: Bool
  let hasEarlyUpgrade: Bool
  let labelViews: [ContentLabelView]?
}

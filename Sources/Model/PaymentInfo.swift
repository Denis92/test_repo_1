//
//  PaymentInfo.swift
//  ForwardLeasing
//

import Foundation

enum PaymentType: String, Codable {
  case leasing = "LEASING"
  case commision = "COMMISSION"
  case delivery = "DELIVERY"
}

struct PaymentInfo: Encodable, EncodableToDictionary {
  private enum CodingKeys: String, CodingKey {
    case contractNumber, paymentSum, cardID = "token", shouldCreateTemplate = "createTemplate",
         deviceType, paymentType
  }
  
  let contractNumber: String
  let paymentSum: Decimal
  let cardID: String?
  let shouldCreateTemplate: Bool
  let deviceType = Constants.deviceType
  let paymentType: PaymentType
  
  init(contractNumber: String, paymentSum: Decimal,
       cardID: String?, shouldCreateTemplate: Bool,
       paymentType: PaymentType = .leasing) {
    self.contractNumber = contractNumber
    self.paymentSum = paymentSum
    self.cardID = cardID
    self.shouldCreateTemplate = shouldCreateTemplate
    self.paymentType = paymentType
  }
}

//
//  ProductShortInfo.swift
//  ForwardLeasing
//

import Foundation

struct ProductShortInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case code = "goodCode", volume, fullPrice, monthPayString = "goodMonthPay",
         isDefault, description
  }
  let code: String
  let volume: String
  let fullPrice: String
  let monthPayString: String
  let isDefault: Bool
  let description: String?
  
  var monthPay: Decimal {
    return Decimal(string: monthPayString) ?? 0
  }
}

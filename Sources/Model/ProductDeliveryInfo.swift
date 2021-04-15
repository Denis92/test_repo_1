//
//  ProductDeliveryInfo.swift
//  ForwardLeasing
//

import Foundation

enum ProductDeliveryStatus: String, Codable {
  case ok = "OK"
  case goodUnavailable = "GOOD_UNAVAILABLE"
  case deliveryUnavailable = "DELIVERY_UNAVAILABLE"
}

struct ProductDeliveryInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case status = "resultStatus", daysCount, deliveryCost
  }
  
  let status: ProductDeliveryStatus
  let daysCount: Int
  let deliveryCost: Double?
}

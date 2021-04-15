//
//  DeliveryType.swift
//  ForwardLeasing
//

import Foundation

enum DeliveryType: String, Codable {
  case delivery = "DELIVERY", deliveryPartner = "DELIVERY_PARTNER", pickup = "PICKUP"
  
  var intValue: Int {
    switch self {
    case .delivery, .deliveryPartner:
      return 0
    case .pickup:
      return 1
    }
  }
}

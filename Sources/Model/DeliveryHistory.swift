//
//  DeliveryHistory.swift
//  ForwardLeasing
//

import Foundation

struct DeliveryHistoryItem: Codable {
  enum CodingKeys: String, CodingKey {
    case createDate = "create_date", deliveryStatus = "delivery_status"
  }
  
  let createDate: Date
  let deliveryStatus: DeliveryStatus
}

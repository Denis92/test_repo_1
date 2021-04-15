//
//  OrderStatus.swift
//  ForwardLeasing
//

import Foundation

enum OrderStatus: String, Codable {
  case new = "NEW"
  case orderNew = "ORDER_NEW"
  case error = "ERROR"
  case none

  init(from decoder: Decoder) throws {
    self = try OrderStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .none
  }
}

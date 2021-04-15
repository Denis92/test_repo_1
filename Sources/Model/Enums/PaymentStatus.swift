//
//  PaymentStatus.swift
//  ForwardLeasing
//

import Foundation

enum PaymentStatus: String, Codable {
  case ok = "OK"
  case pending = "PENDING"
  case error = "ERROR"
}

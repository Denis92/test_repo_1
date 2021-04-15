//
//  PaymentRegistrationResponse.swift
//  ForwardLeasing
//

import Foundation

struct PaymentInfoResponse: Codable {
  enum CodingKeys: String, CodingKey {
    case paymentURL = "payUrl"
  }
  
  let paymentURL: URL
}

struct PaymentRegistrationResponse: Codable {
  let paymentInfo: PaymentInfoResponse
  let reference: String
}

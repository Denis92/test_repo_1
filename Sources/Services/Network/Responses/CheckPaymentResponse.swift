//
//  CheckPaymentReponse.swift
//  ForwardLeasing
//

import Foundation

struct CheckPaymentResponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case status = "paymentStatus", paymentURL = "paymentUrl"
  }
  
  let status: PaymentStatus
  let paymentURL: String?
}

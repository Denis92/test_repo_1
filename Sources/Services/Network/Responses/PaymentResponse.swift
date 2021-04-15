//
//  PaymentResponse.swift
//  ForwardLeasing
//

import Foundation

struct PaymentResponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case paymentURL = "paymentUrl", url = "url"
  }
  
  let paymentURL: URL
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let paymentURL = try container.decodeIfPresent(URL.self, forKey: .paymentURL) {
      self.paymentURL = paymentURL
    } else {
      paymentURL = try container.decode(URL.self, forKey: .url)
    }
  }
}

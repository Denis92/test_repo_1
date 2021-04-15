//
//  CreateBasketResponse.swift
//  ForwardLeasing
//

import Foundation

struct CreateBasketResponse: Codable {
  enum CodingKeys: String, CodingKey {
    case basketID = "basketId"
  }

  let basketID: String
}

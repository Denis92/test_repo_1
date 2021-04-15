//
//  ProductInfoResponse.swift
//  ForwardLeasing
//

import Foundation

struct ProductInfoResponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case product = "good"
  }

  let product: ProductDetails
}

//
//  ModelInfoResponse.swift
//  ForwardLeasing
//

import Foundation

struct ModelInfoResponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case modelInfo = "model", goodInfo
  }
  
  let modelInfo: ModelInfo
  let goodInfo: ProductDetails?
}

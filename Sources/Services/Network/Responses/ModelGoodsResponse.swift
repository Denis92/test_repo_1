//
//  ModelGoodsResponse.swift
//  ForwardLeasing
//

import Foundation

struct ModelGoodsResponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case model, goods
  }

  let model: ModelInfo
  let goods: [ProductDetails]

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    model = try container.decode(ModelInfo.self, forKey: .model)
    goods = (try? container.decode([ProductDetails].self, forKey: .goods)) ?? []
  }
}

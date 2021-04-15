//
//  ModelInfo.swift
//  ForwardLeasing
//

import Foundation

struct ModelInfo: Decodable {
  enum CodingKeys: String, CodingKey {
      case categoryCodes, modelName, name, code, modelCode, images, favoriteProducts = "favoriteGoods",
           productDetails = "good"
  }
  
  let categoryCodes: [String]
  let name: String
  let code: String
  let images: [ProductImage]
  let favoriteProducts: [ProductShortInfo]
  
  var primaryImage: URL? {
    return images.first { $0.type == .primary }?.imageURL
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    categoryCodes = try container.decode([String].self, forKey: .categoryCodes)
    if let name = try container.decodeIfPresent(String.self, forKey: .modelName) {
      self.name = name
    } else {
      name = try container.decode(String.self, forKey: .name)
    }
    if let code = try container.decodeIfPresent(String.self, forKey: .modelCode) {
      self.code = code
    } else {
      code = try container.decode(String.self, forKey: .code)
    }
    images = try container.decodeIfPresent([ProductImage].self, forKey: .images) ?? []
    favoriteProducts = try container.decodeIfPresent([ProductShortInfo].self, forKey: .favoriteProducts) ?? []
  }
}

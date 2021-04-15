//
//  ProductImage.swift
//  ForwardLeasing
//

import Foundation

struct ProductImage: Codable {
  enum ProductImageType: String, Codable {
    case primary = "PRIMARY", common = "COMMON", promo = "PROMO"
  }
  
  enum CodingKeys: String, CodingKey {
    case imagePath = "imageUrl", type, sortOrder
  }
  
  let imagePath: String
  let type: ProductImageType
  let sortOrder: Int
  
  var imageURL: URL? {
    return URL(string: imagePath)
  }
}

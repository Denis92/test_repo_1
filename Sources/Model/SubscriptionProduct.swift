//
//  SubscriptionProduct.swift
//  ForwardLeasing
//

import Foundation

struct SubscriptionProductItem: Codable {
  enum CodingKeys: String, CodingKey {
    case id, price, months, imageURLs = "imageUrls",
         description, contentLabels, sortOrder, hexColor
  }
  
  let id: String
  let price: String
  let months: Int
  let imageURLs: [String]
  let description: String
  let contentLabels: [String]
  let sortOrder: Int
  let hexColor: String
}

extension SubscriptionProductItem: Equatable {
  static func == (lhs: SubscriptionProductItem, rhs: SubscriptionProductItem) -> Bool {
    return lhs.id == rhs.id
  }
}

struct SubscriptionProduct: Codable {
  let name: String
  let items: [SubscriptionProductItem]
}

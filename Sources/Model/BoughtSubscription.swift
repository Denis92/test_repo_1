//
//  BoughtSubscription.swift
//  ForwardLeasing
//

import Foundation

struct BoughtSubscription: Codable {
  enum CodingKeys: String, CodingKey {
    case id, date, keys, name, description, isActive = "active",
         price, months, images, userSubscriptionID = "userSubscriptionId"
  }
  let id: Int
  let date: Date?
  let keys: [String]
  let name: String
  let description: String?
  let isActive: Bool
  let imageURLString: String?
  let price: Decimal
  let months: Int
  let userSubscriptionID: Int

  private let images: [String]

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    date = try container.decode(Date.self, forKey: .date)
    keys = (try container.decodeIfPresent([String].self, forKey: .keys)) ?? []
    description = try container.decodeIfPresent(String.self, forKey: .description)
    isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? false
    images = (try container.decodeIfPresent([String].self, forKey: .images)) ?? []
    imageURLString = images.first
    price = try container.decodeIfPresent(Decimal.self, forKey: .price) ?? 0
    months = try container.decode(Int.self, forKey: .months)
    userSubscriptionID = try container.decode(Int.self, forKey: .userSubscriptionID)
  }
}

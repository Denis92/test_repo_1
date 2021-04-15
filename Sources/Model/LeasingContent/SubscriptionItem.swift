//
//  SubscriptionItem.swift
//  ForwardLeasing
//
//  Created by Roman Levkovich on 4/13/21.
//

import Foundation

struct SubscriptionItem: Codable {
  enum ProviderType: String, Codable {
    case buka = "BUKA"
    case ivi = "IVI"
    case whp = "WHP"
  }
  
  let id: Int
  let price: Double
  let months: Int
  let imageUrls: [String]?
  let description: String?
  let providerType: ProviderType
  let isActive: Bool?
}

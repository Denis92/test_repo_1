//
//  StoresResponse.swift
//  ForwardLeasing
//

import Foundation

struct StoresResponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case points = "storePoints", retailers
  }
  
  let points: [StorePointInfo]
  let retailers: [RetailerInfo]
}

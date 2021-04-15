//
//  RetailerInfo.swift
//  ForwardLeasing
//

import Foundation

struct RetailerInfo: Codable {
  enum CodingKeys: String, CodingKey {
    case code, name, imageURL = "imgUrl"
  }
  
  let code: String
  let name: String
  let imageURL: String?
}

//
//  InfoData.swift
//  ForwardLeasing
//

import Foundation

struct InfoData: Decodable {
  enum CodingKeys: String, CodingKey {
    case message
    case isCritical = "critical"
  }

  let message: String?
  let isCritical: Bool
}

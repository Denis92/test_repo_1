//
//  VersionData.swift
//  ForwardLeasing
//

import Foundation

struct VersionData: Decodable {
  enum CodingKeys: String, CodingKey {
    case description
    case isCritical = "critical"
    case hasNewVersion
  }

  let description: String?
  let isCritical: Bool
  let hasNewVersion: Bool
}

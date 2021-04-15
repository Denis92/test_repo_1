//
//  Card.swift
//  ForwardLeasing
//

import Foundation

struct Card: Codable {
  enum CodingKeys: String, CodingKey {
    case id = "templateId"
    case mask = "maskCard"
    case holderName = "cardholderName"
    case expireMonth = "expMonth"
    case expireYear = "expYear"
  }
  
  let id: String
  let mask: String
  let holderName: String
  let expireMonth: String
  let expireYear: String
}

extension Card: Equatable {
  static func == (lhs: Card, rhs: Card) -> Bool {
    return lhs.id == rhs.id
  }
}

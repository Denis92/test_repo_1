//
//  Question.swift
//  ForwardLeasing
//

import Foundation

struct Question: Codable {
  enum CodingKeys: String, CodingKey {
    case questionText, description, answerValue = "valueAnswer", sortOrder
  }
  
  let questionText: String
  let description: String
  let answerValue: Int
  let sortOrder: Int
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    questionText = try container.decode(String.self, forKey: .questionText)
    description = try container.decode(String.self, forKey: .description)
    answerValue = try container.decode(Int.self, forKey: .answerValue)
    sortOrder = try container.decode(Int.self, forKey: .sortOrder)
  }
}

// MARK: - Hashable
extension Question: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(questionText)
    hasher.combine(description)
    hasher.combine(answerValue)
    hasher.combine(sortOrder)
  }
}

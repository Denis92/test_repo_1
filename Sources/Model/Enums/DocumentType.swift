//
//  DocumentType.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let passportEncodingKey = "PASSPORT"
  static let passportDecodingKey = "RUS_PASSPORT_NATIONAL"
}

enum DocumentType: String, Codable {
  case passport
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let stringValue = try container.decode(String.self)
    guard [Constants.passportEncodingKey, Constants.passportDecodingKey].contains(stringValue) else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unexpected value: \(stringValue)")
    }
    self = .passport
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(Constants.passportEncodingKey)
  }
}

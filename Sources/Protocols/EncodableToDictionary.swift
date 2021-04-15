//
//  EncodableToDictionary.swift
//  ForwardLeasing
//

import Foundation

enum EncodingError: Error {
  case wrongFormat
}

extension EncodingError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .wrongFormat:
      return R.string.networkErrors.errorCreatingRequestDataText()
    }
  }
}

protocol EncodableToDictionary {
  func asDictionary(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy,
                    keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy) throws -> [String: Any]
  func asDictionary() throws -> [String: Any]
}

extension EncodableToDictionary where Self: Encodable {
  func asDictionary() throws -> [String: Any] {
    return try asDictionary(dateEncodingStrategy: .dateAndTimeISO, keyEncodingStrategy: .useDefaultKeys)
  }
  
  func asDictionary(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy,
                    keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy) throws -> [String: Any] {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = dateEncodingStrategy
    encoder.keyEncodingStrategy = keyEncodingStrategy
    let data = try encoder.encode(self)
    return try dictionary(fromJSONData: data)
  }
  
  func dictionary(fromJSONData data: Data) throws -> [String: Any] {
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw EncodingError.wrongFormat
    }
    return dictionary
  }
}

//
//  CodeResult.swift
//  ForwardLeasing
//

import Foundation

enum CodeResult: String, Decodable {
  private struct Results {
    static let ok = ["OK", "SMS_MATCH", "PIN_MATCH"]
    static let mismatch = ["MISMATCH", "SMS_MISMATCH", "PIN_MISMATCH"]
    static let rejected = "REJECTED"
  }
  
  case ok
  case mismatch
  case rejected
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let result = try container.decode(String.self)
    switch result {
    case let result where Results.ok.contains(result):
      self = .ok
    case let result where Results.mismatch.contains(result):
      self = .mismatch
    case Results.rejected:
      self = .rejected
    default:
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Wrong code result: \(result)")
    }
  }
}

struct CheckCodeResult: Decodable {
  enum CodingKeys: String, CodingKey {
    case result, resultCode, token
  }
  
  let resultCode: CodeResult
  let token: String?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let result = try? container.decodeIfPresent(CodeResult.self, forKey: .result) {
      resultCode = result
    } else {
      resultCode = try container.decode(CodeResult.self, forKey: .resultCode)
    }
    token = try container.decodeIfPresent(String.self, forKey: .token)
  }
}

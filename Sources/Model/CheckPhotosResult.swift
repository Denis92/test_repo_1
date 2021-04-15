//
//  CheckPhotosResult.swift
//  ForwardLeasing
//

import Foundation

enum CheckPhotosStatus: String, Codable {
  case checkedSuccess = "CHECKED_SUCCESS"
  case pending = "PENDING"
  case rejected = "REJECTED"
  case checkOff = "CHECK_OFF"
  case notChecked = "NOT_CHECKED"
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let stringResult = try container.decode(String.self)
    guard let status = CheckPhotosStatus(rawValue: stringResult) else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Wrong status: \(stringResult)")
    }
    self = status
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}

struct CheckPhotosResult: Codable {
  let status: CheckPhotosStatus
  let comments: String?
}

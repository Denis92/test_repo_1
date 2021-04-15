//
//  LivenessResponse.swift
//  ForwardLeasing
//

import Foundation

struct LivenessCredentials: Codable {
  enum CodingKeys: String, CodingKey {
    case token, applicantID = "applicantId"
  }
  
  let token: String
  let applicantID: String
}

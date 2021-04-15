//
//  SessionResponse.swift
//  ForwardLeasing
//

import Foundation

struct SessionResponse: Codable {
  enum CodingKeys: String, CodingKey {
    case sessionID = "sessionId"
  }
  
  let sessionID: String
}

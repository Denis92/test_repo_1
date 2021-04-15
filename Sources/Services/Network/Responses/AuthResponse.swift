//
//  AuthResponse.swift
//  ForwardLeasing
//

import Foundation

protocol TokensContainingResponse {
  var access: String? { get }
  var refresh: String? { get }
}

struct AuthResponse: Codable, TokensContainingResponse {
  enum CodingKeys: String, CodingKey {
    case access, refresh, profile, shouldShowWizard = "showWizard"
  }
  
  let access: String?
  let refresh: String?
  let profile: User?
  let shouldShowWizard: Bool
}

//
//  ErrorResponse.swift
//  ForwardLeasing
//

private extension Constants {
  static let wrongToken = "invalid_token"
}

struct ErrorResponse: Codable {
  let errorMessage: String?
  let errorCode: Int?
  private let error: String?
  
  var isInvalidTokenError: Bool {
    return error == Constants.wrongToken
  }
}

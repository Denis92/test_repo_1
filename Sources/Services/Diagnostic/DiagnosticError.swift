//
//  DiagnosticError.swift
//  ForwardLeasing
//

import Foundation

enum DiagnosticError: LocalizedError {
  case diagnosticError(String)
  case notAvailable

  var errorDescription: String? {
    switch self {
    case .diagnosticError(let message):
      return message
    default:
      return nil
    }
  }
}

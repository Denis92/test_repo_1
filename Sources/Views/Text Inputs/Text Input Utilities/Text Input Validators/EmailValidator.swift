//
//  EmailValidator.swift
//  ForwardLeasing
//

import Foundation

class EmailValidator: TextInputValidator {
  override func validate(_ text: String?) throws {
    guard let text = text, !text.isEmpty else {
      throw ValidationError.emptyText
    }
    guard text.count < 30 else {
      throw ValidationError.invalidEmail
    }
    let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    guard text.lowercased().matches(regularExpression: regex) else {
      throw ValidationError.invalidEmail
    }
  }
}

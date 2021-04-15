//
//  CyrillicValidator.swift
//  ForwardLeasing
//

import Foundation

class CyrillicValidator: TextInputValidator {
  override func validate(_ text: String?) throws {
    guard let text = text, !text.isEmpty else {
      throw ValidationError.emptyText
    }
    let regex = "^[^a-zA-Z]+$"
    guard text.matches(regularExpression: regex) else {
      throw ValidationError.invalidCyrillicFormat
    }
  }
}

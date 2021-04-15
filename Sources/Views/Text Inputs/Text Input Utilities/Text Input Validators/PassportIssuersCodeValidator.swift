//
//  PassportIssuersCodeValidator.swift
//  ForwardLeasing
//

import Foundation

class PassportIssuersCodeValidator: TextInputValidator {
  override func validate(_ text: String?) throws {
    guard let sanitizedText = text?.trimmingCharacters(in: .whitespacesAndNewlines),
      !sanitizedText.isEmpty else {
      throw ValidationError.emptyText
    }
    guard isValueValid(sanitizedText) else {
      throw ValidationError.invalidPassportIssuersCode
    }
  }

  func isValueValid(_ value: String) -> Bool {
    let regex = "[0-9]{3}-[0-9]{3}"
    return value.matches(regularExpression: regex)
  }
}

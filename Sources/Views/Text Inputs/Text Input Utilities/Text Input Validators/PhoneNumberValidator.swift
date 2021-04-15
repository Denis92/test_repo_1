//
//  PhoneNumberValidator.swift
//  ForwardLeasing
//

import Foundation

class PhoneNumberValidator: TextInputValidator {
  override func validate(_ text: String?) throws {
    guard let sanitizedText = text?.trimmingCharacters(in: .whitespacesAndNewlines),
      !sanitizedText.isEmpty else {
      throw ValidationError.emptyText
    }
    guard isValueValid(sanitizedText) else {
      throw ValidationError.invalidPhoneNumber
    }
  }

  func isValueValid(_ value: String) -> Bool {
    let regex = "7[0-9]{10}"
    return value.matches(regularExpression: regex)
  }
}

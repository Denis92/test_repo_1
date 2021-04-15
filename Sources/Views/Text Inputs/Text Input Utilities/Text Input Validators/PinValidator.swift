//
//  PinValidator.swift
//  ForwardLeasing
//

import Foundation

class PinValidator: TextInputValidator {
  override func validate(_ text: String?) throws {
    guard let sanitizedText = text?.trimmingCharacters(in: .whitespacesAndNewlines),
      !sanitizedText.isEmpty else {
      throw ValidationError.emptyText
    }
    guard isValueValid(sanitizedText) else {
      throw ValidationError.invalidPin
    }
  }

  func isValueValid(_ value: String) -> Bool {
    return value.count == 4
  }
}

//
//  SalaryValidator.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let minSalary = 1000
  static let maxSalary = 10000000
}

class SalaryValidator: TextInputValidator {
  override func validate(_ text: String?) throws {
    guard let text = text, !text.isEmpty else {
      throw ValidationError.emptyText
    }
    let sanitizedText = text.sanitizedSalary()
    let regex = "^[0-9]+$"
    guard sanitizedText.matches(regularExpression: regex) else {
      throw ValidationError.invalidSalary
    }
    guard let salary = Int(sanitizedText),
          (Constants.minSalary ... Constants.maxSalary).contains(salary) else {
      throw ValidationError.invalidSalary
    }
  }
}

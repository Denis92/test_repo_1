//
//  EmptyTextValidator.swift
//  ForwardLeasing
//

import Foundation

class EmptyTextValidator: TextInputValidator {
  override func validate(_ text: String?) throws {
    guard let text = text, !text.isEmpty else {
      throw ValidationError.emptyText
    }
  }
}

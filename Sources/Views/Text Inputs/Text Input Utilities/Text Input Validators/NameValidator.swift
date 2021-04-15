//
//  NameValidator.swift
//  ForwardLeasing
//

import Foundation

enum NameValidatorType {
  case firstname
  case middlename
  case lastname
}

class NameValidator: TextInputValidator {
  private let type: NameValidatorType
  
  init(type: NameValidatorType) {
    self.type = type
  }
  
  override func validate(_ text: String?) throws {
    guard let text = text, !text.isEmpty else {
      if type == .middlename {
        return
      }
      throw ValidationError.emptyText
    }

    let regex = "[^а-яА-ЯЁё]"
    guard !text.matches(regularExpression: regex) else {
      switch type {
      case .firstname:
        throw ValidationError.invalidFirstname
      case .middlename:
        throw ValidationError.invalidMiddlename
      case .lastname:
        throw ValidationError.invalidLastname
      }
    }
  }
}

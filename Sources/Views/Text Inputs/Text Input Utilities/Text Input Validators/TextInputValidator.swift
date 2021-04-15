//
//  TextInputValidator.swift
//  ForwardLeasing
//

import Foundation

class TextInputValidator {
  func validate(_ text: String?) throws {
    let sanitizedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !sanitizedText.isEmptyOrNil else {
      throw ValidationError.emptyText
    }
  }
}

// MARK: - Factory

enum TextInputValidatorType {
  case `default`, phoneNumber, email, name(NameValidatorType),
       cyrillic, emptyText, dateOfBirth, salary, passportIssuersCode, pin
}

struct TextInputValidatorFactory {
  // swiftlint:disable:next cyclomatic_complexity
  static func makeValidator(for type: TextInputValidatorType?) -> TextInputValidator? {
    guard let type = type else {
      return nil
    }
    switch type {
    case .default:
      return TextInputValidator()
    case .phoneNumber:
      return PhoneNumberValidator()
    case .email:
      return EmailValidator()
    case .name(let type):
      return NameValidator(type: type)
    case .cyrillic:
      return CyrillicValidator()
    case .emptyText:
      return EmptyTextValidator()
    case .dateOfBirth:
      return DateOfBirthValidator()
    case .salary:
      return SalaryValidator()
    case .passportIssuersCode:
      return PassportIssuersCodeValidator()
    case .pin:
      return PinValidator()
    }
  }
}

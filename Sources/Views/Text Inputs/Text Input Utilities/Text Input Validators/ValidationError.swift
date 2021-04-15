//
//  ValidationError.swift
//  ForwardLeasing
//

import Foundation

enum ValidationError: Error {
  case emptyText
  case invalidDate
  case invalidPhoneNumber
  case invalidEmail
  case invalidDateOfBirth
  case invalidFirstname
  case invalidMiddlename
  case invalidLastname
  case invalidSalary
  case invalidCyrillicFormat
  case invalidRegistrationAddress
  case invalidPassportIssuersCode
  case invalidPin
  case invalidDeliveryAddress
}

extension ValidationError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .emptyText:
      return R.string.validationError.emptyTextError()
    case .invalidPhoneNumber:
      return R.string.validationError.phoneValidationError()
    case .invalidEmail:
      return R.string.validationError.emailValidationError()
    case .invalidFirstname:
      return R.string.validationError.nameValidationError(R.string.validationError.firstnameValidation())
    case .invalidMiddlename:
      return R.string.validationError.nameValidationError(R.string.validationError.middlenameValidation())
    case .invalidLastname:
      return R.string.validationError.nameValidationError(R.string.validationError.lastnameValidation())
    case .invalidDate:
      return R.string.validationError.dateValidationError()
    case .invalidDateOfBirth:
      return R.string.validationError.dateOfBirthValidationError()
    case .invalidSalary:
      return R.string.validationError.salaryValidationError()
    case .invalidCyrillicFormat:
      return R.string.validationError.invalidCyrillicFormat()
    case .invalidRegistrationAddress:
      return R.string.validationError.registrationAddressValidationError()
    case .invalidPassportIssuersCode:
      return R.string.validationError.passportIssuersCodeValidationError()
    case .invalidPin:
      return R.string.validationError.pinValidationError()
    case .invalidDeliveryAddress:
      return R.string.validationError.deliveryAddressValidationError()
    }
  }
}

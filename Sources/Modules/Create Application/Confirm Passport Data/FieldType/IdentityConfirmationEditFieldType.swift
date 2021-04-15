//
//  IdentityConfirmationEditFieldType.swift
//  ForwardLeasing
//

import UIKit

enum IdentityConfirmationEditFieldType: Int, CaseIterable, LayoutedFieldType {
  case lastname
  case firstname
  case middlename
  case dateOfBirth
  case placeOfBirth
  case passport
  case dateOfReceiving
  case issuedBy
  case divisionCode
  case registrationAddress
  case apartmentNumber
  case typeOfEmployment
  case salary
  
  var returnKeyType: UIReturnKeyType {
    switch self {
    case .salary:
      return .done
    default:
      return .next
    }
  }

  var keyboardType: UIKeyboardType {
    switch self {
    case .salary, .divisionCode:
      return .numberPad
    default:
      return .default
    }
  }

  var spacingAfterTextInput: CGFloat {
    return 0
  }

  var textInputLayoutType: TextInputLayoutType {
    switch self {
    case .registrationAddress:
      return .partialWidthStretching(position: .first)
    case .apartmentNumber:
      return .partialWidthFixed(width: 64, position: .last)
    default:
      return .fullWidth
    }
  }

  var validatorType: TextInputValidatorType? {
    switch self {
    case .firstname:
      return .name(.firstname)
    case .middlename:
      return .name(.middlename)
    case .lastname:
      return .name(.lastname)
    case .placeOfBirth, .registrationAddress, .issuedBy:
      return .cyrillic
    case .dateOfBirth:
      return .dateOfBirth
    case .salary:
      return .salary
    case .divisionCode:
      return .passportIssuersCode
    case .apartmentNumber:
      return nil
    default:
      return .emptyText
    }
  }

  var formatterType: TextInputFormatterType? {
    switch self {
    case .firstname, .middlename, .lastname:
      return .textLength(maxSymbolCount: 30)
    case .placeOfBirth:
      return .textLength(maxSymbolCount: 120)
    case .issuedBy:
      return .textLength(maxSymbolCount: 150)
    case .salary:
      return .salary
    case .divisionCode:
      return .passportIssuersCode
    default:
      return nil
    }
  }

  var title: String? {
    let strings = R.string.passportDataConfirmation.self
    switch self {
    case .lastname:
      return strings.lastnameFieldTitle()
    case .firstname:
      return strings.firstnameFieldTitle()
    case .middlename:
      return strings.middlenameFieldTitle()
    case .dateOfBirth:
      return strings.dateOfBirthFieldTitle()
    case .passport:
      return strings.passportFieldTitle()
    case .dateOfReceiving:
      return strings.dateOfReceiving()
    case .issuedBy:
      return strings.issuedBy()
    case .divisionCode:
      return strings.divisionCode()
    case .registrationAddress:
      return strings.registrationAddress()
    case .apartmentNumber:
      return strings.apartmentNumber()
    case .typeOfEmployment:
      return strings.typeOfEmployment()
    case .salary:
      return strings.salary()
    case .placeOfBirth:
      return strings.placeOfBirthFieldTitle()
    }
  }

  var hint: String? {
    return nil
  }

  var isEnabled: Bool {
    switch self {
    case .passport:
      return false
    default:
      return true
    }
  }

  var hasClearButton: Bool {
    return false
  }

  var textInputType: TextInputType {
    switch self {
    case .dateOfReceiving, .dateOfBirth:
      return .datePicker(mode: .date, minDate: nil, maxDate: Date(), dateFormatter: DateFormatter.dayMonthYearDisplayable)
    case .typeOfEmployment:
      return .picker
    default:
      return .keyboard
    }
  }

  var textContainerType: TextContainerType {
    return .outlinedSingleLine
  }
  
  var isSecureTextEntry: Bool {
   return false
  }

  var letterSpacing: CGFloat {
    return -0.24
  }
}

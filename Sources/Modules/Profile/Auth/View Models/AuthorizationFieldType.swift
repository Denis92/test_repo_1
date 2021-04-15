//
//  AuthorizationFieldType.swift
//  ForwardLeasing
//

import UIKit

enum AuthorizationFieldType: Int, CaseIterable, FieldType {
  case phoneNumber, pin
  
  var returnKeyType: UIReturnKeyType {
    switch self {
    case .phoneNumber:
      return .next
    case .pin:
      return .done
    }
  }

  var keyboardType: UIKeyboardType {
    switch self {
    case .phoneNumber:
      return .phonePad
    case .pin:
      return .numberPad
    }
  }

  var spacingAfterTextInput: CGFloat {
    switch self {
    case .phoneNumber:
      return 32
    case .pin:
      return 16
    }
  }

  var textInputLayoutType: TextInputLayoutType {
    return .fullWidth
  }

  var validatorType: TextInputValidatorType? {
    switch self {
    case .phoneNumber:
      return .phoneNumber
    case .pin:
      return .pin
    }
  }

  var formatterType: TextInputFormatterType? {
    switch self {
    case .phoneNumber:
      return .phoneNumber
    case .pin:
      return .textLength(maxSymbolCount: 4)
    }
  }

  var title: String? {
    let strings = R.string.textInputs.self
    switch self {
    case .phoneNumber:
      return strings.phoneFieldTitle()
    case .pin:
      return strings.pinFieldTitle()
    }
  }

  var hint: String? {
    return nil
  }

  var isEnabled: Bool {
    return true
  }

  var hasClearButton: Bool {
    return false
  }

  var textInputType: TextInputType {
    return .keyboard
  }

  var textContainerType: TextContainerType {
    return .underscoredSingleLine
  }
  
  var isSecureTextEntry: Bool {
    switch self {
    case .phoneNumber:
      return false
    case .pin:
      return true
    }
  }

  var letterSpacing: CGFloat {
    switch self {
    case .phoneNumber:
      return -0.38
    case .pin:
      return 12
    }
  }
}

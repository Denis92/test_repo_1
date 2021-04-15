//
//  RegistrationFieldType.swift
//  ForwardLeasing
//

import UIKit

enum RegisterFieldType: Int, CaseIterable, FieldType {
  case phoneNumber
  case email
  
  var returnKeyType: UIReturnKeyType {
    switch self {
    case .phoneNumber:
      return .next
    case .email:
      return .done
    }
  }

  var keyboardType: UIKeyboardType {
    switch self {
    case .email:
      return .emailAddress
    case .phoneNumber:
      return .phonePad
    }
  }

  var spacingAfterTextInput: CGFloat {
    switch self {
    case .phoneNumber:
      return 16
    case .email:
      return 0
    }
  }

  var textInputLayoutType: TextInputLayoutType {
    return .fullWidth
  }

  var validatorType: TextInputValidatorType? {
    switch self {
    case .email:
      return .email
    case .phoneNumber:
      return .phoneNumber
    }
  }

  var formatterType: TextInputFormatterType? {
    switch self {
    case .email:
      return .whitespacesTrimming
    case .phoneNumber:
      return .phoneNumber
    }
  }

  var title: String? {
    let strings = R.string.auth.self
    switch self {
    case .phoneNumber:
      return strings.phoneFieldTitle()
    case .email:
      return strings.emailFieldTitle()
    }
  }
  
  var textContentType: UITextContentType? {
    switch self {
    case .email:
      return .emailAddress
    case .phoneNumber:
      return .telephoneNumber
    }
  }
  
  var autocapitalizationType: UITextAutocapitalizationType {
    return .none
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
   return false
  }

  var letterSpacing: CGFloat {
    return -0.38
  }
}

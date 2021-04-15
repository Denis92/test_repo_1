//
//  RecoveryPinFieldType.swift
//  ForwardLeasing
//

import UIKit

struct RecoveryPinFieldType: FieldType {
  var isFirst: Bool {
    return true
  }
  
  var isLast: Bool {
    return true
  }
  
  var previousFieldType: RecoveryPinFieldType? {
    return nil
  }
  
  var nextFieldType: RecoveryPinFieldType? {
    return nil
  }
  
  var returnKeyType: UIReturnKeyType {
    return .done
  }

  var keyboardType: UIKeyboardType {
    return .phonePad
  }

  var spacingAfterTextInput: CGFloat {
    return 0
  }

  var textInputLayoutType: TextInputLayoutType {
    return .fullWidth
  }

  var validatorType: TextInputValidatorType? {
    return .phoneNumber
  }

  var formatterType: TextInputFormatterType? {
    return .phoneNumber
  }

  var title: String? {
    return R.string.auth.phoneFieldTitle()
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

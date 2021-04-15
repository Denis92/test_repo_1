//
//  AnyFieldType.swift
//  ForwardLeasing
//

import UIKit

struct AnyFieldType<T: FieldType>: FieldType {
  var isFirst: Bool {
    return wrapped.isFirst
  }
  
  var isLast: Bool {
    return wrapped.isLast
  }
  
  var previousFieldType: AnyFieldType? {
    return AnyFieldType(type: wrapped.previousFieldType ?? wrapped,
                        isEnabled: isEnabled)
  }
  
  var nextFieldType: AnyFieldType? {
    return AnyFieldType(type: wrapped.nextFieldType ?? wrapped,
                        isEnabled: isEnabled)
  }
  
  var returnKeyType: UIReturnKeyType {
    return wrapped.returnKeyType
  }

  var keyboardType: UIKeyboardType {
    return wrapped.keyboardType
  }

  var validatorType: TextInputValidatorType? {
    return wrapped.validatorType
  }

  var formatterType: TextInputFormatterType? {
    return wrapped.formatterType
  }

  var title: String? {
    return wrapped.title
  }

  var hint: String? {
    return wrapped.hint
  }

  var hasClearButton: Bool {
    return wrapped.hasClearButton
  }

  var textInputType: TextInputType {
    return wrapped.textInputType
  }

  var textContainerType: TextContainerType {
    return wrapped.textContainerType
  }
  
  var isSecureTextEntry: Bool {
    return wrapped.isSecureTextEntry
  }

  var letterSpacing: CGFloat {
    return wrapped.letterSpacing
  }
  
  var autocapitalizationType: UITextAutocapitalizationType {
    return wrapped.autocapitalizationType
  }
  
  var textContentType: UITextContentType? {
    return wrapped.textContentType
  }
  
  let isEnabled: Bool
  let wrapped: T
  
  init(type: T,
       isEnabled: Bool) {
    self.wrapped = type
    self.isEnabled = isEnabled
  }
}

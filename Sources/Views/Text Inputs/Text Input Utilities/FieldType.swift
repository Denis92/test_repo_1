//
//  FieldType.swift
//  ForwardLeasing
//

import UIKit

enum TextContainerType {
  case outlinedSingleLine, underscoredSingleLine
}

enum TextInputType {
  case keyboard, datePicker(mode: UIDatePicker.Mode, minDate: Date?, maxDate: Date?, dateFormatter: DateFormatter), picker
}

protocol LayoutedFieldType: FieldType {
  var textInputLayoutType: TextInputLayoutType { get }
}

protocol FieldType: Equatable {
  var isFirst: Bool { get }
  var isLast: Bool { get }
  var hasToolbar: Bool { get }

  var previousFieldType: Self? { get }
  var nextFieldType: Self? { get }

  var keyboardType: UIKeyboardType { get }
  var returnKeyType: UIReturnKeyType { get }
  var textContentType: UITextContentType? { get }
  var autocapitalizationType: UITextAutocapitalizationType { get }

  var formatterType: TextInputFormatterType? { get }
  var validatorType: TextInputValidatorType? { get }

  var dateFormatter: DateFormatter? { get }

  var textInputType: TextInputType { get }
  var textContainerType: TextContainerType { get }
  var hasClearButton: Bool { get }
  var hasCharacterCounter: Bool { get }
  var isSecureTextEntry: Bool { get }
  var isEnabled: Bool { get }
  var letterSpacing: CGFloat { get }
  var hasSecureModeSwitchButton: Bool { get }
  var hasDownwardChevronRightView: Bool { get }
  var autocorrectionType: UITextAutocorrectionType { get }

  var title: String? { get }
  var hint: String? { get }
}

extension FieldType {
  var keyboardType: UIKeyboardType {
    return .default
  }

  var autocapitalizationType: UITextAutocapitalizationType {
    return .sentences
  }

  var returnKeyType: UIReturnKeyType {
    return .default
  }

  var isEnabled: Bool {
    return true
  }

  var formatterType: TextInputFormatterType? {
    return nil
  }

  var validatorType: TextInputValidatorType? {
    return nil
  }

  var dateFormatter: DateFormatter? {
    return nil
  }

  var textInputType: TextInputType {
    return .keyboard
  }

  var letterSpacing: CGFloat {
    return 1
  }

  var textContentType: UITextContentType? {
    return nil
  }

  var textContainerType: TextContainerType {
    return .outlinedSingleLine
  }

  var hint: String? {
    return nil
  }

  var shouldAnimateEditingStart: Bool {
    return true
  }

  var scrollToFieldWhenEditingNotAllowed: Bool {
    return true
  }

  var hasClearButton: Bool {
    return true
  }

  var hasCharacterCounter: Bool {
    return false
  }

  var hasDownwardChevronRightView: Bool {
    return false
  }

  var isSecureTextEntry: Bool {
    return false
  }

  var hasSecureModeSwitchButton: Bool {
    return isSecureTextEntry
  }

  var hasToolbar: Bool {
    return true
  }
  
  var autocorrectionType: UITextAutocorrectionType {
    return .no
  }
}

extension FieldType where Self: RawRepresentable & CaseIterable, Self.RawValue == Int {
  var isFirst: Bool {
    return rawValue == 0
  }

  var isLast: Bool {
    return rawValue == Self.allCases.count - 1
  }

  var previousFieldType: Self? {
    return Self(rawValue: rawValue - 1)
  }

  var nextFieldType: Self? {
    return Self(rawValue: rawValue + 1)
  }
}

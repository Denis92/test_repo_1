//
//  AddressFieldType.swift
//  ForwardLeasing
//

import UIKit

enum AddressFieldType: Int, CaseIterable, LayoutedFieldType {
  case deliveryAddress
  case apartmentNumber
  
  var returnKeyType: UIReturnKeyType {
    return .done
  }

  var keyboardType: UIKeyboardType {
      return .default
  }

  var spacingAfterTextInput: CGFloat {
    return 0
  }

  var textInputLayoutType: TextInputLayoutType {
    switch self {
    case .deliveryAddress:
      return .partialWidthStretching(position: .first)
    case .apartmentNumber:
      return .partialWidthFixed(width: 64, position: .last)
    }
  }

  var validatorType: TextInputValidatorType? {
    switch self {
    case .deliveryAddress:
      return .emptyText
    default:
      return nil
    }
  }

  var formatterType: TextInputFormatterType? {
    return nil
  }

  var title: String? {
    switch self {
    case .deliveryAddress:
      return R.string.deliveryProduct.deliveryAddressFieldTitle()
    case .apartmentNumber:
      return R.string.passportDataConfirmation.apartmentNumber()
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
    return .outlinedSingleLine
  }
  
  var isSecureTextEntry: Bool {
   return false
  }

  var letterSpacing: CGFloat {
    return -0.24
  }
}

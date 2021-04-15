//
//  RegisterViewModelFactory.swift
//  ForwardLeasing
//

import Foundation

struct RegisterViewModelFieldsFactory {
  static func makeFields(hasPhoneNumber: Bool) -> [AnyFieldType<RegisterFieldType>] {
    return [
      AnyFieldType<RegisterFieldType>(type: .phoneNumber, isEnabled: !hasPhoneNumber),
      AnyFieldType<RegisterFieldType>(type: .email, isEnabled: true)
    ]
  }
}

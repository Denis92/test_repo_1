//
//  String+Validation.swift
//  ForwardLeasing
//

import Foundation

extension String {
  func matches(regularExpression: String) -> Bool {
    return self.range(of: regularExpression, options: .regularExpression, range: nil, locale: nil) != nil
  }
  
  func isValidEmail() -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    return lowercased().matches(regularExpression: emailRegEx)
  }
}

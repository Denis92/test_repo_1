//
//  String+Sanitized.swift
//  ForwardLeasing
//

import Foundation

extension String {
  func sanitizedPhoneNumber() -> String {
    let newString = replacingOccurrences(of: "^\\+7", with: "", options: .regularExpression)
      .replacingOccurrences(of: "[\\(\\)-]", with: "", options: .regularExpression)
    let components = newString.components(separatedBy: .whitespaces)
    return components.joined(separator: "")
  }
  
  func sanitizedSalary() -> String {
    let currencyFormatter = NumberFormatter.currencyFormatter()
    let currencySymbol = currencyFormatter.currencySymbol ?? ""
    let sanitizedText = components(separatedBy: .whitespaces).joined()
      .replacingOccurrences(of: "\(currencySymbol)", with: "")
    return sanitizedText
  }
  
  func sanitizedSlash() -> String {
    return self.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
  }
}

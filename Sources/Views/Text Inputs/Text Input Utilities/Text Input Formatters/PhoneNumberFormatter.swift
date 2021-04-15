//
//  PhoneNumberFormatter.swift
//  ForwardLeasing
//

import Foundation

struct PhoneNumberFormatter: TextInputFormatter {
  func formattedText(_ text: String) -> String {
    guard !text.isEmpty else { return text }
    return formattedPhoneNumber(text)
  }
  
  func sanitizedText(_ text: String?) -> String? {
    guard let text = text else { return nil }
    return sanitizedPhoneNumber(text)
  }
  
  func formattedPhoneNumber(_ phoneNumber: String,
                            mask: String = "+X (XXX) XXX-XX-XX",
                            withPrefix: Bool = true) -> String {
    guard !phoneNumber.isEmpty else { return withPrefix ? "+7" : phoneNumber }
    if phoneNumber == "+" {
      return "+7"
    }
    var sanitizedString = sanitizedPhoneNumber(phoneNumber)
    if withPrefix {
      if sanitizedString.count == 1 {
        sanitizedString = sanitizedString.contains { $0 == "7" || $0 == "8" }
          ? "7"
          : "7\(sanitizedString)"
      }
    }
    var formattedString = mask
    sanitizedString.forEach {
      guard let index = formattedString.firstIndex(of: "X") else { return }
      formattedString.remove(at: index)
      formattedString.insert($0, at: index)
    }
    if let index = formattedString.firstIndex(of: "X") {
      formattedString = String(formattedString.prefix(upTo: index))
    }
    var lastCharacter = formattedString.last ?? Character("")
    var characterSet = CharacterSet(charactersIn: "()-")
    characterSet.formUnion(.whitespaces)
    while lastCharacter.unicodeScalars.allSatisfy({ characterSet.contains($0) }) {
      _ = formattedString.popLast()
      lastCharacter = formattedString.last ?? Character("")
    }
    return formattedString
  }
  
  func sanitizedPhoneNumber(_ phoneNumber: String) -> String {
    guard !phoneNumber.isEmpty else { return phoneNumber }
    let range = phoneNumber.startIndex..<phoneNumber.index(phoneNumber.startIndex,
                                                           offsetBy: phoneNumber.count)
    let result = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "",
                                                  options: .regularExpression,
                                                  range: range)
    return result.count > 11 ? String(result.prefix(11)) : result
  }
}

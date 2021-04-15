//
//  SalaryFormatter.swift
//  ForwardLeasing
//

import Foundation

private extension Constants {
  static let maxSalary = 10000000
}

struct SalaryFormatter: TextInputFormatter {
  private let formatter = NumberFormatter.currencyFormatter()
  
  func formattedText(_ text: String) -> String {
    var text = text
    text = trimLastCharacterIfNeeded(from: text)
    let sanitizedText = text.sanitizedSalary()
    guard var price = Int(sanitizedText) else {
      return text
    }
    if price > Constants.maxSalary {
      price /= 10
    }
    let string = formatter.string(from: price as NSNumber) ?? text
    return string
  }
  
  private func trimLastCharacterIfNeeded(from text: String) -> String {
    guard let currencySymbol = formatter.currencySymbol else { return text }
    var text = text
    
    guard !text.isEmpty else {
      return text
    }
    
    var lastCharacter = text.last ?? Character("")
    guard lastCharacter != Character(currencySymbol) else {
      return text
    }
    
    let characterSet = CharacterSet(charactersIn: currencySymbol).union(.whitespaces)
    var shouldRemoveLastSymbol = false
    while lastCharacter.unicodeScalars.allSatisfy({ characterSet.contains($0) }) {
      _ = text.popLast()
      lastCharacter = text.last ?? Character("")
      shouldRemoveLastSymbol = true
    }
    if shouldRemoveLastSymbol {
      _ = text.popLast()
    }
    return text
  }
  
  func sanitizedText(_ text: String?) -> String? {
    guard let textValue = text, !textValue.isEmpty else {
      return text
    }
    
    if let number = formatter.number(from: textValue) {
      return "\(number.intValue)"
    } else {
      return textValue
    }
  }
}

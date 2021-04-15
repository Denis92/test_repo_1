//
//  PassportIssuersCodeFormatter.swift
//  ForwardLeasing
//

import Foundation

struct PassportIssuersCodeFormatter: TextInputFormatter {
  func formattedText(_ text: String) -> String {
    guard !text.isEmpty else { return text }
    return formattedCode(text)
  }
  
  func formattedCode(_ text: String) -> String {
    guard !text.isEmpty else { return text }
    let sanitizedString = text.replacingOccurrences(of: "-", with: "")
    var formattedString = "XXX-XXX"
    
    sanitizedString.forEach {
      guard let index = formattedString.firstIndex(of: "X") else { return }
      formattedString.remove(at: index)
      formattedString.insert($0, at: index)
    }
    
    if let index = formattedString.firstIndex(of: "X") {
      formattedString = String(formattedString.prefix(upTo: index))
    }
    var lastCharacter = formattedString.last ?? Character("")
    var characterSet = CharacterSet(charactersIn: "-")
    characterSet.formUnion(.whitespaces)
    while lastCharacter.unicodeScalars.allSatisfy({ characterSet.contains($0) }) {
      _ = formattedString.popLast()
      lastCharacter = formattedString.last ?? Character("")
    }
    return formattedString
  }
}

//
//  WhitespaceTrimmingFormatter.swift
//  ForwardLeasing
//

import Foundation

class WhitespaceTrimmingFormatter: TextInputFormatter {
  func formattedText(_ text: String) -> String {
    return text.trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .whitespaces).joined()
  }
}

//
//  MaxLengthFormatter.swift
//  ForwardLeasing
//

import Foundation

struct MaxLengthFormatter: TextInputFormatter {
  private let maxSymbolsCount: Int

  init(maxSymbolsCount: Int = Int.max) {
    self.maxSymbolsCount = maxSymbolsCount
  }

  func shouldFormatText(_ text: String) -> Bool {
    let sanitizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return sanitizedText.count > maxSymbolsCount
  }

  func formattedText(_ text: String) -> String {
    guard !text.isEmpty else { return text }
    return trimmedText(text)
  }

  func sanitizedText(_ text: String?) -> String? {
    return text?.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func trimmedText(_ text: String) -> String {
    let sanitizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return sanitizedText.count > maxSymbolsCount ? String(sanitizedText.prefix(maxSymbolsCount)) : text
  }
}

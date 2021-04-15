//
//  TextInputFormatter.swift
//  ForwardLeasing
//

import Foundation

enum TextInputFormatterType {
  case phoneNumber, textLength(maxSymbolCount: Int), salary,
       passportIssuersCode, whitespacesTrimming

  var maxCharacterCount: Int? {
    switch self {
    case .textLength(let maxSymbolCount):
      return maxSymbolCount
    default:
      return nil
    }
  }
}

protocol TextInputFormatter {
  func shouldFormatText(_ text: String) -> Bool
  func formattedText(_ text: String) -> String
  func sanitizedText(_ text: String?) -> String?
  func shouldChangeCharacters(in range: NSRange, originalString: String,
                              replacementString: String) -> Bool
}

extension TextInputFormatter {
  func shouldFormatText(_ text: String) -> Bool {
    return true
  }
  
  func sanitizedText(_ text: String?) -> String? {
    return text
  }

  func shouldChangeCharacters(in range: NSRange, originalString: String,
                              replacementString: String) -> Bool {
    return true
  }
}

struct TextInputFormatterFactory {
  static func makeFormatter(for type: TextInputFormatterType?) -> TextInputFormatter? {
    guard let type = type else { return nil }
    switch type {
    case .phoneNumber:
      return PhoneNumberFormatter()
    case .textLength(let count):
      return MaxLengthFormatter(maxSymbolsCount: count)
    case .salary:
      return SalaryFormatter()
    case .passportIssuersCode:
      return PassportIssuersCodeFormatter()
    case .whitespacesTrimming:
      return WhitespaceTrimmingFormatter()
    }
  }
}

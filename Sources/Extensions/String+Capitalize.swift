//
//  String+Capitalize.swift
//  ForwardLeasing
//

import Foundation

extension String {
  func capitalizingFirstLetter() -> String {
      return prefix(1).capitalized + dropFirst()
  }

  mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
  }

  func lowercasedFirstLetter() -> String {
      return prefix(1).lowercased() + dropFirst()
  }

  mutating func lowercaseFirstLetter() {
      self = self.lowercasedFirstLetter()
  }
}

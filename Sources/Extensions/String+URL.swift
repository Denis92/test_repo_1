//
//  String+URL.swift
//  ForwardLeasing
//

import Foundation

extension String {
  var encodedURLString: String {
    let allowed = "-._~"
    let reserved = "/?#%:!$&'()*+,/:;=@[]"
    var characterSet: CharacterSet = .urlQueryAllowed
    characterSet.insert(charactersIn: allowed)
    characterSet.insert(charactersIn: reserved)
    return addingPercentEncoding(withAllowedCharacters: characterSet) ?? self
  }

  func toURL() -> URL? {
    return URL(string: encodedURLString)
  }
}

extension Optional where Wrapped == String {
  func toURL() -> URL? {
    switch self {
    case .some(let string):
      return string.toURL()
    case .none:
      return nil
    }
  }
}
